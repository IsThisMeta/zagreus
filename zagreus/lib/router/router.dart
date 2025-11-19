import 'package:flutter/material.dart';

import 'package:zagreus/database/tables/zagreus.dart';
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
        _tryInjectFAB();
      });
    }
    _updateFAB(route);
    _trackRoute(route);
  }

  void _tryInjectFAB({int attempt = 0}) {
    if (navigator?.context == null) return;

    // Check if Overlay is available
    final overlay = Overlay.maybeOf(navigator!.context, rootOverlay: true);
    if (overlay != null) {
      print('🔍 FABRouteObserver: Injecting FAB on first route');
      ZagGlobalFABManager.instance.injectFAB(navigator!.context);
    } else if (attempt < 3) {
      // Retry up to 3 times with increasing delays
      print('🔍 FABRouteObserver: Overlay not ready, retrying (attempt ${attempt + 1}/3)');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInjectFAB(attempt: attempt + 1);
      });
    } else {
      print('🔍 FABRouteObserver: Failed to inject FAB after 3 attempts');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _updateFAB(previousRoute);
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _updateFAB(newRoute);
      _trackRoute(newRoute);
    }
  }

  void _updateFAB(Route route) {
    final name = route.settings.name ?? '';
    ZagGlobalFABManager.instance.updateModule(name);
  }

  void _trackRoute(Route route) {
    // Skip if module tab memory is disabled
    if (!ZagreusDatabase.MODULE_TAB_MEMORY_ENABLED.read()) {
      print('🔍 FABObserver: Route tracking disabled');
      return;
    }

    // Use PostFrameCallback to ensure the router location is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackRouteDelayed(route);
    });
  }

  void _trackRouteDelayed(Route route) {
    final routeName = route.settings.name;
    if (routeName == null || routeName.isEmpty) {
      print('🔍 FABObserver: No route name, skipping tracking');
      return;
    }

    // Extract module from route name (format: "module:PAGE")
    final parts = routeName.split(':');
    if (parts.length < 2) {
      print('🔍 FABObserver: Invalid route format: $routeName');
      return;
    }

    final moduleName = parts[0].toLowerCase();

    // Find the module
    ZagModule? module;
    for (final m in ZagModule.values) {
      if (m.key == moduleName) {
        module = m;
        break;
      }
    }

    if (module == null) {
      print('🔍 FABObserver: No module found for: $moduleName');
      return;
    }

    final homeRoute = module.homeRoute;
    if (homeRoute == null) {
      print('🔍 FABObserver: Module $moduleName has no home route');
      return;
    }

    // Get the current location AFTER the navigation has completed
    final router = ZagRouter.router;
    final location = router.routeInformationProvider.value.location;
    if (location == null || location.isEmpty) {
      print('🔍 FABObserver: No current location');
      return;
    }

    final uri = Uri.tryParse(location);
    if (uri == null) {
      print('🔍 FABObserver: Failed to parse location: $location');
      return;
    }

    var path = uri.path.isEmpty ? '/' : uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // Verify this path belongs to the module
    if (!(path == homeRoute || path.startsWith('$homeRoute/'))) {
      print('🔍 FABObserver: Path $path not under $homeRoute, skipping');
      return;
    }

    final normalizedLocation = uri.replace(fragment: null).toString();
    if (!module.canRestoreRoute(normalizedLocation)) {
      print('🔍 FABObserver: Route $normalizedLocation not restorable');
      return;
    }

    final last = ZagSessionState.instance.getModuleLastRoute(module.key);
    if (last == normalizedLocation) {
      print('🔍 FABObserver: Route $normalizedLocation already saved, skipping');
      return;
    }

    print('🔍 FABObserver: Saving route $normalizedLocation for ${module.key}');
    ZagSessionState.instance.setModuleLastRoute(module.key, normalizedLocation);
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
