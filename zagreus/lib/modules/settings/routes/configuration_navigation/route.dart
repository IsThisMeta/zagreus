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
            text: 'Allow horizontal swiping between tabs.',
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
      builder: (context, _) => ZagBlock(
        title: 'Speed Cube',
        body: const [
          TextSpan(text: 'Show the floating module switcher button with long-press bounce-back.'),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  Widget _downloadsDrawer() {
    const db = ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Downloads Drawer',
        body: const [
          TextSpan(
            text: 'Access queues from the right edge.',
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  Widget _legacyModulesTabToggle() {
    if (!ZagreusPro.isEnabled) return const SizedBox.shrink();
    const db = ZagreusDatabase.SHOW_LEGACY_MODULES_TAB;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Show Modules Tab',
        body: const [
          TextSpan(
            text: 'Restores Modules tab in Dashboard.',
          ),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            if (!value &&
                ZagreusDatabase.DISCOVER_DEFAULT_TAB.read() == 'modules') {
              ZagreusDatabase.DISCOVER_DEFAULT_TAB.update('movies');
            } else if (value) {
              ZagreusDatabase.DISCOVER_DEFAULT_TAB.update('modules');
            }
          },
        ),
      ),
    );
  }
}
