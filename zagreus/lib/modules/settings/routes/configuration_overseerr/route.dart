import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationOverseerrRoute extends StatefulWidget {
  const ConfigurationOverseerrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationOverseerrRoute> createState() => _State();
}

class _State extends State<ConfigurationOverseerrRoute>
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
      title: ZagModule.OVERSEERR.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.OVERSEERR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.OVERSEERR.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.overseerrEnabled,
          onChanged: (value) {
            ZagProfile.current.overseerrEnabled = value;
            ZagProfile.current.save();
            context.read<OverseerrState>().reset();
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
            args: [ZagModule.OVERSEERR.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS.go,
    );
  }
}
