import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes/bios.dart';
import 'package:zagreus/router/routes/dashboard.dart';
import 'package:zagreus/router/routes/external_modules.dart';
import 'package:zagreus/router/routes/lidarr.dart';
import 'package:zagreus/router/routes/nzbget.dart';
import 'package:zagreus/router/routes/overseerr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sabnzbd.dart';
import 'package:zagreus/router/routes/search.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/router/routes/tautulli.dart';
import 'package:zagreus/router/routes/discover.dart';
import 'package:zagreus/router/routes/server.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/pages/not_enabled.dart';

enum ZagRoutes {
  bios('bios', root: BIOSRoutes.HOME),
  dashboard('dashboard', root: DashboardRoutes.HOME),
  externalModules('external_modules', root: ExternalModulesRoutes.HOME),
  lidarr('lidarr', root: LidarrRoutes.HOME),
  nzbget('nzbget', root: NZBGetRoutes.HOME),
  overseerr('overseerr', root: OverseerrRoutes.HOME),
  radarr('radarr', root: RadarrRoutes.HOME),
  sabnzbd('sabnzbd', root: SABnzbdRoutes.HOME),
  search('search', root: SearchRoutes.HOME),
  settings('settings', root: SettingsRoutes.HOME),
  sonarr('sonarr', root: SonarrRoutes.HOME),
  tautulli('tautulli', root: TautulliRoutes.HOME),
  discover('discover', root: DiscoverRoutes.HOME),
  server('server', root: ServerRoutes.HOME);

  final String key;
  final ZagRoutesMixin root;

  const ZagRoutes(
    this.key, {
    required this.root,
  });

  static String get initialLocation => BIOSRoutes.HOME.path;
}

mixin ZagRoutesMixin on Enum {
  String get _routeName => '${this.module?.key ?? 'unknown'}:$name';

  String get path;
  ZagModule? get module;

  GoRoute get routes;
  List<GoRoute> get subroutes => const <GoRoute>[];

  bool isModuleEnabled(BuildContext context);

  GoRoute route({
    Widget? widget,
    Widget Function(BuildContext, GoRouterState)? builder,
  }) {
    assert(!(widget == null && builder == null));
    return GoRoute(
      path: path,
      name: _routeName,
      routes: subroutes,
      builder: (context, state) {
        if (isModuleEnabled(context)) {
          _rememberModuleRoute(state);
          return builder?.call(context, state) ?? widget!;
        }
        return NotEnabledPage(module: module?.title ?? 'Zagreus');
      },
    );
  }

  GoRoute redirect({
    required GoRouterRedirect redirect,
  }) {
    return GoRoute(
      path: path,
      name: _routeName,
      redirect: redirect,
    );
  }

  void go({
    Object? extra,
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
    bool buildTree = false,
  }) {
    if (buildTree) {
      return ZagRouter.router.goNamed(
        _routeName,
        extra: extra,
        pathParameters: params,
        queryParameters: queryParams,
      );
    }
    ZagRouter.router.pushNamed(
      _routeName,
      extra: extra,
      pathParameters: params,
      queryParameters: queryParams,
    );
  }

  void _rememberModuleRoute(GoRouterState state) {
    final moduleKey = module?.key;
    if (moduleKey == null) return;

    final moduleHome = module?.homeRoute;
    if (moduleHome == null) return;

    final uri = state.uri.toString();
    if (uri.isEmpty || !uri.startsWith(moduleHome)) return;

    final lastRoute = ZagSessionState.instance.getModuleLastRoute(moduleKey);
    if (lastRoute == uri) return;

    ZagSessionState.instance.setModuleLastRoute(moduleKey, uri);
  }
}
