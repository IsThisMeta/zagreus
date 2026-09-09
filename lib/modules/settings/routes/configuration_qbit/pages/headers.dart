import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings/core/pages/headers.dart';

class ConfigurationQBitConnectionDetailsHeadersRoute extends StatelessWidget {
  const ConfigurationQBitConnectionDetailsHeadersRoute({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsHeaderRoute(module: ZagModule.QBIT);
  }
}
