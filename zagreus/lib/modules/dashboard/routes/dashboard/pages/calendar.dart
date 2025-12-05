import 'package:flutter/material.dart';

import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/modules/dashboard/core/state.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/calendar_view.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/schedule_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _State();
}

class _State extends State<CalendarPage>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<DashboardState>().resetToday();
    context.read<DashboardState>().resetUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: Selector<DashboardState, Future<Map<DateTime, List<CalendarData>>>?>(
        selector: (_, state) => state.upcoming,
        builder: (context, upcomingFuture, _) {
          return FutureBuilder(
            future: upcomingFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<Map<DateTime, List<CalendarData>>> snapshot,
            ) {
              if (snapshot.hasError) {
                ZagLogger().error(
                  'Failed to fetch unified calendar data',
                  snapshot.error,
                  snapshot.stackTrace,
                );
                return ZagMessage.error(onTap: _refreshKey.currentState!.show);
              }

              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final events = snapshot.data!;
                return Selector<DashboardState, CalendarStartingType>(
                  selector: (_, s) => s.calendarType,
                  builder: (context, type, _) {
                    if (type == CalendarStartingType.CALENDAR)
                      return CalendarView(events: events);
                    else
                      return ScheduleView(events: events);
                  },
                );
              }

              return const ZagLoader();
            },
          );
        },
      ),
    );
  }
}
