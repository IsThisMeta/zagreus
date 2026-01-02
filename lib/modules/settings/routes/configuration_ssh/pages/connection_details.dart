import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';

class ConfigurationSSHConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationSSHConnectionDetailsRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationSSHConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationSSHConnectionDetailsRoute>
    with ZagScrollControllerMixin {
  final _localHostController = TextEditingController();
  final _localSsidsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  void _loadValues() {
    final profile = ZagProfile.current;
    _localHostController.text = profile.sshLocalHost;
    _localSsidsController.text = profile.sshLocalSsids;
  }

  @override
  void dispose() {
    _localHostController.dispose();
    _localSsidsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return ZagScaffold(
      scaffoldKey: scaffoldKey,
      appBar: ZagAppBar(
        title: 'settings.ConnectionDetails'.tr(),
        scrollControllers: [scrollController],
      ),
      body: ZagListView(
        controller: scrollController,
        children: [
          ZagHeader(text: 'settings.LocalNetworkSettings'.tr()),
          _localHostField(),
          _localSsidsField(),
        ],
      ),
    );
  }

  Widget _localHostField() {
    final profile = ZagProfile.current;
    final host = profile.sshLocalHost;
    return ZagBlock(
      title: 'settings.LocalHost'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'settings.LocalHost'.tr(),
          prefill: host,
        );
        if (result.item1) {
          profile.sshLocalHost = result.item2;
          profile.save();
          context.read<SSHState>().reset();
        }
      },
    );
  }

  Widget _localSsidsField() {
    final profile = ZagProfile.current;
    final ssids = profile.sshLocalSsids;
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
          profile.sshLocalSsids = result.item2;
          profile.save();
          context.read<SSHState>().reset();
        }
      },
    );
  }
}
