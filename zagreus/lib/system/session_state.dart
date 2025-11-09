/// In-memory session state that persists during app runtime only.
/// Cleared when the app is restarted.
class ZagSessionState {
  ZagSessionState._();
  static final ZagSessionState instance = ZagSessionState._();

  // Module tab positions (module key -> tab index)
  final Map<String, int> _moduleTabPositions = {};
  
  // Module last visited routes (module key -> full route path)
  final Map<String, String> _moduleLastRoutes = {};

  /// Get the saved tab position for a module, or null if not set
  int? getModuleTabPosition(String moduleKey) {
    return _moduleTabPositions[moduleKey];
  }

  /// Save the tab position for a module
  void setModuleTabPosition(String moduleKey, int tabIndex) {
    _moduleTabPositions[moduleKey] = tabIndex;
    print('🔍 Session: Saved ${moduleKey} tab position: $tabIndex');
  }
  
  /// Get the last visited route for a module, or null if not set
  String? getModuleLastRoute(String moduleKey) {
    return _moduleLastRoutes[moduleKey];
  }
  
  /// Save the last visited route for a module
  void setModuleLastRoute(String moduleKey, String routePath) {
    _moduleLastRoutes[moduleKey] = routePath;
    print('🔍 Session: Saved ${moduleKey} last route: $routePath');
  }

  /// Clear all session state
  void clear() {
    _moduleTabPositions.clear();
    _moduleLastRoutes.clear();
    print('🔍 Session: Cleared all state');
  }

  /// Clear tab position for a specific module
  void clearModuleTabPosition(String moduleKey) {
    _moduleTabPositions.remove(moduleKey);
    print('🔍 Session: Cleared ${moduleKey} tab position');
  }
  
  /// Clear last route for a specific module
  void clearModuleLastRoute(String moduleKey) {
    _moduleLastRoutes.remove(moduleKey);
    print('🔍 Session: Cleared ${moduleKey} last route');
  }
}
