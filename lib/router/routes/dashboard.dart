import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/route.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum DashboardRoutes with ZagRoutesMixin {
  HOME('/dashboard');

  @override
  final String path;

  const DashboardRoutes(this.path);

  @override
  ZagModule get module => ZagModule.DASHBOARD;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case DashboardRoutes.HOME:
        return route(widget: const DashboardRoute());
    }
  }
}
