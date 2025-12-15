import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrQueueRecord on RadarrQueueRecord {
  String get zagQuality {
    return this.quality?.quality?.name ?? ZagUI.TEXT_EMDASH;
  }

  String get zagLanguage {
    if ((this.languages?.length ?? 0) == 0) return ZagUI.TEXT_EMDASH;
    if (this.languages!.length == 1)
      return this.languages![0].name ?? ZagUI.TEXT_EMDASH;
    return 'Multi-Language';
  }

  String zagMovieTitle(RadarrMovie movie) {
    String title = movie.title ?? ZagUI.TEXT_EMDASH;
    String year = movie.zagYear;
    return '$title ($year)';
  }

  String? get zagDownloadClient {
    if ((this.downloadClient ?? '').isNotEmpty) return this.downloadClient;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagIndexer {
    if ((this.indexer ?? '').isNotEmpty) return this.indexer;
    return ZagUI.TEXT_EMDASH;
  }

  Color get zagProtocolColor {
    if (this.protocol == RadarrProtocol.USENET) return ZagColours.currentAccent;
    return ZagColours.blue;
  }

  int get zagPercentageComplete {
    if (this.sizeLeft == null || this.size == null || this.size == 0) return 0;
    double sizeFetched = this.size! - this.sizeLeft!;
    return ((sizeFetched / this.size!) * 100).round();
  }

  IconData get zagStatusIcon {
    switch (this.status) {
      case RadarrQueueRecordStatus.DELAY:
        return Icons.access_time_rounded;
      case RadarrQueueRecordStatus.DOWNLOAD_CLIENT_UNAVAILABLE:
        return Icons.access_time_rounded;
      case RadarrQueueRecordStatus.FAILED:
        return Icons.cloud_download_rounded;
      case RadarrQueueRecordStatus.PAUSED:
        return Icons.pause_rounded;
      case RadarrQueueRecordStatus.QUEUED:
        return Icons.cloud_rounded;
      case RadarrQueueRecordStatus.WARNING:
        return Icons.cloud_download_rounded;
      case RadarrQueueRecordStatus.COMPLETED:
        return Icons.download_done_rounded;
      case RadarrQueueRecordStatus.DOWNLOADING:
        return Icons.cloud_download_rounded;
      default:
        return Icons.cloud_download_rounded;
    }
  }

  Color get zagStatusColor {
    Color color = Colors.white;
    if (this.status == RadarrQueueRecordStatus.COMPLETED)
      switch (this.trackedDownloadState) {
        case RadarrTrackedDownloadState.FAILED_PENDING:
          color = ZagColours.red;
          break;
        case RadarrTrackedDownloadState.IMPORT_PENDING:
          color = ZagColours.purple;
          break;
        case RadarrTrackedDownloadState.IMPORTING:
          color = ZagColours.purple;
          break;
        default:
          break;
      }
    if (this.trackedDownloadStatus == RadarrTrackedDownloadStatus.WARNING)
      color = ZagColours.orange;
    switch (this.status) {
      case RadarrQueueRecordStatus.DOWNLOAD_CLIENT_UNAVAILABLE:
        color = ZagColours.orange;
        break;
      case RadarrQueueRecordStatus.FAILED:
        color = ZagColours.red;
        break;
      case RadarrQueueRecordStatus.WARNING:
        color = ZagColours.orange;
        break;
      default:
        break;
    }
    if (this.trackedDownloadStatus == RadarrTrackedDownloadStatus.ERROR)
      color = ZagColours.red;
    return color;
  }
}
