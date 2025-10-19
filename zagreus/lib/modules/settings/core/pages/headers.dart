import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/modules/server.dart';

class SettingsHeaderRoute extends StatefulWidget {
  final ZagModule module;

  const SettingsHeaderRoute({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SettingsHeaderRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
            text: 'settings.AddHeader'.tr(),
            icon: Icons.add_rounded,
            onTap: () async {
              await HeaderUtility().addHeader(context, headers: _headers());
              _resetState();
            }),
      ],
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.CustomHeaders'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          if ((_headers()).isEmpty) _noHeadersFound(),
          ..._headerList(),
        ],
      ),
    );
  }

  Widget _noHeadersFound() =>
      ZagMessage.inList(text: 'settings.NoHeadersAdded'.tr());

  List<ZagBlock> _headerList() {
    final headers = _headers();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZagBlock>((key) => _headerBlock(key, headers[key]))
        .toList();
  }

  ZagBlock _headerBlock(String key, String? value) {
    return ZagBlock(
      title: key,
      body: [TextSpan(text: value)],
      trailing: ZagIconButton(
          icon: ZagIcons.DELETE,
          color: ZagColours.red,
          onPressed: () async {
            await HeaderUtility().deleteHeader(
              context,
              key: key,
              headers: _headers(),
            );
            _resetState();
          }),
    );
  }

  Map<String, String> _headers() {
    switch (widget.module) {
      case ZagModule.DASHBOARD:
        throw Exception('Dashboard does not have a headers page');
      case ZagModule.EXTERNAL_MODULES:
        throw Exception('External modules do not have a headers page');
      case ZagModule.LIDARR:
        return ZagProfile.current.lidarrHeaders;
      case ZagModule.RADARR:
        return ZagProfile.current.radarrHeaders;
      case ZagModule.SONARR:
        return ZagProfile.current.sonarrHeaders;
      case ZagModule.SABNZBD:
        return ZagProfile.current.sabnzbdHeaders;
      case ZagModule.NZBGET:
        return ZagProfile.current.nzbgetHeaders;
      case ZagModule.SEARCH:
        throw Exception('Search does not have a headers page');
      case ZagModule.SETTINGS:
        throw Exception('Settings does not have a headers page');
      case ZagModule.WAKE_ON_LAN:
        throw Exception('Wake on LAN does not have a headers page');
      case ZagModule.OVERSEERR:
        throw Exception('Overseerr does not have a headers page');
      case ZagModule.TAUTULLI:
        return ZagProfile.current.tautulliHeaders;
      case ZagModule.SERVER:
        return ZagProfile.current.serverHeaders;
      case ZagModule.DISCOVER:
        throw Exception('Discover does not have a headers page');
    }
  }

  Future<void> _resetState() async {
    switch (widget.module) {
      case ZagModule.DASHBOARD:
        throw Exception('Dashboard does not have a global state');
      case ZagModule.EXTERNAL_MODULES:
        throw Exception('External modules do not have a global state');
      case ZagModule.LIDARR:
        return;
      case ZagModule.RADARR:
        return context.read<RadarrState>().reset();
      case ZagModule.SONARR:
        return context.read<SonarrState>().reset();
      case ZagModule.SABNZBD:
        return;
      case ZagModule.NZBGET:
        return;
      case ZagModule.SEARCH:
        throw Exception('Search does not have a global state');
      case ZagModule.SETTINGS:
        throw Exception('Settings does not have a global state');
      case ZagModule.WAKE_ON_LAN:
        throw Exception('Wake on LAN does not have a global state');
      case ZagModule.TAUTULLI:
        return context.read<TautulliState>().reset();
      case ZagModule.SERVER:
        return context.read<ServerState>().reset();
      case ZagModule.OVERSEERR:
        return;
      case ZagModule.DISCOVER:
        throw Exception('Discover does not have a global state');
    }
  }
}
