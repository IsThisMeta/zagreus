import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrQueueStatusExtension on SonarrQueueStatus {
  String zagStatus() {
    switch (this) {
      case SonarrQueueStatus.DOWNLOADING:
        return 'sonarr.Downloading'.tr();
      case SonarrQueueStatus.PAUSED:
        return 'sonarr.Paused'.tr();
      case SonarrQueueStatus.QUEUED:
        return 'sonarr.Queued'.tr();
      case SonarrQueueStatus.COMPLETED:
        return 'sonarr.Downloaded'.tr();
      case SonarrQueueStatus.DELAY:
        return 'sonarr.Pending'.tr();
      case SonarrQueueStatus.DOWNLOAD_CLIENT_UNAVAILABLE:
        return 'sonarr.DownloadClientUnavailable'.tr();
      case SonarrQueueStatus.FAILED:
        return 'sonarr.DownloadFailed'.tr();
      case SonarrQueueStatus.WARNING:
        return 'sonarr.DownloadWarning'.tr();
    }
  }
}
