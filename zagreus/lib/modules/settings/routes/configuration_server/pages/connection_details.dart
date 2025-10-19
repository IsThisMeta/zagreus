import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';

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
}
