import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/overseerr/core/state.dart';
import 'package:zagreus/modules/overseerr/routes/overseerr.dart';
import 'package:zagreus/modules/overseerr/routes/requests.dart';
import 'package:zagreus/modules/overseerr/routes/issues.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum OverseerrRoutes with ZagRoutesMixin {
  HOME('/overseerr'),
  REQUESTS('requests'),
  ISSUES('issues');

  @override
  final String path;

  const OverseerrRoutes(this.path);

  @override
  ZagModule get module => ZagModule.OVERSEERR;

  @override
  bool isModuleEnabled(BuildContext context) {
    return context.read<OverseerrState>().enabled;
  }

  @override
  GoRoute get routes {
    switch (this) {
      case OverseerrRoutes.HOME:
        return route(widget: const OverseerrRoute());
      case OverseerrRoutes.REQUESTS:
        return route(widget: const OverseerrRequestsRoute());
      case OverseerrRoutes.ISSUES:
        return route(widget: const OverseerrIssuesRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case OverseerrRoutes.HOME:
        return [
          OverseerrRoutes.REQUESTS.routes,
          OverseerrRoutes.ISSUES.routes,
        ];
      default:
        return const [];
    }
  }
}
