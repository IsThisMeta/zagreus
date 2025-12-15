import 'package:flutter/material.dart';

import 'package:zagreus/system/quick_actions/quick_actions.dart';

class ZagOS {
  Future<void> boot(BuildContext context) async {
    if (ZagQuickActions.isSupported) ZagQuickActions().initialize();
  }
}
