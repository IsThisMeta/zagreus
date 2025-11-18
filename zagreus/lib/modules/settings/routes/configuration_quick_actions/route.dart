import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/system/quick_actions/quick_actions.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationQuickActionsRoute extends StatefulWidget {
  const ConfigurationQuickActionsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationQuickActionsRoute> createState() => _State();
}

class _State extends State<ConfigurationQuickActionsRoute>
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
      title: 'settings.QuickActions'.tr(),
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        SettingsBanners.QUICK_ACTIONS_SUPPORT.banner(),
        _actionTile(
          ZagModule.LIDARR.title,
          ZagreusDatabase.QUICK_ACTIONS_LIDARR,
        ),
        _actionTile(
          ZagModule.NZBGET.title,
          ZagreusDatabase.QUICK_ACTIONS_NZBGET,
        ),
        if (ZagModule.OVERSEERR.featureFlag && ZagreusPro.isEnabled)
          _actionTile(
            ZagModule.OVERSEERR.title,
            ZagreusDatabase.QUICK_ACTIONS_OVERSEERR,
          ),
        _actionTile(
          ZagModule.RADARR.title,
          ZagreusDatabase.QUICK_ACTIONS_RADARR,
        ),
        _actionTile(
          ZagModule.SABNZBD.title,
          ZagreusDatabase.QUICK_ACTIONS_SABNZBD,
        ),
        _actionTile(
          ZagModule.SEARCH.title,
          ZagreusDatabase.QUICK_ACTIONS_SEARCH,
        ),
        _actionTile(
          ZagModule.SONARR.title,
          ZagreusDatabase.QUICK_ACTIONS_SONARR,
        ),
        _actionTile(
          ZagModule.TAUTULLI.title,
          ZagreusDatabase.QUICK_ACTIONS_TAUTULLI,
        ),
      ],
    );
  }

  Widget _actionTile(String title, ZagreusDatabase action) {
    return ZagBlock(
      title: title,
      trailing: ZagBox.zagreus.listenableBuilder(
        selectKeys: [action.key],
        builder: (context, _) => ZagSwitch(
          value: action.read(),
          onChanged: (value) {
            action.update(value);
            if (ZagQuickActions.isSupported)
              ZagQuickActions().setActionItems();
          },
        ),
      ),
    );
  }
}
