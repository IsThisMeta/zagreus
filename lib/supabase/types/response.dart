import 'package:supabase_flutter/supabase_flutter.dart';

class ZagSupabaseResponse {
  final bool state;
  final AuthResponse? authResponse;
  final AuthException? error;

  ZagSupabaseResponse({
    required this.state,
    this.authResponse,
    this.error,
  });
}