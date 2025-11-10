import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/widgets/ui/downloads_drawer.dart';

/// Manager to provide global downloads drawer
class ZagGlobalFABManager {
  static final ZagGlobalFABManager instance = ZagGlobalFABManager._();
  ZagGlobalFABManager._();

  bool _isInjected = false;

  void injectFAB(BuildContext context, {GlobalKey<ScaffoldState>? scaffoldKey}) {
    if (_isInjected) {
      return;
    }
    _isInjected = true;
  }

  Widget? getEndDrawer() {
    if (!ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED.read()) {
      return null;
    }
    return const ZagDownloadsDrawer();
  }
}
