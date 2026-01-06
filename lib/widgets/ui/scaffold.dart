import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/platform.dart';

class ZagScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ZagModule? module;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double? endDrawerEnableOpenDragGesture;

  /// Called when [ZagreusDatabase.ENABLED_PROFILE] has changed. Triggered within the build function.
  final void Function(BuildContext)? onProfileChange;

  // ignore: use_key_in_widget_constructors
  const ZagScaffold({
    required this.scaffoldKey,
    this.module,
    this.appBar,
    this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.endDrawerEnableOpenDragGesture,
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

        final effectiveEndDrawerDragWidth = endDrawerEnableOpenDragGesture ?? 25.0;

        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final effectiveAppBar = isLandscape ? null : appBar;

        return Scaffold(
          key: scaffoldKey,
          appBar: effectiveAppBar,
          body: body,
          drawer: drawer,
          endDrawer: endDrawer,
          endDrawerEnableOpenDragGesture: endDrawer != null,
          drawerEdgeDragWidth: endDrawer != null ? effectiveEndDrawerDragWidth : null,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          onDrawerChanged: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onEndDrawerChanged: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        );
      },
    );
  }
}
