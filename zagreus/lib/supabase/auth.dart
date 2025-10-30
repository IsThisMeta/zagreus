import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/database.dart';
import 'package:zagreus/supabase/types.dart';

class ZagSupabaseAuth {
  /// Return an instance of Supabase Auth.
  ///
  /// Throws an error if [ZagSupabase.initialize] has not been called.
  static GoTrueClient get instance => Supabase.instance.client.auth;

  /// Returns the [User] object.
  ///
  /// If the user is not signed in, returns null.
  User? get user => instance.currentUser;

  /// Returns if a user is signed in.
  bool get isSignedIn => instance.currentUser != null;

  /// Returns the user's UID.
  ///
  /// If the user is not signed in, returns null.
  String? get uid => instance.currentUser?.id;

  /// Return the user's email.
  ///
  /// If the user is not signed in, returns null.
  String? get email => instance.currentUser?.email;

  /// Sign out a logged in user.
  ///
  /// If the user is not signed in, this is a non-op.
  Future<void> signOut() async {
    await instance.signOut();

    // Log out from RevenueCat to create a new anonymous user
    try {
      await Purchases.logOut();
      ZagLogger().debug('✅ Logged out from RevenueCat');
    } catch (e) {
      ZagLogger().warning('Failed to log out from RevenueCat: $e');
    }
  }

  /// Register a new user using Supabase Authentication.
  ///
  /// Returns a [ZagSupabaseResponse] which contains the state (true on success, false on failure), the [AuthResponse] object, and [AuthException] if applicable.
  Future<ZagSupabaseResponse> registerUser(
      String email, String password) async {
    try {
      AuthResponse authResponse = await instance.signUp(
        email: email,
        password: password,
      );
      if (authResponse.user != null) {
        ZagSupabaseDatabase().addDeviceToken();

        // Link RevenueCat purchases to this Supabase user
        try {
          await Purchases.logIn(authResponse.user!.id);
          ZagLogger().debug('✅ Linked RevenueCat to Supabase user ${authResponse.user!.id}');
        } catch (e) {
          ZagLogger().warning('Failed to link RevenueCat: $e');
          // Don't fail registration if RevenueCat linking fails
        }

        return ZagSupabaseResponse(state: true, authResponse: authResponse);
      } else {
        return ZagSupabaseResponse(state: false);
      }
    } on AuthException catch (error) {
      return ZagSupabaseResponse(state: false, error: error);
    } catch (error, stack) {
      ZagLogger().error("Failed to register user: $email", error, stack);
      return ZagSupabaseResponse(state: false);
    }
  }

  /// Sign in a user using Supabase Authentication.
  ///
  /// Returns a [ZagSupabaseResponse] which contains the state (true on success, false on failure), the [AuthResponse] object, and [AuthException] if applicable.
  Future<ZagSupabaseResponse> signInUser(String email, String password) async {
    try {
      AuthResponse authResponse = await instance.signInWithPassword(
        email: email,
        password: password,
      );
      if (authResponse.user != null) {
        ZagSupabaseDatabase().addDeviceToken();

        // Link RevenueCat purchases to this Supabase user
        try {
          await Purchases.logIn(authResponse.user!.id);
          ZagLogger().debug('✅ Linked RevenueCat to Supabase user ${authResponse.user!.id}');
        } catch (e) {
          ZagLogger().warning('Failed to link RevenueCat: $e');
          // Don't fail sign-in if RevenueCat linking fails
        }

        return ZagSupabaseResponse(state: true, authResponse: authResponse);
      } else {
        return ZagSupabaseResponse(state: false);
      }
    } on AuthException catch (error) {
      return ZagSupabaseResponse(state: false, error: error);
    } catch (error, stack) {
      ZagLogger().error("Failed to login user: $email", error, stack);
      return ZagSupabaseResponse(state: false);
    }
  }

  /// Delete the currently logged in user from the Supabase project.
  ///
  /// The user's password is required to validate and acquire fresh credentials to process the deletion.
  Future<ZagSupabaseResponse> deleteUser(String password) async {
    try {
      // First, reauthenticate the user
      AuthResponse authResponse = await instance.signInWithPassword(
        email: email!,
        password: password,
      );
      
      if (authResponse.user != null) {
        // In Supabase, user deletion typically requires calling an edge function
        // or using the admin API. For now, we'll just sign out.
        // You'll need to implement a server-side function to delete users.
        await instance.signOut();
        
        // TODO: Call your edge function or server endpoint to delete the user
        // await Supabase.instance.client.functions.invoke('delete-user', body: {'userId': uid});
        
        return ZagSupabaseResponse(state: true);
      } else {
        return ZagSupabaseResponse(state: false);
      }
    } on AuthException catch (error) {
      return ZagSupabaseResponse(state: false, error: error);
    } catch (error, stack) {
      ZagLogger().error('Failed to delete user: ${user!.email}', error, stack);
      rethrow;
    }
  }

  Future<ZagSupabaseResponse> updateEmail(
    String newEmail,
    String password,
  ) async {
    try {
      // First, reauthenticate the user
      AuthResponse authResponse = await instance.signInWithPassword(
        email: email!,
        password: password,
      );
      
      if (authResponse.user != null) {
        UserResponse response = await instance.updateUser(
          UserAttributes(email: newEmail),
        );
        
        if (response.user != null) {
          return ZagSupabaseResponse(state: true);
        } else {
          return ZagSupabaseResponse(state: false);
        }
      } else {
        return ZagSupabaseResponse(state: false);
      }
    } on AuthException catch (error) {
      return ZagSupabaseResponse(state: false, error: error);
    } catch (error, stack) {
      ZagLogger().error('Failed to set email: ${user!.email}', error, stack);
      rethrow;
    }
  }

  Future<ZagSupabaseResponse> updatePassword(
    String newPassword,
    String password,
  ) async {
    try {
      // First, reauthenticate the user
      AuthResponse authResponse = await instance.signInWithPassword(
        email: email!,
        password: password,
      );
      
      if (authResponse.user != null) {
        UserResponse response = await instance.updateUser(
          UserAttributes(password: newPassword),
        );
        
        if (response.user != null) {
          return ZagSupabaseResponse(state: true);
        } else {
          return ZagSupabaseResponse(state: false);
        }
      } else {
        return ZagSupabaseResponse(state: false);
      }
    } on AuthException catch (error) {
      return ZagSupabaseResponse(state: false, error: error);
    } catch (error, stack) {
      ZagLogger().error('Failed to set pass: ${user!.email}', error, stack);
      rethrow;
    }
  }

  /// Reset a user's password by sending them a password reset email.
  Future<void> resetPassword(String email) async {
    await instance.resetPasswordForEmail(
      email,
      redirectTo: 'https://zagreus.app/reset-password',
    );
  }

  /// Listen to auth state changes.
  /// Returns a stream that emits the current user when auth state changes.
  static Stream<User?> authStateChanges() {
    return instance.onAuthStateChange.map((event) => event.session?.user);
  }
}