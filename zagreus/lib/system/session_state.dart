/// In-memory session state that persists during app runtime only.
/// Cleared when the app is restarted.
class ZagSessionState {
  ZagSessionState._();
  static final ZagSessionState instance = ZagSessionState._();

  // Module tab positions (module key -> tab index)
  final Map<String, int> _moduleTabPositions = {};

  /// Get the saved tab position for a module, or null if not set
  int? getModuleTabPosition(String moduleKey) {
    return _moduleTabPositions[moduleKey];
  }

  /// Save the tab position for a module
  void setModuleTabPosition(String moduleKey, int tabIndex) {
    _moduleTabPositions[moduleKey] = tabIndex;
    print('🔍 Session: Saved ${moduleKey} tab position: $tabIndex');
  }

  /// Clear all session state
  void clear() {
    _moduleTabPositions.clear();
    print('🔍 Session: Cleared all state');
  }

  /// Clear tab position for a specific module
  void clearModuleTabPosition(String moduleKey) {
    _moduleTabPositions.remove(moduleKey);
    print('🔍 Session: Cleared ${moduleKey} tab position');
  }
}
