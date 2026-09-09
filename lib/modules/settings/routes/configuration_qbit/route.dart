import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationQBitRoute extends StatefulWidget {
  const ConfigurationQBitRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationQBitRoute> createState() => _State();
}

class _State extends State<ConfigurationQBitRoute>
    with ZagScrollControllerMixin {
  static const _moduleKey = 'qbit';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ZagProfile get _profile => ZagProfile.forModule(_moduleKey);

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: ZagModule.QBIT.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.QBIT.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultPagesPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.QBIT.title]),
        trailing: ZagSwitch(
          value: _profile.qbitEnabled,
          onChanged: (value) {
            _profile.qbitEnabled = value;
            _profile.save();
            context.read<QBitState>().reset();
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
          text: 'settings.ConnectionDetailsDescription'
              .tr(args: [ZagModule.QBIT.title]),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_QBIT_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_QBIT_DEFAULT_PAGES.go,
    );
  }
}
