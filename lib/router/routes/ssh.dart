import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/modules/ssh/routes/ssh/route.dart';
import 'package:zagreus/modules/ssh/routes/terminal/route.dart';
import 'package:zagreus/modules/ssh/routes/ssh/pages/add_connection.dart';
import 'package:zagreus/modules/ssh/routes/ssh/pages/edit_connection.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/vendor.dart';

enum SSHRoutes with ZagRoutesMixin {
  HOME('/ssh'),
  ADD_CONNECTION('add'),
  EDIT_CONNECTION('edit/:connectionId'),
  TERMINAL('terminal/:connectionId');

  @override
  final String path;

  const SSHRoutes(this.path);

  @override
  ZagModule get module => ZagModule.SSH;

  @override
  bool isModuleEnabled(BuildContext context) {
    return ZagreusPro.isEnabled && context.read<SSHState>().enabled;
  }

  @override
  GoRoute get routes {
    switch (this) {
      case SSHRoutes.HOME:
        return route(widget: const SSHRoute());
      case SSHRoutes.ADD_CONNECTION:
        return route(widget: const SSHAddConnectionRoute());
      case SSHRoutes.EDIT_CONNECTION:
        return route(builder: (_, state) {
          final connectionId = state.pathParameters['connectionId'] ?? '';
          return SSHEditConnectionRoute(connectionId: connectionId);
        });
      case SSHRoutes.TERMINAL:
        return route(builder: (_, state) {
          final connectionId = state.pathParameters['connectionId'] ?? '';
          return SSHTerminalRoute(connectionId: connectionId);
        });
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case SSHRoutes.HOME:
        return [
          SSHRoutes.ADD_CONNECTION.routes,
          SSHRoutes.EDIT_CONNECTION.routes,
          SSHRoutes.TERMINAL.routes,
        ];
      default:
        return const <GoRoute>[];
    }
  }
}
