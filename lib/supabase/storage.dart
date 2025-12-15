import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'dart:convert';

class ZagSupabaseStorage {
  static const String _BACKUP_BUCKET = 'backups';

  /// Returns an instance of Supabase Storage.
  ///
  /// Throws an error if [ZagSupabase.initialize] has not been called.
  static SupabaseStorageClient get instance => Supabase.instance.client.storage;

  /// Returns the storage bucket for backups.
  static StorageFileApi get backupBucket => instance.from(_BACKUP_BUCKET);

  /// Upload a backup configuration to Supabase storage.
  ///
  /// If the user is not signed in, returns false.
  Future<bool> uploadBackup(String data, String id) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;
    try {
      final userId = ZagSupabaseAuth().uid;
      final path = '$userId/$id.zagreus';
      
      // Convert string to bytes
      final bytes = utf8.encode(data);
      
      // Upload file
      await backupBucket.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'application/json',
          upsert: true,
        ),
      );
      
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to backup to Supabase', error, stack);
      return false;
    }
  }

  /// Delete a backup configuration from Supabase storage.
  ///
  /// If the user is not signed in, returns false.
  Future<bool> deleteBackup(String? id) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;
    try {
      final userId = ZagSupabaseAuth().uid;
      final path = '$userId/$id.zagreus';
      
      await backupBucket.remove([path]);
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to delete backup from Supabase', error, stack);
      return false;
    }
  }

  /// Download a backup configuration from Supabase storage.
  ///
  /// If the user is not signed in, returns null.
  Future<String?> downloadBackup(String? id) async {
    if (!ZagSupabaseAuth().isSignedIn) return null;
    try {
      final userId = ZagSupabaseAuth().uid;
      final path = '$userId/$id.zagreus';
      
      final response = await backupBucket.download(path);
      return utf8.decode(response);
    } catch (error, stack) {
      ZagLogger()
          .error('Failed to download backup from Supabase', error, stack);
      return null;
    }
  }
}