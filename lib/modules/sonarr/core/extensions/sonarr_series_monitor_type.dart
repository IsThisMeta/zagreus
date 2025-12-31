import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrSeriesMonitorTypeExtension on SonarrSeriesMonitorType {
  String get zagName {
    switch (this) {
      case SonarrSeriesMonitorType.ALL:
        return 'sonarr.MonitorAllEpisodes'.tr();
      case SonarrSeriesMonitorType.FUTURE:
        return 'sonarr.MonitorFutureEpisodes'.tr();
      case SonarrSeriesMonitorType.MISSING:
        return 'sonarr.MonitorMissingEpisodes'.tr();
      case SonarrSeriesMonitorType.EXISTING:
        return 'sonarr.MonitorExistingEpisodes'.tr();
      case SonarrSeriesMonitorType.PILOT:
        return 'sonarr.MonitorPilotEpisode'.tr();
      case SonarrSeriesMonitorType.FIRST_SEASON:
        return 'sonarr.MonitorFirstSeason'.tr();
      case SonarrSeriesMonitorType.LATEST_SEASON:
        return 'sonarr.MonitorLatestSeason'.tr();
      case SonarrSeriesMonitorType.NONE:
        return 'sonarr.MonitorNone'.tr();
      default:
        return 'zagreus.Unknown'.tr();
    }
  }
}
