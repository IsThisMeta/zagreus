import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/supabase/core.dart';

class DeepLinkHandler {
  static void initialize(BuildContext context) {
    // Listen for deep links
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        // User successfully confirmed email or signed in
        // Navigate to main app screen
        print('User confirmed email and signed in');
        // Navigator.of(context).pushReplacementNamed('/home');
      } else if (event == AuthChangeEvent.userUpdated) {
        // Handle email change confirmation
        print('User email updated');
      } else if (event == AuthChangeEvent.passwordRecovery) {
        // Handle password reset
        print('Password recovery initiated');
        // Navigator.of(context).pushNamed('/reset-password');
      }
    });
  }
  
  static Future<void> handleDeepLink(Uri uri) async {
    // Handle the incoming deep link
    if (uri.scheme == 'zagreus' && uri.host == 'auth') {
      // Extract token and type from the URL
      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        // Supabase will automatically handle the token verification
        // when the app receives the deep link
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    }
  }
}