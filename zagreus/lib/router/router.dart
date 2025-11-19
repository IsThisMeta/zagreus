import 'package:flutter/material.dart';

import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/widgets/pages/error_route.dart';
import 'package:zagreus/widgets/ui/global_cube_overlay.dart';
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
        _CubeRouteObserver(), // Track routes for global cube
      ],
    );
    // Route tracking saves routes as you navigate (for bounce-back feature)
    // Restoration is controlled by module.launch(restore: true/false)
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

/// Observer that tracks route changes for the global cube
class _CubeRouteObserver extends NavigatorObserver {
  bool _hasInjectedCube = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    // Inject cube on first route push
    if (!_hasInjectedCube && navigator?.context != null) {
      _hasInjectedCube = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInjectCube();
      });
    }
    _updateCube(route);
  }

  void _tryInjectCube({int attempt = 0}) {
    if (navigator?.context == null) return;

    // Check if Overlay is available
    final overlay = Overlay.maybeOf(navigator!.context, rootOverlay: true);
    if (overlay != null) {
      print('🔍 CubeRouteObserver: Injecting cube on first route');
      ZagGlobalCubeManager.instance.injectCube(navigator!.context);
    } else if (attempt < 3) {
      // Retry up to 3 times with increasing delays
      print(
          '🔍 CubeRouteObserver: Overlay not ready, retrying (attempt ${attempt + 1}/3)');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInjectCube(attempt: attempt + 1);
      });
    } else {
      print('🔍 CubeRouteObserver: Failed to inject cube after 3 attempts');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _updateCube(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _updateCube(newRoute);
    }
  }

  void _updateCube(Route route) {
    final name = route.settings.name ?? '';
    ZagGlobalCubeManager.instance.updateModule(name);
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
    // Skip if module tab memory is disabled
    if (!ZagreusDatabase.MODULE_TAB_MEMORY_ENABLED.read()) {
      print('🔍 RouteTracker: Memory disabled, skipping');
      return;
    }

    final rawLocation = _provider.value.location ?? '';
    if (rawLocation.isEmpty) {
      print('🔍 RouteTracker: Empty location, skipping');
      return;
    }

    final uri = _normalizeUri(rawLocation);
    if (uri == null) {
      print('🔍 RouteTracker: Failed to normalize URI: $rawLocation');
      return;
    }

    var path = uri.path.isEmpty ? '/' : uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final module = _moduleForPath(path);
    if (module == null) {
      print('🔍 RouteTracker: No module for path: $path');
      return;
    }

    final home = module.homeRoute;
    if (home == null) {
      print('🔍 RouteTracker: Module ${module.key} has no home route');
      return;
    }

    if (!(path == home || path.startsWith('$home/'))) {
      print('🔍 RouteTracker: Path $path not under home $home, skipping');
      return;
    }

    final normalizedLocation = uri.replace(fragment: null).toString();
    if (!module.canRestoreRoute(normalizedLocation)) {
      print('🔍 RouteTracker: Route $normalizedLocation not restorable for ${module.key}');
      return;
    }

    final last = ZagSessionState.instance.getModuleLastRoute(module.key);
    if (last == normalizedLocation) {
      print('🔍 RouteTracker: Route $normalizedLocation already saved for ${module.key}, skipping');
      return;
    }

    print('🔍 RouteTracker: Saving route $normalizedLocation for ${module.key}');
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
