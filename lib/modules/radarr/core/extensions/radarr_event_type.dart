import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrEventType on RadarrEventType {
  // Get Zagreus associated colour of the event type.
  Color get zagColour {
    switch (this) {
      case RadarrEventType.GRABBED:
        return ZagColours.orange;
      case RadarrEventType.DOWNLOAD_FAILED:
        return ZagColours.red;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return ZagColours.currentAccent;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return ZagColours.purple;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return ZagColours.red;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return ZagColours.blue;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return ZagColours.currentAccent;
    }
  }

  IconData get zagIcon {
    switch (this) {
      case RadarrEventType.GRABBED:
        return Icons.cloud_download_rounded;
      case RadarrEventType.DOWNLOAD_FAILED:
        return Icons.cloud_download_rounded;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return Icons.delete_rounded;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return Icons.cancel_rounded;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return Icons.drive_file_rename_outline_rounded;
    }
  }

  Color get zagIconColour {
    switch (this) {
      case RadarrEventType.GRABBED:
        return Colors.white;
      case RadarrEventType.DOWNLOAD_FAILED:
        return ZagColours.red;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Colors.white;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return Colors.white;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return Colors.white;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return Colors.white;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return Colors.white;
    }
  }

  String? zagReadable(RadarrHistoryRecord record) {
    switch (this) {
      case RadarrEventType.GRABBED:
        return 'radarr.GrabbedFrom'
            .tr(args: [(record.data ?? {})['indexer'] ?? ZagUI.TEXT_EMDASH]);
      case RadarrEventType.DOWNLOAD_FAILED:
        return 'radarr.DownloadFailed'.tr();
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return 'radarr.MovieImported'
            .tr(args: [record.quality?.quality?.name ?? ZagUI.TEXT_EMDASH]);
      case RadarrEventType.DOWNLOAD_IGNORED:
        return 'radarr.DownloadIgnored'.tr();
      case RadarrEventType.MOVIE_FILE_DELETED:
        return 'radarr.MovieFileDeleted'.tr();
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return 'radarr.MovieFileRenamed'.tr();
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return 'radarr.MovieImported'
            .tr(args: [record.quality?.quality?.name ?? ZagUI.TEXT_EMDASH]);
    }
  }

  List<ZagTableContent> zagTableContent(
    RadarrHistoryRecord record, {
    bool movieHistory = false,
  }) {
    switch (this) {
      case RadarrEventType.GRABBED:
        return _grabbedTableContent(record, !movieHistory);
      case RadarrEventType.DOWNLOAD_FAILED:
        return _downloadFailedTableContent(record, !movieHistory);
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return _downloadFolderImportedTableContent(record);
      case RadarrEventType.DOWNLOAD_IGNORED:
        return _downloadIgnoredTableContent(record, !movieHistory);
      case RadarrEventType.MOVIE_FILE_DELETED:
        return _movieFileDeletedTableContent(record, !movieHistory);
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return _movieFileRenamedTableContent(record);
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return _movieFolderImportedTableContent(record);
      default:
        return [];
    }
  }

  List<ZagTableContent> _grabbedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'languages',
        body: record.languages
            ?.map<String?>((language) => language.name)
            .join('\n'),
      ),
      ZagTableContent(
        title: 'indexer',
        body: record.data!['indexer'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'group',
        body: record.data!['releaseGroup'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'age',
        body: record.data!['ageHours'] != null
            ? double.tryParse((record.data!['ageHours'] as String))
                    ?.asTimeAgo() ??
                ZagUI.TEXT_EMDASH
            : ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'published date',
        body: DateTime.tryParse(record.data!['publishedDate']) != null
            ? DateTime.tryParse(record.data!['publishedDate'])
                    ?.asDateTime(delimiter: '\n') ??
                ZagUI.TEXT_EMDASH
            : ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'info url',
        body: record.data!['nzbInfoUrl'] ?? ZagUI.TEXT_EMDASH,
        bodyIsUrl: record.data!['nzbInfoUrl'] != null,
      ),
    ];
  }

  List<ZagTableContent> _downloadFailedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'message',
        body: record.data!['message'] ?? ZagUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZagTableContent> _downloadFolderImportedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZagTableContent(
        title: 'source title',
        body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'languages',
        body: record.languages
                ?.map<String?>((language) => language.name)
                .join('\n') ??
            ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'source',
        body: record.data!['droppedPath'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'imported to',
        body: record.data!['importedPath'] ?? ZagUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZagTableContent> _downloadIgnoredTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'message',
        body: record.data!['message'] ?? ZagUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZagTableContent> _movieFileDeletedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZagTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'reason',
        body: record.zagFileDeletedReasonMessage,
      ),
    ];
  }

  List<ZagTableContent> _movieFileRenamedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZagTableContent(
        title: 'source',
        body: record.data!['sourceRelativePath'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'destination',
        body: record.data!['relativePath'] ?? ZagUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZagTableContent> _movieFolderImportedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZagTableContent(
        title: 'source title',
        body: record.sourceTitle ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'languages',
        body: ([RadarrLanguage(name: ZagUI.TEXT_EMDASH)])
            .map<String?>((language) => language.name)
            .join('\n'),
      ),
      ZagTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'source',
        body: record.data!['droppedPath'] ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'imported to',
        body: record.data!['importedPath'] ?? ZagUI.TEXT_EMDASH,
      ),
    ];
  }
}
