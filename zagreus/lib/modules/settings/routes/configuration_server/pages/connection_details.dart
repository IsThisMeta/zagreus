import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/api/unraid/unraid.dart';

class ConfigurationServerConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationServerConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationServerConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationServerConnectionDetailsRoute>
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

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        _testConnection(),
      ],
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.ConnectionDetails'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          _host(),
          _apiKey(),
          _customHeaders(),
        ],
      ),
    );
  }

  Widget _host() {
    String host = ZagProfile.current.serverHost;
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
          ZagProfile.current.serverHost = _values.item2;
          ZagProfile.current.save();
          context.read<ServerState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.current.serverKey;
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
          ZagProfile.current.serverKey = _values.item2;
          ZagProfile.current.save();
          context.read<ServerState>().reset();
        }
      },
    );
  }

  Widget _customHeaders() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SERVER_CONNECTION_DETAILS_HEADERS.go,
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZagIcons.CONNECTION_TEST,
      onTap: () async {
        ZagProfile _profile = ZagProfile.current;
        if (_profile.serverHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.SERVER.title]),
          );
          return;
        }
        if (_profile.serverKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZagModule.SERVER.title]),
          );
          return;
        }
        UnraidAPI(
          host: _profile.serverHost,
          apiKey: _profile.serverKey,
          headers: Map<String, dynamic>.from(_profile.serverHeaders),
        )
            .getSystemInfo()
            .then(
              (info) {
                showZagSuccessSnackBar(
                  title: 'settings.ConnectedSuccessfully'.tr(),
                  message: 'settings.ConnectedSuccessfullyMessage'
                      .tr(args: [ZagModule.SERVER.title]),
                );
              },
            )
            .catchError(
          (error, trace) {
            ZagLogger().error(
              'Connection Test Failed',
              error,
              trace,
            );
            showZagErrorSnackBar(
              title: 'settings.ConnectionTestFailed'.tr(),
              error: error,
            );
          },
        );
      },
    );
  }
}
