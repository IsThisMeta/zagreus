import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/config/supabase_config.dart';

class ZagSupabase {
  // Configuration loaded from gitignored file
  static const String _supabaseUrl = SupabaseConfig.url;
  static const String _supabaseAnonKey = SupabaseConfig.anonKey;
  
  static bool get isSupported {
    if (ZagPlatform.isMobile || ZagPlatform.isMacOS || ZagPlatform.isWeb) {
      return true;
    }
    return false;
  }

  /// Initialize Supabase and configuration.
  ///
  /// This must be called before anything accesses Supabase services, or an exception will be thrown.
  Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: true,
      ),
    );
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}