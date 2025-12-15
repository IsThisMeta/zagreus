import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/utils/zagreus_mega.dart';

/// Debug function - paste this in your discover route temporarily
void debugSubscriptionStatus() async {
  print('🔍 Debug: Checking subscription status...');

  // Check local Mega status
  print('📱 Local ZagreusMega.isEnabled: ${ZagreusMega.isEnabled}');

  // Check Supabase session
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    print('❌ No Supabase session found');
    return;
  }

  print('✅ Supabase session exists');
  print('👤 User ID: ${session.user.id}');
  print('🔑 Token (first 20 chars): ${session.accessToken.substring(0, 20)}...');

  // Check Supabase subscription
  try {
    final result = await Supabase.instance.client.rpc(
      'has_active_mega',
      params: {'p_user_id': session.user.id},
    );
    print('🔍 Supabase has_active_mega result: $result');
  } catch (e) {
    print('❌ Error checking Supabase subscription: $e');
  }
}
