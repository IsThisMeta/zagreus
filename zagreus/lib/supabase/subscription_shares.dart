import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/database.dart';

/// Model for a subscription share
class SubscriptionShare {
  final String id;
  final String ownerUserId;
  final String ownerProductId;
  final DateTime ownerExpiresAt;
  final String sharedWithUserId;
  final String? sharedWithEmail;
  final String status; // 'active' or 'revoked'
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionShare({
    required this.id,
    required this.ownerUserId,
    required this.ownerProductId,
    required this.ownerExpiresAt,
    required this.sharedWithUserId,
    this.sharedWithEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionShare.fromMap(Map<String, dynamic> map) {
    return SubscriptionShare(
      id: map['id'] as String,
      ownerUserId: map['owner_user_id'] as String,
      ownerProductId: map['owner_product_id'] as String,
      ownerExpiresAt: DateTime.parse(map['owner_expires_at'] as String),
      sharedWithUserId: map['shared_with_user_id'] as String,
      sharedWithEmail: map['shared_with_email'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Model for Pro access result
class ProAccessResult {
  final bool hasAccess;
  final String? accessType; // 'direct', 'shared', or null
  final DateTime? expiresAt;
  final String? productId;

  ProAccessResult({
    required this.hasAccess,
    this.accessType,
    this.expiresAt,
    this.productId,
  });

  bool get isDirect => accessType == 'direct';
  bool get isShared => accessType == 'shared';
}

/// Service for managing subscription shares
class ZagSupabaseShares {
  static final ZagSupabaseShares _instance = ZagSupabaseShares._internal();
  factory ZagSupabaseShares() => _instance;
  ZagSupabaseShares._internal();

  SupabaseClient get _client => ZagSupabaseDatabase.instance;

  /// Check if user has Pro access (direct subscription OR shared)
  Future<ProAccessResult> checkProAccess() async {
    if (!ZagSupabaseAuth().isSignedIn) {
      return ProAccessResult(hasAccess: false);
    }

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('has_pro_access', params: {
        'p_user_id': userId,
      }) as List;

      if (response.isEmpty) {
        return ProAccessResult(hasAccess: false);
      }

      final result = response.first;
      return ProAccessResult(
        hasAccess: result['has_access'] as bool? ?? false,
        accessType: result['access_type'] as String?,
        expiresAt: result['expires_at'] != null
            ? DateTime.parse(result['expires_at'] as String)
            : null,
        productId: result['product_id'] as String?,
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to check Pro access', error, stack);
      return ProAccessResult(hasAccess: false);
    }
  }

  /// Get remaining share slots for the current user
  Future<int> getRemainingShares(String productId) async {
    if (!ZagSupabaseAuth().isSignedIn) return 0;

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('get_remaining_shares', params: {
        'p_user_id': userId,
        'p_product_id': productId,
      });

      return response as int? ?? 0;
    } catch (error, stack) {
      ZagLogger().error('Failed to get remaining shares', error, stack);
      return 0;
    }
  }

  /// Get all shares granted by the current user
  Future<List<SubscriptionShare>> getGrantedShares() async {
    if (!ZagSupabaseAuth().isSignedIn) return [];

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client
          .from('subscription_shares')
          .select()
          .eq('owner_user_id', userId!)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((map) => SubscriptionShare.fromMap(map))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to get granted shares', error, stack);
      return [];
    }
  }

  /// Get shares granted to the current user
  Future<List<SubscriptionShare>> getReceivedShares() async {
    if (!ZagSupabaseAuth().isSignedIn) return [];

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client
          .from('subscription_shares')
          .select()
          .eq('shared_with_user_id', userId!)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((map) => SubscriptionShare.fromMap(map))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to get received shares', error, stack);
      return [];
    }
  }

  /// Grant a share to another user by email
  Future<({bool success, String? error, String? shareId})> grantShare({
    required String recipientEmail,
    required String productId,
    required DateTime expiresAt,
  }) async {
    if (!ZagSupabaseAuth().isSignedIn) {
      return (success: false, error: 'Not signed in', shareId: null);
    }

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('grant_share', params: {
        'p_owner_user_id': userId,
        'p_shared_with_email': recipientEmail,
        'p_owner_product_id': productId,
        'p_owner_expires_at': expiresAt.toUtc().toIso8601String(),
      });

      final result = response as Map<String, dynamic>;
      return (
        success: result['success'] as bool? ?? false,
        error: result['error'] as String?,
        shareId: result['share_id'] as String?,
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to grant share', error, stack);
      return (success: false, error: error.toString(), shareId: null);
    }
  }

  /// Revoke a share
  Future<bool> revokeShare(String shareId) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('revoke_share', params: {
        'p_owner_user_id': userId,
        'p_share_id': shareId,
      });

      return response as bool? ?? false;
    } catch (error, stack) {
      ZagLogger().error('Failed to revoke share', error, stack);
      return false;
    }
  }

  /// Sync master subscription data to Supabase (called by RevenueCat service)
  /// Updates all active shares with new expiry
  Future<bool> syncMasterSubscription({
    required String productId,
    required DateTime expiresAt,
  }) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;

    try {
      final userId = ZagSupabaseAuth().uid;

      // Update all active shares with new expiry
      await _client
          .from('subscription_shares')
          .update({
            'owner_expires_at': expiresAt.toUtc().toIso8601String(),
            'owner_product_id': productId,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('owner_user_id', userId!)
          .eq('status', 'active');

      print('✅ Synced master subscription to Supabase: $productId expires $expiresAt');
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to sync master subscription', error, stack);
      return false;
    }
  }
}
