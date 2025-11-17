import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/unraid/core/state.dart';
import 'package:zagreus/modules/unraid/routes/unraid/route.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/vendor.dart';

enum UnraidRoutes with ZagRoutesMixin {
  HOME('/unraid');

  @override
  final String path;

  const UnraidRoutes(this.path);

  @override
  ZagModule get module => ZagModule.UNRAID;

  @override
  bool isModuleEnabled(BuildContext context) {
    return ZagreusPro.isEnabled && context.read<UnraidState>().enabled;
  }

  @override
  GoRoute get routes {
    switch (this) {
      case UnraidRoutes.HOME:
        return route(widget: const UnraidRoute());
    }
  }
}
