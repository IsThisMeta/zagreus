import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/widgets/pages/error_route.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

class ZagRouter {
  static late GoRouter router;
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
  static _RouteLocationTracker? _routeTracker;

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
    _routeTracker = _RouteLocationTracker(router.routeInformationProvider);
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

class _RouteLocationTracker {
  _RouteLocationTracker(this._provider) {
    _provider.addListener(_handleLocationChange);
    _handleLocationChange();
  }

  final GoRouteInformationProvider _provider;

  void dispose() {
    _provider.removeListener(_handleLocationChange);
  }

  void _handleLocationChange() {
    final rawLocation = _provider.value.location ?? '';
    if (rawLocation.isEmpty) return;

    final uri = _normalizeUri(rawLocation);
    if (uri == null) return;

    var path = uri.path.isEmpty ? '/' : uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final module = _moduleForPath(path);
    if (module == null) return;

    final home = module.homeRoute;
    if (home == null) return;

    if (!(path == home || path.startsWith('$home/'))) return;

    final normalizedLocation = uri.replace(fragment: null).toString();
    if (!module.canRestoreRoute(normalizedLocation)) return;

    final last = ZagSessionState.instance.getModuleLastRoute(module.key);
    if (last == normalizedLocation) return;

    ZagSessionState.instance.setModuleLastRoute(module.key, normalizedLocation);
  }

  Uri? _normalizeUri(String location) {
    try {
      final parsed = Uri.parse(location);
      return parsed;
    } catch (_) {
      try {
        return Uri.parse('/$location');
      } catch (_) {
        return null;
      }
    }
  }

  ZagModule? _moduleForPath(String path) {
    for (final module in ZagModule.values) {
      final home = module.homeRoute;
      if (home == null) continue;
      if (path == home || path.startsWith('$home/')) {
        return module;
      }
    }
    return null;
  }
}
