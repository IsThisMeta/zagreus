import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings/core/pages/headers.dart';
import 'package:zagreus/modules.dart';

class ConfigurationBazarrConnectionDetailsHeadersRoute extends StatelessWidget {
  const ConfigurationBazarrConnectionDetailsHeadersRoute({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsHeaderRoute(module: ZagModule.BAZARR);
  }
}
