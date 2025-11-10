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

  void injectFAB(BuildContext context, {GlobalKey<ScaffoldState>? scaffoldKey}) {
    // Store scaffold key for drawer access
    _scaffoldKey = scaffoldKey;
    
    if (_isInjected) {
      print('🔍 FABManager: FAB already injected, skipping');
      return;
    }

    print('🔍 FABManager: Injecting FAB overlay');
    print(
        '🔍 FABManager: Setting enabled: ${ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()}');

    // FAB is now handled by the endDrawer in scaffold
    _isInjected = true;
    print('🔍 FABManager: FAB setup complete (using endDrawer)');
  }

  GlobalKey<ScaffoldState>? _scaffoldKey;

  Widget? getEndDrawer(String currentModule) {
    if (!ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()) {
      return null;
    }
    if (currentModule.isEmpty) {
      return null;
    }
    if (_scaffoldKey == null) {
      return null;
    }
    return ZagModuleSwitcherFAB(
      currentModuleKey: currentModule,
      scaffoldKey: _scaffoldKey!,
    );
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
    if (routeLower.contains('settings')) return '';
    if (routeLower.contains('dashboard')) return ''; // Hide FAB on dashboard
    if (routeLower == '/') return ''; // Hide FAB on dashboard

    return '';
  }
}
