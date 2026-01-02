import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSSHRoute extends StatefulWidget {
  const ConfigurationSSHRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationSSHRoute> createState() => _State();
}

class _State extends State<ConfigurationSSHRoute> with ZagScrollControllerMixin {
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
      title: ZagModule.SSH.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.SSH.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.SSH.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.sshEnabled,
          onChanged: (value) {
            ZagProfile.current.sshEnabled = value;
            ZagProfile.current.save();
            context.read<SSHState>().reset();
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
            args: [ZagModule.SSH.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SSH_CONNECTION_DETAILS.go,
    );
  }
}
