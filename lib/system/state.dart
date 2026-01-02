import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:zagreus/modules/dashboard/core/state.dart';
import 'package:zagreus/modules/lidarr/core/state.dart';
import 'package:zagreus/modules/overseerr/core/state.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/readarr/core/state.dart';
import 'package:zagreus/modules/search/core/state.dart';
import 'package:zagreus/modules/settings/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/modules/sabnzbd/core/state.dart';
import 'package:zagreus/modules/nzbget/core/state.dart';
import 'package:zagreus/modules/tautulli/core/state.dart';
import 'package:zagreus/modules/unraid/core/state.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/router/router.dart';

class ZagState {
  ZagState._();

  static BuildContext get context => ZagRouter.navigator.currentContext!;

  /// Calls `.reset()` on all states which extend [ZagModuleState].
  static void reset([BuildContext? context]) {
    final ctx = context ?? ZagState.context;
    ZagModule.values.forEach((module) => module.state(ctx)?.reset());
  }

  static MultiProvider providers({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(create: (_) => LidarrState()),
        ChangeNotifierProvider(create: (_) => OverseerrState()),
        ChangeNotifierProvider(create: (_) => RadarrState()),
        ChangeNotifierProvider(create: (_) => ReadarrState()),
        ChangeNotifierProvider(create: (_) => SonarrState()),
        ChangeNotifierProvider(create: (_) => NZBGetState()),
        ChangeNotifierProvider(create: (_) => SABnzbdState()),
        ChangeNotifierProvider(create: (_) => TautulliState()),
        ChangeNotifierProvider(create: (_) => UnraidState()),
        ChangeNotifierProvider(create: (_) => SSHState()),
      ],
      child: child,
    );
  }
}

abstract class ZagModuleState extends ChangeNotifier {
  /// Reset the state back to the default
  void reset();
}
