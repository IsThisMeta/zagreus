import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

extension DateTimeExtension on DateTime {
  String _formatted(String format) {
    return DateFormat(format, 'en').format(this.toLocal());
  }

  DateTime floor() {
    return DateTime(this.year, this.month, this.day);
  }

  String asTimeOnly() {
    if (ZagreusDatabase.USE_24_HOUR_TIME.read()) return _formatted('Hm');
    return _formatted('jm');
  }

  String asDateOnly({
    shortenMonth = false,
  }) {
    final format = shortenMonth ? 'MMM dd, y' : 'MMMM dd, y';
    return _formatted(format);
  }

  String asDateTime({
    bool showSeconds = true,
    bool shortenMonth = false,
    String? delimiter,
  }) {
    final format = StringBuffer(shortenMonth ? 'MMM dd, y' : 'MMMM dd, y');
    format.write(delimiter ?? ZagUI.TEXT_BULLET.pad());
    format.write(ZagreusDatabase.USE_24_HOUR_TIME.read() ? 'HH:mm' : 'hh:mm');
    if (showSeconds) format.write(':ss');
    if (!ZagreusDatabase.USE_24_HOUR_TIME.read()) format.write(' a');

    return _formatted(format.toString());
  }

  String asPoleDate() {
    final year = this.year.toString().padLeft(4, '0');
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String asAge() {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 15) return 'zagreus.JustNow'.tr();

    final days = diff.inDays.abs();
    if (days >= 1) {
      final years = (days / 365).floor();
      if (years == 1) return 'zagreus.OneYearAgo'.tr();
      if (years > 1) return 'zagreus.YearsAgo'.tr(args: [years.toString()]);

      final months = (days / 30).floor();
      if (months == 1) return 'zagreus.OneMonthAgo'.tr();
      if (months > 1) return 'zagreus.MonthsAgo'.tr(args: [months.toString()]);

      if (days == 1) return 'zagreus.OneDayAgo'.tr();
      if (days > 1) return 'zagreus.DaysAgo'.tr(args: [days.toString()]);
    }

    final hours = diff.inHours.abs();
    if (hours == 1) return 'zagreus.OneHourAgo'.tr();
    if (hours > 1) return 'zagreus.HoursAgo'.tr(args: [hours.toString()]);

    final mins = diff.inMinutes.abs();
    if (mins == 1) return 'zagreus.OneMinuteAgo'.tr();
    if (mins > 1) return 'zagreus.MinutesAgo'.tr(args: [mins.toString()]);

    final secs = diff.inSeconds.abs();
    if (secs == 1) return 'zagreus.OneSecondAgo'.tr();
    return 'zagreus.SecondsAgo'.tr(args: [secs.toString()]);
  }

  String asDaysDifference() {
    final diff = DateTime.now().difference(this);
    final days = diff.inDays.abs();
    if (days == 0) return 'zagreus.Today'.tr();

    final years = (days / 365).floor();
    if (years == 1) return 'zagreus.OneYear'.tr();
    if (years > 1) return 'zagreus.Years'.tr(args: [years.toString()]);

    final months = (days / 30).floor();
    if (months == 1) return 'zagreus.OneMonth'.tr();
    if (months > 1) return 'zagreus.Months'.tr(args: [months.toString()]);

    if (days == 1) return 'zagreus.OneDay'.tr();
    return 'zagreus.Days'.tr(args: [days.toString()]);
  }
}
