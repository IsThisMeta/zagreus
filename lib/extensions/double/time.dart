import 'package:zagreus/core.dart';

extension DoubleAsTimeExtension on double? {
  String asTimeAgo() {
    if (this == null || this! < 0) return ZagUI.TEXT_EMDASH;

    double hours = this!;
    double minutes = (this! * 60);
    double days = (this! / 24);

    if (minutes <= 2) {
      return 'zagreus.JustNow'.tr();
    }

    if (minutes <= 120) {
      return 'zagreus.MinutesAgo'.tr(args: [minutes.round().toString()]);
    }

    if (hours <= 48) {
      return 'zagreus.HoursAgo'.tr(args: [hours.toStringAsFixed(1)]);
    }

    return 'zagreus.DaysAgo'.tr(args: [days.round().toString()]);
  }
}
