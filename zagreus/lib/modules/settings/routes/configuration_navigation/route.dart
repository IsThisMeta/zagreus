import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationNavigationRoute extends StatefulWidget {
  const ConfigurationNavigationRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationNavigationRoute> createState() => _State();
}

class _State extends State<ConfigurationNavigationRoute>
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
      scrollControllers: [scrollController],
      title: 'Navigation',
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _horizontalSwipeToggle(),
        _downloadsDrawer(),
        _legacyModulesTabToggle(),
        _calendarTabToggle(),
        _speedCube(),
      ],
    );
  }

  Widget _horizontalSwipeToggle() {
    const db = ZagreusDatabase.NAVIGATION_DISABLE_HORIZONTAL_SWIPE;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Swipe Between Tabs',
        body: const [
          TextSpan(
            text: 'Allow horizontal swiping between tabs',
          ),
        ],
        trailing: ZagSwitch(
          value: !db.read(),
          onChanged: (value) => db.update(!value),
        ),
      ),
    );
  }

  Widget _speedCube() {
    const db = ZagreusDatabase.SPEED_CUBE_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) {
        final isPro = ZagreusPro.isEnabled;
        return ZagBlock(
          title: 'Speed Cube',
          body: const [
            TextSpan(text: 'Show floating action cube'),
          ],
          trailing: ZagSwitch(
            value: db.read(),
            onChanged: isPro ? db.update : null,
          ),
          onTap: isPro ? null : () => _showSpeedCubeProUpgradeToast(),
        );
      },
    );
  }

  Widget _downloadsDrawer() {
    const db = ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) {
        final isPro = ZagreusPro.isEnabled;
        return ZagBlock(
          title: 'Queue Drawer',
          body: const [
            TextSpan(
              text: 'Access queues from the right edge',
            ),
          ],
          trailing: ZagSwitch(
            value: isPro && db.read(),
            onChanged: isPro ? db.update : null,
          ),
          onTap: isPro ? null : () => _showProUpgradeToast(),
        );
      },
    );
  }

  Widget _legacyModulesTabToggle() {
    if (!ZagreusPro.isEnabled) return const SizedBox.shrink();
    return Column(
      children: [
        _dashboardModulesTabToggle(),
        _discoverModulesTabToggle(),
      ],
    );
  }

  Widget _dashboardModulesTabToggle() {
    const db = ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Show Modules Tab (Dashboard)',
        body: const [
          TextSpan(
            text: 'Shows Modules tab in Dashboard',
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  Widget _discoverModulesTabToggle() {
    const db = ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Show Modules Tab (Discover)',
        body: const [
          TextSpan(
            text: 'Shows Modules tab in Discover',
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            if (!value &&
                ZagreusDatabase.DISCOVER_DEFAULT_TAB.read() == 'modules') {
              ZagreusDatabase.DISCOVER_DEFAULT_TAB.update('movies');
            }
          },
        ),
      ),
    );
  }

  Widget _calendarTabToggle() {
    if (!ZagreusPro.isEnabled) return const SizedBox.shrink();
    const db = ZagreusDatabase.SHOW_CALENDAR_TAB;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Hide Calendar Tab',
        body: const [
          TextSpan(
            text: 'Hides Calendar tab in Dashboard',
          ),
        ],
        trailing: ZagSwitch(
          value: !db.read(),
          onChanged: (value) => db.update(!value),
        ),
      ),
    );
  }

  void _showProUpgradeToast() {
    showZagInfoSnackBar(
      title: 'Zagreus Pro required',
      message: 'Upgrade to Zagreus Pro to use Queue Drawer.',
    );
  }

  void _showSpeedCubeProUpgradeToast() {
    showZagInfoSnackBar(
      title: 'Zagreus Pro required',
      message: 'Upgrade to Zagreus Pro to use Speed Cube.',
    );
  }
}
