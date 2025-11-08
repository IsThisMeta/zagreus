import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/widgets/ui/module_switcher_fab.dart';

class ZagScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ZagModule? module;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  /// Called when [ZagreusDatabase.ENABLED_PROFILE] has changed. Triggered within the build function.
  final void Function(BuildContext)? onProfileChange;

  // ignore: use_key_in_widget_constructors
  const ZagScaffold({
    required this.scaffoldKey,
    this.module,
    this.appBar,
    this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.onProfileChange,
  });

  @override
  Widget build(BuildContext context) {
    if (ZagPlatform.isAndroid) return android;
    return scaffold;
  }

  Widget get android {
    return WillPopScope(
      onWillPop: () async {
        if (!ZagreusDatabase.ANDROID_BACK_OPENS_DRAWER.read()) return true;

        final state = scaffoldKey.currentState;
        if (state?.hasDrawer ?? false) {
          if (state!.isDrawerOpen) return true;
          state.openDrawer();
          return false;
        }
        return true;
      },
      child: scaffold,
    );
  }

  Widget get scaffold {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        onProfileChange?.call(context);

        // Auto-add module switcher FAB if enabled and no custom FAB provided
        // Only for main routes (identified by having a drawer)
        Widget? finalFAB = floatingActionButton;
        if (finalFAB == null &&
            module != null &&
            drawer != null &&
            ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()) {
          finalFAB = ZagModuleSwitcherFAB(
            currentModuleKey: module!.key,
          );
        }

        return Scaffold(
          key: scaffoldKey,
          appBar: appBar,
          body: body,
          drawer: drawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: finalFAB,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          onDrawerChanged: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        );
      },
    );
  }
}
