import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationServerRoute extends StatefulWidget {
  const ConfigurationServerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationServerRoute> createState() => _State();
}

class _State extends State<ConfigurationServerRoute>
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
      title: ZagModule.SERVER.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.SERVER.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.SERVER.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.serverEnabled,
          onChanged: (value) {
            ZagProfile.current.serverEnabled = value;
            ZagProfile.current.save();
            context.read<ServerState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZagModule.SERVER.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SERVER_CONNECTION_DETAILS.go,
    );
  }
}
