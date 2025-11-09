import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/widgets/ui/module_switcher_fab.dart';

/// Manager to track current module globally and inject FAB via Overlay
class ZagGlobalFABManager {
  static final ZagGlobalFABManager instance = ZagGlobalFABManager._();
  ZagGlobalFABManager._();

  final ValueNotifier<String> currentModuleNotifier = ValueNotifier<String>('');
  OverlayEntry? _overlayEntry;
  bool _isInjected = false;
  
  // Track current route for saving when switching modules
  String _currentRoute = '';
  String _currentModule = '';

  void injectFAB(BuildContext context) {
    if (_isInjected) {
      print('🔍 FABManager: FAB already injected, skipping');
      return;
    }

    print('🔍 FABManager: Injecting FAB overlay');
    print(
        '🔍 FABManager: Setting enabled: ${ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()}');

    try {
      final overlay = Overlay.of(context, rootOverlay: true);
      print('🔍 FABManager: Overlay found: $overlay');

      _overlayEntry = OverlayEntry(
        builder: (context) {
          print('🔍 OverlayEntry: Building FAB');
          return Positioned(
            bottom: 85, // Align with SABnzbd FAB (above bottom nav bar)
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: ValueListenableBuilder<String>(
                  valueListenable: currentModuleNotifier,
                  builder: (context, currentModule, _) {
                    print('🔍 GlobalFAB: Building with module: $currentModule');

                    if (currentModule.isEmpty ||
                        !ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()) {
                      print('🔍 GlobalFAB: Empty or disabled, hiding');
                      return const SizedBox.shrink();
                    }

                    print('🔍 GlobalFAB: Creating FAB widget');
                    return ZagModuleSwitcherFAB(
                      currentModuleKey: currentModule,
                    );
                  },
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(_overlayEntry!);
      _isInjected = true;
      print('🔍 FABManager: FAB overlay injected successfully');
    } catch (e, stack) {
      print('🔍 FABManager: ERROR injecting FAB: $e');
      print('🔍 FABManager: Stack: $stack');
    }
  }

  void updateModule(String routeName) {
    final module = _extractModuleFromRoute(routeName);
    print('🔍 FABManager: Route name: $routeName → Module: $module');

    // Update current tracking
    _currentModule = module;

    if (module != currentModuleNotifier.value) {
      currentModuleNotifier.value = module;
    }
  }
  
  /// Call this when a module is launched (e.g., from drawer)
  void trackModuleLaunch(String targetModuleKey) {
    print('🔍 FABManager: trackModuleLaunch called for: $targetModuleKey');
    // Forward to the FAB's static tracking method
    ZagModuleSwitcherFAB.updateModuleTracking(targetModuleKey);
  }

  String _extractModuleFromRoute(String route) {
    // Route format is like "sonarr:HOME" or "dashboard:HOME"
    final routeLower = route.toLowerCase();

    if (routeLower.contains('sonarr')) return 'sonarr';
    if (routeLower.contains('radarr')) return 'radarr';
    if (routeLower.contains('lidarr')) return 'lidarr';
    if (routeLower.contains('tautulli')) return 'tautulli';
    if (routeLower.contains('sabnzbd')) return 'sabnzbd';
    if (routeLower.contains('nzbget')) return 'nzbget';
    if (routeLower.contains('overseerr')) return 'overseerr';
    if (routeLower.contains('server')) return 'server';
    if (routeLower.contains('search')) return 'search';
    if (routeLower.contains('settings')) return 'settings';
    if (routeLower.contains('dashboard')) return ''; // Hide FAB on dashboard
    if (routeLower == '/') return ''; // Hide FAB on dashboard

    return '';
  }
}
