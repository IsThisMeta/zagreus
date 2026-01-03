import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/widgets/ui/downloads_drawer.dart';
import 'package:zagreus/widgets/ui/speed_cube.dart';

/// Manager to track current module globally, inject cube overlay, and provide downloads drawer
class ZagGlobalCubeManager {
  static final ZagGlobalCubeManager instance = ZagGlobalCubeManager._();
  ZagGlobalCubeManager._();

  final ValueNotifier<String> currentModuleNotifier = ValueNotifier<String>('');
  OverlayEntry? _overlayEntry;
  bool _isInjected = false;
  BuildContext? _lastContext;
  StreamSubscription? _speedCubeSubscription;

  // Track current route for saving when switching modules
  String _currentRoute = '';
  String _currentModule = '';

  bool get isCubeEnabled {
    return ZagreusDatabase.SPEED_CUBE_ENABLED.read() && ZagreusPro.isEnabled;
  }

  void injectCube(BuildContext context, {GlobalKey<ScaffoldState>? scaffoldKey}) {
    _lastContext = context;
    _ensureSpeedCubeListener();
    if (!isCubeEnabled) {
      return;
    }
    if (_isInjected) {
      print('🔍 CubeManager: Cube already injected, skipping');
      return;
    }

    print('🔍 CubeManager: Injecting cube overlay');
    print('🔍 CubeManager: Setting enabled: ${ZagreusDatabase.SPEED_CUBE_ENABLED.read()}');

    try {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) {
        print('🔍 CubeManager: Overlay not ready, skipping injection');
        return;
      }
      print('🔍 CubeManager: Overlay found: $overlay');

      _overlayEntry = OverlayEntry(
        builder: (context) {
          print('🔍 OverlayEntry: Building cube');
          return SafeArea(
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 88),
                  child: Material(
                    color: Colors.transparent,
                    child: ZagreusDatabase.SPEED_CUBE_ENABLED
                        .listenableBuilder(
                      builder: (context, _) {
                        final enabled =
                            ZagreusDatabase.SPEED_CUBE_ENABLED.read();
                        if (!enabled || !ZagreusPro.isEnabled) {
                          print('🔍 GlobalCube: Disabled via settings, hiding');
                          return const SizedBox.shrink();
                        }
                        return ValueListenableBuilder<String>(
                          valueListenable: currentModuleNotifier,
                          builder: (context, currentModule, __) {
                            print('🔍 GlobalCube: Building with module: $currentModule');

                            if (currentModule.isEmpty) {
                              print('🔍 GlobalCube: Empty module, hiding');
                              return const SizedBox.shrink();
                            }

                            print('🔍 GlobalCube: Creating cube widget');
                            return ZagSpeedCube(
                              currentModuleKey: currentModule,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(_overlayEntry!);
      _isInjected = true;
      print('🔍 CubeManager: Cube overlay injected successfully');
    } catch (e, stack) {
      print('🔍 CubeManager: ERROR injecting cube: $e');
      print('🔍 CubeManager: Stack: $stack');
    }
  }

  void _ensureSpeedCubeListener() {
    if (_speedCubeSubscription != null) return;
    _speedCubeSubscription =
        ZagreusDatabase.SPEED_CUBE_ENABLED.watch().listen((_) {
      if (!isCubeEnabled) {
        if (_isInjected) {
          _removeCube();
        }
        return;
      }

      if (_isInjected) return;
      final context = _lastContext;
      if (context == null) return;
      if (context is Element && !context.mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = _lastContext;
        if (retryContext == null) return;
        if (retryContext is Element && !retryContext.mounted) return;
        injectCube(retryContext);
      });
    });
  }

  void _removeCube() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isInjected = false;
  }

  void updateModule(String routeName) {
    final module = _extractModuleFromRoute(routeName);
    print('🔍 CubeManager: Route name: $routeName → Module: $module');

    // Update current tracking
    _currentModule = module;

    if (module != currentModuleNotifier.value) {
      currentModuleNotifier.value = module;
    }
  }

  /// Call this when a module is launched (e.g., from drawer)
  void trackModuleLaunch(String targetModuleKey) {
    print('🔍 CubeManager: trackModuleLaunch called for: $targetModuleKey');
    // Forward to the cube's static tracking method
    final fromModule = _currentModule; // Track where we're coming from
    ZagSpeedCube.updateModuleTracking(fromModule, targetModuleKey);
  }

  String _extractModuleFromRoute(String route) {
    // Route format is like "sonarr:HOME" or "dashboard:HOME"
    final routeLower = route.toLowerCase();

    if (routeLower.contains('sonarr')) return 'sonarr';
    if (routeLower.contains('radarr')) return 'radarr';
    if (routeLower.contains('readarr')) return 'readarr';
    if (routeLower.contains('lidarr')) return 'lidarr';
    if (routeLower.contains('tautulli')) return 'tautulli';
    if (routeLower.contains('sabnzbd')) return 'sabnzbd';
    if (routeLower.contains('nzbget')) return 'nzbget';
    if (routeLower.contains('seerr')) return 'seerr';
    if (routeLower.contains('unraid')) return 'unraid';
    if (routeLower.contains('server')) return 'server';
    if (routeLower.contains('search')) return 'search';
    if (routeLower.contains('settings')) return '';
    if (routeLower.contains('dashboard')) return ''; // Hide cube on dashboard
    if (routeLower == '/') return ''; // Hide cube on dashboard

    return '';
  }

  Widget? getEndDrawer() {
    if (!ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED.read() || !ZagreusPro.isEnabled) {
      return null;
    }
    return const ZagDownloadsDrawer();
  }
}
