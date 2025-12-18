import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

enum SonarrGlobalSettingsType {
  WEB_GUI,
  RUN_RSS_SYNC,
  SEARCH_ALL_MISSING,
  UPDATE_LIBRARY,
  BACKUP_DATABASE,
  HISTORY,
  MANUAL_IMPORT,
  TAGS,
}

extension SonarrGlobalSettingsTypeExtension on SonarrGlobalSettingsType {
  IconData get icon {
    switch (this) {
      case SonarrGlobalSettingsType.WEB_GUI:
        return Icons.language_rounded;
      case SonarrGlobalSettingsType.UPDATE_LIBRARY:
        return Icons.autorenew_rounded;
      case SonarrGlobalSettingsType.RUN_RSS_SYNC:
        return Icons.rss_feed_rounded;
      case SonarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return Icons.search_rounded;
      case SonarrGlobalSettingsType.BACKUP_DATABASE:
        return Icons.save_rounded;
      case SonarrGlobalSettingsType.HISTORY:
        return Icons.history_rounded;
      case SonarrGlobalSettingsType.MANUAL_IMPORT:
        return Icons.download_done_rounded;
      case SonarrGlobalSettingsType.TAGS:
        return Icons.style_rounded;
    }
  }

  String get name {
    switch (this) {
      case SonarrGlobalSettingsType.WEB_GUI:
        return 'sonarr.ViewWebGUI'.tr();
      case SonarrGlobalSettingsType.UPDATE_LIBRARY:
        return 'sonarr.UpdateLibrary'.tr();
      case SonarrGlobalSettingsType.RUN_RSS_SYNC:
        return 'sonarr.RunRSSSync'.tr();
      case SonarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return 'sonarr.SearchAllMissing'.tr();
      case SonarrGlobalSettingsType.BACKUP_DATABASE:
        return 'sonarr.BackupDatabase'.tr();
      case SonarrGlobalSettingsType.HISTORY:
        return 'sonarr.History'.tr();
      case SonarrGlobalSettingsType.MANUAL_IMPORT:
        return 'sonarr.ManualImport'.tr();
      case SonarrGlobalSettingsType.TAGS:
        return 'sonarr.Tags'.tr();
    }
  }

  Future<void> execute(BuildContext context) async {
    switch (this) {
      case SonarrGlobalSettingsType.WEB_GUI:
        return _webGUI(context);
      case SonarrGlobalSettingsType.RUN_RSS_SYNC:
        return _runRssSync(context);
      case SonarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return _searchAllMissing(context);
      case SonarrGlobalSettingsType.UPDATE_LIBRARY:
        return _updateLibrary(context);
      case SonarrGlobalSettingsType.BACKUP_DATABASE:
        return _backupDatabase(context);
      case SonarrGlobalSettingsType.HISTORY:
        return _openHistory(context);
      case SonarrGlobalSettingsType.MANUAL_IMPORT:
        return _openManualImport(context);
      case SonarrGlobalSettingsType.TAGS:
        return _openTags(context);
    }
  }

  Future<void> _webGUI(BuildContext context) async =>
      context.read<SonarrState>().host.openLink();
  Future<void> _backupDatabase(BuildContext context) async =>
      SonarrAPIController().backupDatabase(context: context);
  Future<void> _searchAllMissing(BuildContext context) async {
    bool result = await SonarrDialogs().searchAllMissingEpisodes(context);
    if (result) SonarrAPIController().missingEpisodesSearch(context: context);
  }

  Future<void> _runRssSync(BuildContext context) async =>
      SonarrAPIController().runRSSSync(context: context);
  Future<void> _updateLibrary(BuildContext context) async =>
      SonarrAPIController().updateLibrary(context: context);

  Future<void> _openHistory(BuildContext context) async =>
      SonarrRoutes.HISTORY.go();

  Future<void> _openManualImport(BuildContext context) async =>
      SonarrRoutes.MANUAL_IMPORT.go();

  Future<void> _openTags(BuildContext context) async =>
      SonarrRoutes.TAGS.go();
}
