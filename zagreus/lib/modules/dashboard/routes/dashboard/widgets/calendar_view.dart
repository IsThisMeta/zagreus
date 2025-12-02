import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_day.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/modules/dashboard/core/api/data/lidarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/radarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/sonarr.dart';
import 'package:zagreus/modules/dashboard/core/state.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/content_block.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

class CalendarView extends StatefulWidget {
  final Map<DateTime, List<CalendarData>> events;

  const CalendarView({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _State();
}

class _State extends State<CalendarView> {
  final double _calendarBulletSize = 8.0;
  late final TextStyle dayStyle = _getTextStyle(ZagColours.white);
  late final TextStyle outsideStyle = _getTextStyle(ZagColours.white70);
  late final TextStyle unavailableStyle = _getTextStyle(ZagColours.white10);
  late final TextStyle weekdayStyle = _getTextStyle(ZagColours.currentAccent);

  TextStyle _getTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      fontSize: ZagUI.FONT_SIZE_H3,
    );
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    HapticFeedback.selectionClick();
    context.read<DashboardState>().selected = selected.floor();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        children: [
          _calendar(),
          ZagDivider(),
          _calendarList(),
        ],
      ),
      padding: EdgeInsets.only(top: ZagUI.MARGIN_H_DEFAULT_V_HALF.top),
    );
  }

  Widget? _markerBuilder(
    BuildContext context,
    DateTime date,
    List<dynamic> events,
  ) {
    Color color;
    int missingCount = _countMissingContent(date, events);
    switch (missingCount) {
      case -100:
        color = Colors.transparent;
        break;
      case -1:
        color = ZagColours.blueGrey;
        break;
      case 0:
        color = ZagColours.currentAccent;
        break;
      case 1:
        color = ZagColours.orange;
        break;
      case 2:
        color = ZagColours.orange;
        break;
      default:
        color = ZagColours.red;
        break;
    }
    return PositionedDirectional(
      bottom: 3.0,
      child: Container(
        width: _calendarBulletSize,
        height: _calendarBulletSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _calendar() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        DashboardDatabase.CALENDAR_STARTING_DAY,
        DashboardDatabase.CALENDAR_STARTING_SIZE,
      ],
      builder: (context, _) {
        DateTime firstDay = context.watch<DashboardState>().today.subtract(
              Duration(days: DashboardDatabase.CALENDAR_DAYS_PAST.read()),
            );
        DateTime lastDay = context.watch<DashboardState>().today.add(
              Duration(days: DashboardDatabase.CALENDAR_DAYS_FUTURE.read()),
            );
        return SafeArea(
          child: ZagCard(
            context: context,
            child: Padding(
              child: TableCalendar(
                calendarBuilders: CalendarBuilders(
                  markerBuilder: _markerBuilder,
                ),
                rowHeight: 48.0,
                rangeSelectionMode: RangeSelectionMode.disabled,
                focusedDay: context.watch<DashboardState>().selected,
                firstDay: firstDay,
                lastDay: lastDay,
                //events: widget.events,
                headerVisible: true,
                headerStyle: const HeaderStyle(
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    formatButtonVisible: false,
                    headerPadding: ZagUI.MARGIN_DEFAULT_VERTICAL,
                    titleTextStyle: TextStyle(
                      fontSize: ZagUI.FONT_SIZE_H2,
                      fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                    )),
                startingDayOfWeek:
                    DashboardDatabase.CALENDAR_STARTING_DAY.read().data,
                selectedDayPredicate: (date) {
                  return date.floor() ==
                      context.read<DashboardState>().selected;
                },
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  isTodayHighlighted: true,
                  outsideDaysVisible: false,
                  weekendTextStyle: dayStyle,
                  defaultTextStyle: dayStyle,
                  disabledTextStyle: unavailableStyle,
                  outsideTextStyle: outsideStyle,
                  selectedTextStyle: TextStyle(
                    color: ZagColours.currentAccent,
                    fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                  ),
                  todayTextStyle: dayStyle,
                  selectedDecoration: const BoxDecoration(color: Colors.transparent),
                  todayDecoration: const BoxDecoration(color: Colors.transparent),
                  markersAlignment: Alignment.bottomCenter,
                ),
                onFormatChanged: (format) {
                  context.read<DashboardState>().calendarFormat = format;
                },
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: weekdayStyle,
                  weekdayStyle: weekdayStyle,
                ),
                eventLoader: (date) {
                  if (widget.events.isEmpty) return [];
                  return widget.events[date.floor()] ?? [];
                },
                calendarFormat: context.watch<DashboardState>().calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.twoWeeks: '2 Weeks',
                  CalendarFormat.week: 'Week',
                },
                onDaySelected: _onDaySelected,
              ),
              padding: const EdgeInsets.only(
                bottom: ZagUI.DEFAULT_MARGIN_SIZE,
              ),
            ),
          ),
        );
      },
    );
  }

  /// -1: Date is after today (with content)
  /// -100: Event list was empty or null
  int _countMissingContent(DateTime date, List<dynamic> events) {
    DateTime _date = date.floor();
    DateTime _now = DateTime.now().floor();

    if (events.isEmpty) return -100;
    if (_date.isAfter(_now)) return -1;

    int counter = 0;
    for (dynamic event in events) {
      switch (event.runtimeType) {
        case CalendarLidarrData:
          if (!(event as CalendarLidarrData).hasAllFiles) counter++;
          break;
        case CalendarRadarrData:
          final _event = event as CalendarRadarrData;
          if (!_event.monitored) break;
          if (!_event.hasFile) counter++;
          break;
        case CalendarSonarrData:
          CalendarSonarrData _event = event;
          if (!_event.monitored) break;
          // Don't count as missing if currently on air
          if (_event.isOnAir) break;
          DateTime? _airTime = _event.airTimeObject?.toLocal();
          bool _isAired = _airTime?.isBefore(DateTime.now()) ?? false;
          if (!_event.hasFile && _isAired) counter++;
          break;
      }
    }
    return counter;
  }

  Widget _calendarList() {
    final selected = context.read<DashboardState>().selected;
    final events = widget.events[selected.floor()] ?? [];
    if (events.isEmpty) {
      return Expanded(
        child: ZagListView(
          controller: HomeNavigationBar.scrollControllers[1],
          children: [
            ZagMessage.inList(text: 'dashboard.NoNewContent'.tr()),
          ],
          padding:
              MediaQuery.of(context).padding.copyWith(top: 0.0, bottom: 8.0),
        ),
      );
    }

    return Expanded(
      child: ZagListView(
        controller: HomeNavigationBar.scrollControllers[1],
        children: events.map(ContentBlock.new).toList(),
        padding: MediaQuery.of(context).padding.copyWith(top: 0.0, bottom: 8.0),
      ),
    );
  }
}
