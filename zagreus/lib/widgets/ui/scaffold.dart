import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';

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

        final routeName = ModalRoute.of(context)?.settings.name ?? '';
        final isSettingsRoute =
            routeName.startsWith('${ZagModule.SETTINGS.key}:');
        final isDownloadsModule = routeName.startsWith('${ZagModule.SABNZBD.key}:') ||
            routeName.startsWith('${ZagModule.NZBGET.key}:');
        final isExternalModulesRoute =
            routeName.startsWith('${ZagModule.EXTERNAL_MODULES.key}:');

        // Auto-add downloads drawer if not explicitly provided and not in Settings
        final shouldAttachGlobalEndDrawer =
            !isSettingsRoute &&
            !isDownloadsModule &&
            !isExternalModulesRoute &&
            endDrawer == null;
        final globalEndDrawer = shouldAttachGlobalEndDrawer
            ? ZagGlobalFABManager.instance.getEndDrawer()
            : null;
        final effectiveEndDrawer = endDrawer ?? globalEndDrawer;
        final effectiveEndDrawerDragWidth = endDrawerEnableOpenDragGesture ?? 25.0;

        return Scaffold(
          key: scaffoldKey,
          appBar: appBar,
          body: body,
          drawer: drawer,
          endDrawer: effectiveEndDrawer,
          endDrawerEnableOpenDragGesture: effectiveEndDrawer != null,
          drawerEdgeDragWidth: effectiveEndDrawer != null ? effectiveEndDrawerDragWidth : null,
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
