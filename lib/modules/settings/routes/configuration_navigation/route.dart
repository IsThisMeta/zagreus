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
      title: 'settings.Navigation'.tr(),
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _horizontalSwipeToggle(),
        _downloadsButton(),
        _calendarTabToggle(),
        _legacyModulesTabToggle(),
        _speedCube(),
      ],
    );
  }

  Widget _downloadsButton() {
    const db = ZagreusDatabase.DOWNLOADS_BUTTON_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.QueueButton'.tr(),
        body: [
          TextSpan(
            text: 'settings.QueueButtonDescription'.tr(),
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  Widget _horizontalSwipeToggle() {
    const db = ZagreusDatabase.NAVIGATION_DISABLE_HORIZONTAL_SWIPE;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.SwipeBetweenTabs'.tr(),
        body: [
          TextSpan(
            text: 'settings.SwipeBetweenTabsDescription'.tr(),
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
          title: 'settings.SpeedCube'.tr(),
          body: [
            TextSpan(text: 'settings.SpeedCubeDescription'.tr()),
          ],
          trailing: ZagSwitch(
            value: db.read(),
            onChanged: isPro ? db.update : null,
          ),
          onTap: isPro
              ? null
              : () => _showProUpgradeToast('settings.SpeedCube'.tr()),
        );
      },
    );
  }

  Widget _legacyModulesTabToggle() {
    if (!ZagreusPro.isEnabled) return const SizedBox.shrink();
    const db = ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.ShowModulesTab'.tr(),
        body: [
          TextSpan(
            text: 'settings.ShowModulesTabDescription'.tr(),
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            final currentDefault =
                ZagreusDatabase.DISCOVER_DEFAULT_TAB.read();
            if (value) {
              if (currentDefault == null || currentDefault == 'movies') {
                ZagreusDatabase.DISCOVER_DEFAULT_TAB.update('modules');
              }
            } else if (currentDefault == 'modules') {
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
        title: 'settings.ShowCalendarTab'.tr(),
        body: [
          TextSpan(
            text: 'settings.ShowCalendarTabDescription'.tr(),
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  void _showProUpgradeToast(String featureName) {
    showZagInfoSnackBar(
      title: 'settings.ZagreusProRequiredTitle'.tr(),
      message: 'settings.ZagreusProRequiredMessage'.tr(
        args: [featureName],
      ),
    );
  }
}
