import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrSeriesMonitorTypeExtension on SonarrSeriesMonitorType {
  String get zagName {
    switch (this) {
      case SonarrSeriesMonitorType.ALL:
        return 'All Episodes';
      case SonarrSeriesMonitorType.FUTURE:
        return 'Future Episodes';
      case SonarrSeriesMonitorType.MISSING:
        return 'Missing Episodes';
      case SonarrSeriesMonitorType.EXISTING:
        return 'Existing Episodes';
      case SonarrSeriesMonitorType.PILOT:
        return 'Pilot Episode';
      case SonarrSeriesMonitorType.FIRST_SEASON:
        return 'Only First Season';
      case SonarrSeriesMonitorType.LATEST_SEASON:
        return 'Only Latest Season';
      case SonarrSeriesMonitorType.NONE:
        return 'None';
      default:
        return 'zagreus.Unknown'.tr();
    }
  }
}
