import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/types.dart';

class ZagSupabaseDatabase {
  /// Returns an instance of Supabase Client.
  ///
  /// Throws an error if [ZagSupabase.initialize] has not been called.
  static SupabaseClient get instance => Supabase.instance.client;

  /// Add a backup entry to Supabase. Returns true if successful, and false on any error.
  ///
  /// If the user is not signed in, returns false.
  /// Assumes you have a 'backups' table with columns: id, user_id, title, description, timestamp
  Future<bool> addBackupEntry(
    String id,
    int timestamp, {
    String title = '',
    String description = '',
  }) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;
    try {
      final userId = ZagSupabaseAuth().uid;
      await instance.from('backups').insert({
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'timestamp': timestamp,
      });
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to add backup entry', error, stack);
      return false;
    }
  }

  /// Delete a backup entry from Supabase. Returns true if successful, and false on any error.
  ///
  /// If the user is not signed in, returns false.
  Future<bool> deleteBackupEntry(String? id) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;
    try {
      final userId = ZagSupabaseAuth().uid;
      await instance
          .from('backups')
          .delete()
          .eq('id', id!)
          .eq('user_id', userId!);
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to delete backup entry', error, stack);
      return false;
    }
  }

  /// Returns a list of all backups available for this account.
  ///
  /// If the user is not signed in, returns an empty list.
  Future<List<ZagSupabaseBackupDocument>> getBackupEntries() async {
    if (!ZagSupabaseAuth().isSignedIn) return [];
    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await instance
          .from('backups')
          .select()
          .eq('user_id', userId!)
          .order('timestamp', ascending: false);
      
      return (response as List)
          .map<ZagSupabaseBackupDocument>((document) =>
              ZagSupabaseBackupDocument.fromMap(document))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to get backup list', error, stack);
      return [];
    }
  }

  /// Register the device token with our notification server
  /// This is called automatically when the user signs in
  Future<bool> addDeviceToken() async {
    if (!ZagSupabaseAuth().isSignedIn) return false;
    
    // Only register device token if notifications are enabled by the user
    if (!ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) {
      ZagLogger().debug('Skipping device token registration - notifications not enabled');
      return false;
    }
    
    try {
      // Register with our notification server instead of Supabase
      return await ZagSupabaseMessaging.instance.registerDeviceToken();
    } catch (error, stack) {
      ZagLogger().error('Failed to add device token', error, stack);
      return false;
    }
  }
}