import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

enum RadarrGlobalSettingsType {
  WEB_GUI,
  RUN_RSS_SYNC,
  SEARCH_ALL_MISSING,
  UPDATE_LIBRARY,
  BACKUP_DATABASE,
  HISTORY,
  MANUAL_IMPORT,
  SYSTEM_STATUS,
  TAGS,
}

extension RadarrGlobalSettingsTypeExtension on RadarrGlobalSettingsType {
  IconData get icon {
    switch (this) {
      case RadarrGlobalSettingsType.WEB_GUI:
        return Icons.language_rounded;
      case RadarrGlobalSettingsType.UPDATE_LIBRARY:
        return Icons.autorenew_rounded;
      case RadarrGlobalSettingsType.RUN_RSS_SYNC:
        return Icons.rss_feed_rounded;
      case RadarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return Icons.search_rounded;
      case RadarrGlobalSettingsType.BACKUP_DATABASE:
        return Icons.save_rounded;
      case RadarrGlobalSettingsType.HISTORY:
        return Icons.history_rounded;
      case RadarrGlobalSettingsType.MANUAL_IMPORT:
        return Icons.download_done_rounded;
      case RadarrGlobalSettingsType.SYSTEM_STATUS:
        return Icons.computer_rounded;
      case RadarrGlobalSettingsType.TAGS:
        return Icons.style_rounded;
    }
  }

  String get name {
    switch (this) {
      case RadarrGlobalSettingsType.WEB_GUI:
        return 'radarr.ViewWebGUI'.tr();
      case RadarrGlobalSettingsType.UPDATE_LIBRARY:
        return 'radarr.UpdateLibrary'.tr();
      case RadarrGlobalSettingsType.RUN_RSS_SYNC:
        return 'radarr.RunRSSSync'.tr();
      case RadarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return 'radarr.SearchAllMissing'.tr();
      case RadarrGlobalSettingsType.BACKUP_DATABASE:
        return 'radarr.BackupDatabase'.tr();
      case RadarrGlobalSettingsType.HISTORY:
        return 'radarr.History'.tr();
      case RadarrGlobalSettingsType.MANUAL_IMPORT:
        return 'radarr.ManualImport'.tr();
      case RadarrGlobalSettingsType.SYSTEM_STATUS:
        return 'radarr.SystemStatus'.tr();
      case RadarrGlobalSettingsType.TAGS:
        return 'radarr.Tags'.tr();
    }
  }

  Future<void> execute(BuildContext context) async {
    switch (this) {
      case RadarrGlobalSettingsType.WEB_GUI:
        return _webGUI(context);
      case RadarrGlobalSettingsType.RUN_RSS_SYNC:
        return _runRssSync(context);
      case RadarrGlobalSettingsType.SEARCH_ALL_MISSING:
        return _searchAllMissing(context);
      case RadarrGlobalSettingsType.UPDATE_LIBRARY:
        return _updateLibrary(context);
      case RadarrGlobalSettingsType.BACKUP_DATABASE:
        return _backupDatabase(context);
      case RadarrGlobalSettingsType.HISTORY:
        return _openHistory(context);
      case RadarrGlobalSettingsType.MANUAL_IMPORT:
        return _openManualImport(context);
      case RadarrGlobalSettingsType.SYSTEM_STATUS:
        return _openSystemStatus(context);
      case RadarrGlobalSettingsType.TAGS:
        return _openTags(context);
    }
  }

  Future<void> _webGUI(BuildContext context) async {
    context.read<RadarrState>().host.openLink();
  }

  Future<void> _backupDatabase(BuildContext context) async {
    RadarrAPIHelper().backupDatabase(context: context);
  }

  Future<void> _searchAllMissing(BuildContext context) async {
    bool result = await RadarrDialogs().searchAllMissingMovies(context);
    if (result) RadarrAPIHelper().missingMovieSearch(context: context);
  }

  Future<void> _runRssSync(BuildContext context) async {
    RadarrAPIHelper().runRSSSync(context: context);
  }

  Future<void> _updateLibrary(BuildContext context) async {
    RadarrAPIHelper().updateLibrary(context: context);
  }

  Future<void> _openHistory(BuildContext context) async {
    RadarrRoutes.HISTORY.go();
  }

  Future<void> _openManualImport(BuildContext context) async {
    RadarrRoutes.MANUAL_IMPORT.go();
  }

  Future<void> _openSystemStatus(BuildContext context) async {
    RadarrRoutes.SYSTEM_STATUS.go();
  }

  Future<void> _openTags(BuildContext context) async {
    RadarrRoutes.TAGS.go();
  }
}
