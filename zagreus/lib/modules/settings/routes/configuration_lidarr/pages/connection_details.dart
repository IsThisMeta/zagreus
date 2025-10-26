import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationLidarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationLidarrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationLidarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationLidarrConnectionDetailsRoute>
    with ZagScrollControllerMixin {
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

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.ConnectionDetails'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        _testConnection(),
      ],
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBox.zagreus.listenableBuilder(
        selectItems: const [
          ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED,
        ],
        builder: (context, __) {
          final advanced =
              ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
          return ZagListView(
            controller: scrollController,
            children: [
              if (advanced) ZagHeader(text: 'settings.RemoteConnection'.tr()),
              ..._remoteBlocks(),
              if (advanced) ...[
                ZagHeader(text: 'settings.LocalConnection'.tr()),
                ..._localBlocks(),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _remoteBlocks() => [
        _remoteHost(),
        _apiKey(),
        _customHeaders(),
      ];

  List<Widget> _localBlocks() => [
        _localHost(),
        _localSsids(),
      ];

  Widget _remoteHost() {
    String host = ZagProfile.current.lidarrHost;
    return ZagBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (_values.item1) {
          ZagProfile.current.lidarrHost = _values.item2;
          ZagProfile.current.save();
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _localHost() {
    final profile = ZagProfile.current;
    final host = profile.lidarrLocalHost;
    return ZagBlock(
      title: 'settings.LocalHost'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (result.item1) {
          profile.lidarrLocalHost = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid();
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _localSsids() {
    final profile = ZagProfile.current;
    final ssids = profile.lidarrLocalSsids;
    return ZagBlock(
      title: 'settings.TrustedSsids'.tr(),
      body: [
        TextSpan(
          text: ssids.isEmpty ? 'settings.TrustedSsidsDescription'.tr() : ssids,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'settings.TrustedSsids'.tr(),
          prefill: ssids,
          extraText: [TextSpan(text: 'settings.TrustedSsidsHint'.tr())],
        );
        if (result.item1) {
          profile.lidarrLocalSsids = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid();
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.current.lidarrKey;
    return ZagBlock(
      title: 'settings.ApiKey'.tr(),
      body: [
        TextSpan(
          text: apiKey.isEmpty
              ? 'zagreus.NotSet'.tr()
              : ZagUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.ApiKey'.tr(),
          prefill: apiKey,
        );
        if (_values.item1) {
          ZagProfile.current.lidarrKey = _values.item2;
          ZagProfile.current.save();
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: Icons.wifi_tethering_rounded,
      onTap: () async {
        ZagProfile _profile = ZagProfile.current;
        if (_profile.lidarrHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'.tr(
              args: [ZagModule.LIDARR.title],
            ),
          );
          return;
        }
        if (_profile.lidarrKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'.tr(
              args: [ZagModule.LIDARR.title],
            ),
          );
          return;
        }
        LidarrAPI.from(ZagProfile.current)
            .testConnection()
            .then(
              (_) => showZagSuccessSnackBar(
                title: 'settings.ConnectedSuccessfully'.tr(),
                message: 'settings.ConnectedSuccessfullyMessage'.tr(
                  args: [ZagModule.LIDARR.title],
                ),
              ),
            )
            .catchError((error, trace) {
          ZagLogger().error(
            'Connection Test Failed',
            error,
            trace,
          );
          showZagErrorSnackBar(
            title: 'settings.ConnectionTestFailed'.tr(),
            error: error,
          );
        });
      },
    );
  }

  Widget _customHeaders() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
