import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class UnraidState extends ZagModuleState {
  UnraidState() {
    reset();
  }

  @override
  void reset() {
    // Reset stored data
    resetProfile();
    notifyListeners();
  }

  ///////////////
  /// PROFILE ///
  ///////////////

  /// Is the module enabled?
  bool _enabled = false;
  bool get enabled => _enabled;

  /// Server host
  String _host = '';
  String get host => _host;

  /// Server API key
  String _apiKey = '';
  String get apiKey => _apiKey;

  /// Headers to attach to all requests
  Map<String, String> _headers = const {};
  Map<String, String> get headers => _headers;

  /// Check if Unraid is properly configured
  bool get isConfigured => _enabled && _host.isNotEmpty;

  /// Reset the profile data
  void resetProfile() {
    ZagLogger().debug('UnraidState.resetProfile called');
    ZagProfile profile = ZagProfile.current;
    // Copy profile into state
    _enabled = profile.serverEnabled;
    _host = profile.effectiveServerHost();
    _apiKey = profile.serverKey;
    _headers = Map.unmodifiable(profile.serverHeaders);
  }
}
