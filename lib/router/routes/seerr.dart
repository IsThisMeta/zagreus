import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/seerr/core/state.dart';
import 'package:zagreus/modules/seerr/routes/seerr.dart';
import 'package:zagreus/modules/seerr/routes/requests.dart';
import 'package:zagreus/modules/seerr/routes/issues.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/vendor.dart';

enum SeerrRoutes with ZagRoutesMixin {
  HOME('/seerr'),
  REQUESTS('requests'),
  ISSUES('issues');

  @override
  final String path;

  const SeerrRoutes(this.path);

  @override
  ZagModule get module => ZagModule.SEERR;

  @override
  bool isModuleEnabled(BuildContext context) {
    return ZagreusPro.isEnabled && context.read<SeerrState>().enabled;
  }

  @override
  GoRoute get routes {
    switch (this) {
      case SeerrRoutes.HOME:
        return route(widget: const SeerrRoute());
      case SeerrRoutes.REQUESTS:
        return route(widget: const SeerrRequestsRoute());
      case SeerrRoutes.ISSUES:
        return route(widget: const SeerrIssuesRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case SeerrRoutes.HOME:
        return [
          SeerrRoutes.REQUESTS.routes,
          SeerrRoutes.ISSUES.routes,
        ];
      default:
        return const [];
    }
  }
}
