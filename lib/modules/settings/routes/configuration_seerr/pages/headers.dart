import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/settings.dart';

class ConfigurationSeerrConnectionDetailsHeadersRoute extends StatelessWidget {
  const ConfigurationSeerrConnectionDetailsHeadersRoute({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsHeaderRoute(module: ZagModule.SEERR);
  }
}
