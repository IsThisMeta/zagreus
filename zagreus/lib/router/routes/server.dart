import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/server/core/state.dart';
import 'package:zagreus/modules/server/routes/server/route.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum ServerRoutes with ZagRoutesMixin {
  HOME('/server');

  @override
  final String path;

  const ServerRoutes(this.path);

  @override
  ZagModule get module => ZagModule.SERVER;

  @override
  bool isModuleEnabled(BuildContext context) {
    return context.read<ServerState>().enabled;
  }

  @override
  GoRoute get routes {
    switch (this) {
      case ServerRoutes.HOME:
        return route(widget: const ServerRoute());
    }
  }
}
