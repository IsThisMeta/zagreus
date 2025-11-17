import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/settings.dart';

class ConfigurationReadarrConnectionDetailsHeadersRoute
    extends StatelessWidget {
  const ConfigurationReadarrConnectionDetailsHeadersRoute({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SettingsHeaderRoute(module: ZagModule.READARR);
  }
}
