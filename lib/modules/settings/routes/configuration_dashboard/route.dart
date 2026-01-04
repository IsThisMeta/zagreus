import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationDashboardRoute extends StatefulWidget {
  const ConfigurationDashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDashboardRoute> createState() => _State();
}

class _State extends State<ConfigurationDashboardRoute>
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
      title: 'zagreus.Dashboard'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _calendarSettingsPage(),
        _searchSettingsSection(),
        _defaultPagesPage(),
      ],
    );
  }

  Widget _searchSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagHeader(text: 'settings.Search'.tr()),
        DashboardDatabase.SEARCH_SHOW_LIBRARY_BADGES.listenableBuilder(
          builder: (context, _) {
            final enabled = DashboardDatabase.SEARCH_SHOW_LIBRARY_BADGES.read();
            return ZagBlock(
              title: 'settings.ShowLibraryBadges'.tr(),
              body: [
                TextSpan(
                  text: 'settings.ShowLibraryBadgesDescription'.tr(),
                ),
              ],
              trailing: ZagSwitch(
                value: enabled,
                onChanged: (value) {
                  DashboardDatabase.SEARCH_SHOW_LIBRARY_BADGES.update(value);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_DASHBOARD_DEFAULT_PAGES.go,
    );
  }

  Widget _calendarSettingsPage() {
    return ZagBlock(
      title: 'settings.CalendarSettings'.tr(),
      body: [TextSpan(text: 'settings.CalendarSettingsDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_DASHBOARD_CALENDAR.go,
    );
  }
}
