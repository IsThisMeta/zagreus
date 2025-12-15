import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_size.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zagreus/modules/dashboard/core/api/api.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/system/state.dart';
import 'package:zagreus/vendor.dart';

class DashboardState extends ZagModuleState {
  DashboardState() {
    reset();
  }

  @override
  void reset() {
    resetToday();
    resetAPI();
    resetUpcoming();
  }

  CalendarStartingType _calendarType =
      DashboardDatabase.CALENDAR_STARTING_TYPE.read();
  CalendarStartingType get calendarType => _calendarType;
  set calendarType(CalendarStartingType calendarStartingType) {
    _calendarType = calendarStartingType;
    notifyListeners();
  }

  CalendarFormat _calendarFormat =
      DashboardDatabase.CALENDAR_STARTING_SIZE.read().data;
  CalendarFormat get calendarFormat => _calendarFormat;
  set calendarFormat(CalendarFormat calendarFormat) {
    _calendarFormat = calendarFormat;
    notifyListeners();
  }

  API? _api;
  API? get api => _api;
  void resetAPI() {
    _api = API();
    notifyListeners();
  }

  DateTime _today = DateTime.now().floor();
  DateTime get today => _today;
  void resetToday() {
    _today = DateTime.now().floor();
    notifyListeners();
  }

  Future<Map<DateTime, List<CalendarData>>>? _upcoming;
  Future<Map<DateTime, List<CalendarData>>>? get upcoming => _upcoming;
  void resetUpcoming() {
    if (_api != null) _upcoming = _api!.getUpcoming(DateTime.now());
    notifyListeners();
  }

  DateTime _selected = DateTime.now().floor();
  DateTime get selected => _selected;
  set selected(DateTime selected) {
    _selected = selected;
    notifyListeners();
  }
}
