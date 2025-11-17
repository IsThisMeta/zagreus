import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/unraid.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationUnraidRoute extends StatefulWidget {
  const ConfigurationUnraidRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationUnraidRoute> createState() => _State();
}

class _State extends State<ConfigurationUnraidRoute>
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
      title: ZagModule.UNRAID.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.UNRAID.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.UNRAID.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.serverEnabled,
          onChanged: (value) {
            ZagProfile.current.serverEnabled = value;
            ZagProfile.current.save();
            context.read<UnraidState>().reset();
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
            args: [ZagModule.UNRAID.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS.go,
    );
  }
}
