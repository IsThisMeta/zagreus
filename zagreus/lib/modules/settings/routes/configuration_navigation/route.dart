import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/system/session_state.dart';
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
        _moduleTabMemoryToggle(),
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
          TextSpan(text: 'Show the floating module switcher button.'),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  Widget _moduleTabMemoryToggle() {
    const cubeDb = ZagreusDatabase.SPEED_CUBE_ENABLED;
    const memoryDb = ZagreusDatabase.MODULE_TAB_MEMORY_ENABLED;

    return cubeDb.listenableBuilder(
      builder: (context, _) {
        final cubeEnabled = cubeDb.read();
        return memoryDb.listenableBuilder(
          builder: (context, _) => ZagBlock(
            title: 'Remember Module Page',
            body: const [
              TextSpan(
                text: 'Jump back to the last page you viewed.',
              ),
            ],
            trailing: ZagSwitch(
              value: cubeEnabled ? memoryDb.read() : false,
              onChanged: cubeEnabled
                  ? (value) {
                      memoryDb.update(value);
                      if (!value) {
                        ZagSessionState.instance.clearAllModuleTabPositions();
                      }
                    }
                  : null,
            ),
          ),
        );
      },
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
          onChanged: db.update,
        ),
      ),
    );
  }
}
