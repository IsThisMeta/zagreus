import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/widgets/pages/error_route.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

class ZagRouter {
  static late GoRouter router;
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

  void initialize() {
    router = GoRouter(
      navigatorKey: navigator,
      errorBuilder: (_, state) => ErrorRoutePage(exception: state.error),
      initialLocation: ZagRoutes.initialLocation,
      routes: ZagRoutes.values.map((r) => r.root.routes).toList(),
      observers: [
        _FABRouteObserver(), // Track routes for global FAB
      ],
    );
  }

  void popSafely() {
    if (router.canPop()) router.pop();
  }

  void popToRootRoute() {
    if (navigator.currentState == null) {
      ZagLogger().warning('Not observing any navigation navigators, skipping');
      return;
    }
    navigator.currentState!.popUntil((route) => route.isFirst);
  }
}

/// Observer that tracks route changes for the global FAB
class _FABRouteObserver extends NavigatorObserver {
  bool _hasInjectedFAB = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    // Inject FAB on first route push
    if (!_hasInjectedFAB && navigator?.context != null) {
      _hasInjectedFAB = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator?.context != null) {
          print('🔍 FABRouteObserver: Injecting FAB on first route');
          ZagGlobalFABManager.instance.injectFAB(navigator!.context);
        }
      });
    }
    _updateFAB(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _updateFAB(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _updateFAB(newRoute);
    }
  }

  void _updateFAB(Route route) {
    final name = route.settings.name ?? '';
    ZagGlobalFABManager.instance.updateModule(name);
  }
}
