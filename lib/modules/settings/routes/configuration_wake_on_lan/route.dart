import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';

class ConfigurationWakeOnLANRoute extends StatefulWidget {
  const ConfigurationWakeOnLANRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationWakeOnLANRoute> createState() => _State();
}

class _State extends State<ConfigurationWakeOnLANRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      scrollControllers: [scrollController],
      title: ZagModule.WAKE_ON_LAN.title,
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          ZagModule.WAKE_ON_LAN.informationBanner(),
          _enabledToggle(),
          _broadcastAddress(),
          _macAddress(),
        ],
      ),
    );
  }

  Widget _enabledToggle() {
    return ZagBlock(
      title: 'settings.EnableModule'.tr(args: [ZagModule.WAKE_ON_LAN.title]),
      trailing: ZagSwitch(
        value: ZagProfile.current.wakeOnLANEnabled,
        onChanged: (value) {
          ZagProfile.current.wakeOnLANEnabled = value;
          ZagProfile.current.save();
        },
      ),
    );
  }

  Widget _broadcastAddress() {
    String? broadcastAddress = ZagProfile.current.wakeOnLANBroadcastAddress;
    return ZagBlock(
      title: 'settings.BroadcastAddress'.tr(),
      body: [
        TextSpan(
          text:
              broadcastAddress == '' ? 'zagreus.NotSet'.tr() : broadcastAddress,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values =
            await SettingsDialogs().editBroadcastAddress(
          context,
          broadcastAddress,
        );
        if (_values.item1) {
          ZagProfile.current.wakeOnLANBroadcastAddress = _values.item2;
          ZagProfile.current.save();
        }
      },
    );
  }

  Widget _macAddress() {
    String? macAddress = ZagProfile.current.wakeOnLANMACAddress;
    return ZagBlock(
      title: 'settings.MACAddress'.tr(),
      body: [
        TextSpan(text: macAddress == '' ? 'zagreus.NotSet'.tr() : macAddress),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editMACAddress(
          context,
          macAddress,
        );
        if (_values.item1) {
          ZagProfile.current.wakeOnLANMACAddress = _values.item2;
          ZagProfile.current.save();
        }
      },
    );
  }
}
