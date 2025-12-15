import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrEventTypeZagExtension on SonarrEventType {
  Color zagColour() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return ZagColours.blue;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return ZagColours.red;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return ZagColours.currentAccent;
      case SonarrEventType.DOWNLOAD_FAILED:
        return ZagColours.red;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return ZagColours.purple;
      case SonarrEventType.GRABBED:
        return ZagColours.orange;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return ZagColours.currentAccent;
    }
  }

  IconData zagIcon() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return Icons.drive_file_rename_outline_rounded;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return Icons.delete_rounded;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case SonarrEventType.DOWNLOAD_FAILED:
        return Icons.cloud_download_rounded;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return Icons.cancel_rounded;
      case SonarrEventType.GRABBED:
        return Icons.cloud_download_rounded;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return Icons.download_rounded;
    }
  }

  Color zagIconColour() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return Colors.white;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return Colors.white;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Colors.white;
      case SonarrEventType.DOWNLOAD_FAILED:
        return ZagColours.red;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return Colors.white;
      case SonarrEventType.GRABBED:
        return Colors.white;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return Colors.white;
    }
  }

  String? zagReadable(SonarrHistoryRecord record) {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return 'sonarr.EpisodeFileRenamed'.tr();
      case SonarrEventType.EPISODE_FILE_DELETED:
        return 'sonarr.EpisodeFileDeleted'.tr();
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return 'sonarr.EpisodeImported'.tr(
          args: [record.quality?.quality?.name ?? 'zagreus.Unknown'.tr()],
        );
      case SonarrEventType.DOWNLOAD_FAILED:
        return 'sonarr.DownloadFailed'.tr();
      case SonarrEventType.GRABBED:
        return 'sonarr.GrabbedFrom'.tr(
          args: [record.data!['indexer'] ?? 'zagreus.Unknown'.tr()],
        );
      case SonarrEventType.DOWNLOAD_IGNORED:
        return 'sonarr.DownloadIgnored'.tr();
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return 'sonarr.SeriesFolderImported'.tr();
    }
  }

  List<ZagTableContent> zagTableContent({
    required SonarrHistoryRecord history,
    required bool showSourceTitle,
  }) {
    switch (this) {
      case SonarrEventType.DOWNLOAD_FAILED:
        return _downloadFailedTableContent(history, showSourceTitle);
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return _downloadFolderImportedTableContent(history, showSourceTitle);
      case SonarrEventType.DOWNLOAD_IGNORED:
        return _downloadIgnoredTableContent(history, showSourceTitle);
      case SonarrEventType.EPISODE_FILE_DELETED:
        return _episodeFileDeletedTableContent(history, showSourceTitle);
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return _episodeFileRenamedTableContent(history);
      case SonarrEventType.GRABBED:
        return _grabbedTableContent(history, showSourceTitle);
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
      default:
        return _defaultTableContent(history, showSourceTitle);
    }
  }

  List<ZagTableContent> _downloadFailedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZagTableContent(
        title: 'sonarr.Message'.tr(),
        body: history.data!['message'],
      ),
    ];
  }

  List<ZagTableContent> _downloadFolderImportedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZagTableContent(
        title: 'sonarr.Quality'.tr(),
        body: history.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      if (history.language != null)
        ZagTableContent(
          title: 'sonarr.Languages'.tr(),
          body: history.language?.name ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'sonarr.Client'.tr(),
        body: history.data!['downloadClient'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'sonarr.Source'.tr(),
        body: history.data!['droppedPath'],
      ),
      ZagTableContent(
        title: 'sonarr.ImportedTo'.tr(),
        body: history.data!['importedPath'],
      ),
    ];
  }

  List<ZagTableContent> _downloadIgnoredTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.Name'.tr(),
          body: history.sourceTitle,
        ),
      ZagTableContent(
        title: 'sonarr.Message'.tr(),
        body: history.data!['message'],
      ),
    ];
  }

  List<ZagTableContent> _episodeFileDeletedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    String _reasonMapping(String? reason) {
      switch (reason) {
        case 'Upgrade':
          return 'sonarr.DeleteReasonUpgrade'.tr();
        case 'MissingFromDisk':
          return 'sonarr.DeleteReasonMissingFromDisk'.tr();
        case 'Manual':
          return 'sonarr.DeleteReasonManual'.tr();
        default:
          return 'zagreus.Unknown'.tr();
      }
    }

    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZagTableContent(
        title: 'sonarr.Reason'.tr(),
        body: _reasonMapping(history.data!['reason']),
      ),
    ];
  }

  List<ZagTableContent> _episodeFileRenamedTableContent(
    SonarrHistoryRecord history,
  ) {
    return [
      ZagTableContent(
        title: 'sonarr.Source'.tr(),
        body: history.data!['sourcePath'],
      ),
      ZagTableContent(
        title: 'sonarr.SourceRelative'.tr(),
        body: history.data!['sourceRelativePath'],
      ),
      ZagTableContent(
        title: 'sonarr.Destination'.tr(),
        body: history.data!['path'],
      ),
      ZagTableContent(
        title: 'sonarr.DestinationRelative'.tr(),
        body: history.data!['relativePath'],
      ),
    ];
  }

  List<ZagTableContent> _grabbedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZagTableContent(
        title: 'sonarr.Quality'.tr(),
        body: history.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      if (history.language != null)
        ZagTableContent(
          title: 'sonarr.Languages'.tr(),
          body: history.language?.name ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'sonarr.Indexer'.tr(),
        body: history.data!['indexer'],
      ),
      ZagTableContent(
        title: 'sonarr.ReleaseGroup'.tr(),
        body: history.data!['releaseGroup'],
      ),
      ZagTableContent(
        title: 'sonarr.InfoURL'.tr(),
        body: history.data!['nzbInfoUrl'],
        bodyIsUrl: history.data!['nzbInfoUrl'] != null,
      ),
      ZagTableContent(
        title: 'sonarr.Client'.tr(),
        body: history.data!['downloadClientName'],
      ),
      ZagTableContent(
        title: 'sonarr.DownloadID'.tr(),
        body: history.data!['downloadId'],
      ),
      ZagTableContent(
        title: 'sonarr.Age'.tr(),
        body: double.tryParse(history.data!['ageHours'])?.asTimeAgo(),
      ),
      ZagTableContent(
          title: 'sonarr.PublishedDate'.tr(),
          body: DateTime.tryParse(history.data!['publishedDate'])
              ?.asDateTime(delimiter: '\n')),
    ];
  }

  List<ZagTableContent> _defaultTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'sonarr.Name'.tr(),
          body: history.sourceTitle,
        ),
    ];
  }
}
