import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrQueueRecordExtension on SonarrQueueRecord {
  Tuple3<String, IconData, Color> zagStatusParameters({
    bool canBeWhite = true,
  }) {
    SonarrQueueStatus? _status = this.status;
    SonarrTrackedDownloadStatus? _tStatus = this.trackedDownloadStatus;
    SonarrTrackedDownloadState? _tState = this.trackedDownloadState;

    String _title = 'sonarr.Downloading'.tr();
    IconData _icon = Icons.cloud_download_rounded;
    Color _color = canBeWhite ? Colors.white : ZagColours.blueGrey;

    // Paused
    if (_status == SonarrQueueStatus.PAUSED) {
      _icon = Icons.pause_rounded;
      _title = 'sonarr.Paused'.tr();
    }

    // Queued
    if (_status == SonarrQueueStatus.QUEUED) {
      _icon = Icons.cloud_rounded;
      _title = 'sonarr.Queued'.tr();
    }

    // Complete
    if (_status == SonarrQueueStatus.COMPLETED) {
      _title = 'sonarr.Downloaded'.tr();
      _icon = Icons.file_download_rounded;

      if (_tState == SonarrTrackedDownloadState.IMPORT_PENDING) {
        _title = 'sonarr.DownloadedWaitingToImport'.tr();
        _color = ZagColours.purple;
      }
      if (_tState == SonarrTrackedDownloadState.IMPORTING) {
        _title = 'sonarr.DownloadedImporting'.tr();
        _color = ZagColours.purple;
      }
      if (_tState == SonarrTrackedDownloadState.FAILED_PENDING) {
        _title = 'sonarr.DownloadedWaitingToProcess'.tr();
        _color = ZagColours.red;
      }
    }

    if (_tStatus == SonarrTrackedDownloadStatus.WARNING) {
      _color = ZagColours.orange;
    }

    // Delay
    if (_status == SonarrQueueStatus.DELAY) {
      _title = 'sonarr.Pending'.tr();
      _icon = Icons.schedule_rounded;
    }

    // Download Client Unavailable
    if (_status == SonarrQueueStatus.DOWNLOAD_CLIENT_UNAVAILABLE) {
      _title = 'sonarr.PendingWithMessage'.tr(
        args: ['sonarr.DownloadClientUnavailable'.tr()],
      );
      _icon = Icons.schedule_rounded;
      _color = ZagColours.orange;
    }

    // Failed
    if (_status == SonarrQueueStatus.FAILED) {
      _title = 'sonarr.DownloadFailed'.tr();
      _icon = Icons.cloud_download_rounded;
      _color = ZagColours.red;
    }

    // Warning
    if (_status == SonarrQueueStatus.WARNING) {
      _title = 'sonarr.DownloadWarningWithMessage'.tr(args: [
        'sonarr.CheckDownloadClient'.tr(),
      ]);
      _icon = Icons.cloud_download_rounded;
      _color = ZagColours.orange;
    }

    // Error
    if (_tStatus == SonarrTrackedDownloadStatus.ERROR) {
      if (_status == SonarrQueueStatus.COMPLETED) {
        _title = 'sonarr.ImportFailed'.tr();
        _icon = Icons.file_download_rounded;
        _color = ZagColours.red;
      } else {
        _title = 'sonarr.DownloadFailed'.tr();
        _icon = Icons.cloud_download_rounded;
        _color = ZagColours.red;
      }
    }

    return Tuple3(_title, _icon, _color);
  }

  String zagPercentage() {
    if (this.sizeleft == null || this.size == null || this.size == 0)
      return '0%';
    double sizeFetched = this.size! - this.sizeleft!;
    int percentage = ((sizeFetched / this.size!) * 100).round();
    return '$percentage%';
  }

  String zagTimeLeft() {
    return this.timeleft ?? ZagUI.TEXT_EMDASH;
  }
}
