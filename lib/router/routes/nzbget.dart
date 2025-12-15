import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/nzbget/routes/nzbget.dart';
import 'package:zagreus/modules/nzbget/routes/statistics.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum NZBGetRoutes with ZagRoutesMixin {
  HOME('/nzbget'),
  STATISTICS('statistics');

  @override
  final String path;

  const NZBGetRoutes(this.path);

  @override
  ZagModule get module => ZagModule.NZBGET;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case NZBGetRoutes.HOME:
        return route(widget: const NZBGetRoute());
      case NZBGetRoutes.STATISTICS:
        return route(widget: const StatisticsRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case NZBGetRoutes.HOME:
        return [
          NZBGetRoutes.STATISTICS.routes,
        ];
      default:
        return const [];
    }
  }
}
