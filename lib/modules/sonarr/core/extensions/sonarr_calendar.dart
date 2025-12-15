import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrCalendarExtension on SonarrCalendar {
  String get zagAirTime {
    if (this.airDateUtc != null)
      return ZagreusDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(this.airDateUtc!.toLocal())
          : DateFormat('hh:mm\na').format(this.airDateUtc!.toLocal());
    return ZagUI.TEXT_EMDASH;
  }

  bool get zagHasAired {
    if (this.airDateUtc != null)
      return DateTime.now().isAfter(this.airDateUtc!.toLocal());
    return false;
  }
}
