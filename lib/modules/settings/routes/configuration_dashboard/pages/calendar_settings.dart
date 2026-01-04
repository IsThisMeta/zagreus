import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/vendor.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_day.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_size.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zagreus/modules/dashboard/core/dialogs.dart';
import 'package:zagreus/modules/settings/core/dialogs.dart';

class ConfigurationDashboardCalendarRoute extends StatefulWidget {
  const ConfigurationDashboardCalendarRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDashboardCalendarRoute> createState() => _State();
}

class _State extends State<ConfigurationDashboardCalendarRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.CalendarSettings'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _futureDays(),
        _pastDays(),
        ZagDivider(),
        _startingDay(),
        _startingSize(),
        _startingView(),
        ZagDivider(),
        _modulesLidarr(),
        _modulesRadarr(),
        _modulesSonarr(),
        _sonarrUnmonitoredToggle(),
      ],
    );
  }

  Widget _pastDays() {
    const _db = DashboardDatabase.CALENDAR_DAYS_PAST;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.PastDays'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'settings.DaysOne'.tr()
                : 'settings.DaysCount'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, int> result =
              await DashboardDialogs().setPastDays(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  Widget _futureDays() {
    const _db = DashboardDatabase.CALENDAR_DAYS_FUTURE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.FutureDays'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'settings.DaysOne'.tr()
                : 'settings.DaysCount'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, int> result =
              await DashboardDialogs().setFutureDays(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  Widget _modulesLidarr() {
    const _db = DashboardDatabase.CALENDAR_ENABLE_LIDARR;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: ZagModule.LIDARR.title,
        body: [
          TextSpan(
            text: 'settings.ShowCalendarEntries'.tr(
              args: [ZagModule.LIDARR.title],
            ),
          )
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _modulesRadarr() {
    const _db = DashboardDatabase.CALENDAR_ENABLE_RADARR;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: ZagModule.RADARR.title,
        body: [
          TextSpan(
            text: 'settings.ShowCalendarEntries'.tr(
              args: [ZagModule.RADARR.title],
            ),
          )
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _modulesSonarr() {
    const _db = DashboardDatabase.CALENDAR_ENABLE_SONARR;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: ZagModule.SONARR.title,
        body: [
          TextSpan(
            text: 'settings.ShowCalendarEntries'.tr(
              args: [ZagModule.SONARR.title],
            ),
          )
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _sonarrUnmonitoredToggle() {
    const _db = DashboardDatabase.CALENDAR_INCLUDE_UNMONITORED_SONARR;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.IncludeUnmonitored'.tr(),
        body: [
          TextSpan(text: 'settings.IncludeUnmonitoredDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _startingView() {
    const _db = DashboardDatabase.CALENDAR_STARTING_TYPE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.StartingView'.tr(),
        body: [
          TextSpan(text: _db.read().name),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, CalendarStartingType?> _values =
              await SettingsDialogs().editCalendarStartingView(context);
          if (_values.item1) _db.update(_values.item2!);
        },
      ),
    );
  }

  Widget _startingDay() {
    const _db = DashboardDatabase.CALENDAR_STARTING_DAY;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.StartingDay'.tr(),
        body: [
          TextSpan(text: _db.read().name),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, CalendarStartingDay?> results =
              await SettingsDialogs().editCalendarStartingDay(context);
          if (results.item1) _db.update(results.item2!);
        },
      ),
    );
  }

  Widget _startingSize() {
    const _db = DashboardDatabase.CALENDAR_STARTING_SIZE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.StartingSize'.tr(),
        body: [
          TextSpan(text: _db.read().name),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, CalendarStartingSize?> _values =
              await SettingsDialogs().editCalendarStartingSize(context);
          if (_values.item1) _db.update(_values.item2!);
        },
      ),
    );
  }
}
