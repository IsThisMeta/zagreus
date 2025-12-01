import 'package:zagreus/database/table.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_day.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_size.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zagreus/vendor.dart';

enum DashboardDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  CALENDAR_STARTING_DAY<CalendarStartingDay>(CalendarStartingDay.MONDAY),
  CALENDAR_STARTING_SIZE<CalendarStartingSize>(CalendarStartingSize.TWO_WEEKS),
  CALENDAR_STARTING_TYPE<CalendarStartingType>(CalendarStartingType.CALENDAR),
  CALENDAR_ENABLE_LIDARR<bool>(true),
  CALENDAR_ENABLE_RADARR<bool>(true),
  CALENDAR_ENABLE_SONARR<bool>(true),
  CALENDAR_INCLUDE_UNMONITORED_SONARR<bool>(false),
  CALENDAR_DAYS_PAST<int>(14),
  CALENDAR_DAYS_FUTURE<int>(14);

  @override
  ZagTable get table => ZagTable.dashboard;

  @override
  final T fallback;

  const DashboardDatabase(this.fallback);

  @override
  void register() {
    Hive.registerAdapter(CalendarStartingDayAdapter());
    Hive.registerAdapter(CalendarStartingSizeAdapter());
    Hive.registerAdapter(CalendarStartingTypeAdapter());
  }

  @override
  dynamic export() {
    DashboardDatabase db = this;
    switch (db) {
      case DashboardDatabase.CALENDAR_STARTING_DAY:
        return DashboardDatabase.CALENDAR_STARTING_DAY.read().key;
      case DashboardDatabase.CALENDAR_STARTING_SIZE:
        return DashboardDatabase.CALENDAR_STARTING_SIZE.read().key;
      case DashboardDatabase.CALENDAR_STARTING_TYPE:
        return DashboardDatabase.CALENDAR_STARTING_TYPE.read().key;
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    DashboardDatabase db = this;
    dynamic result;

    switch (db) {
      case DashboardDatabase.CALENDAR_STARTING_DAY:
        result = CalendarStartingDay.MONDAY.fromKey(value.toString());
        break;
      case DashboardDatabase.CALENDAR_STARTING_SIZE:
        result = CalendarStartingSize.TWO_WEEKS.fromKey(value.toString());
        break;
      case DashboardDatabase.CALENDAR_STARTING_TYPE:
        result = CalendarStartingType.CALENDAR.fromKey(value.toString());
        break;
      default:
        result = value;
        break;
    }

    return super.import(result);
  }
}
