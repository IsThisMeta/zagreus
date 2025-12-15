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
  final String sharedWithEmail; // Email address granted access
  final String? sharedWithUserId; // NULL until user signs in
  final String status; // 'active', 'revoked'
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionShare({
    required this.id,
    required this.ownerUserId,
    required this.ownerProductId,
    required this.ownerExpiresAt,
    required this.sharedWithEmail,
    this.sharedWithUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => sharedWithUserId != null;

  factory SubscriptionShare.fromMap(Map<String, dynamic> map) {
    return SubscriptionShare(
      id: map['id'] as String,
      ownerUserId: map['owner_user_id'] as String,
      ownerProductId: map['owner_product_id'] as String,
      ownerExpiresAt: DateTime.parse(map['owner_expires_at'] as String),
      sharedWithEmail: map['shared_with_email'] as String,
      sharedWithUserId: map['shared_with_user_id'] as String?,
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
  final String? shareId; // For linking email to user on first sign-in

  ProAccessResult({
    required this.hasAccess,
    this.accessType,
    this.expiresAt,
    this.productId,
    this.shareId,
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
  /// Auto-links email-based shares to user on first sign-in
  Future<ProAccessResult> checkProAccess() async {
    if (!ZagSupabaseAuth().isSignedIn) {
      return ProAccessResult(hasAccess: false);
    }

    try {
      final userId = ZagSupabaseAuth().uid;
      final userEmail = ZagSupabaseAuth().email;

      final response = await _client.rpc('has_pro_access', params: {
        'p_user_id': userId,
        'p_user_email': userEmail,
      }) as List;

      if (response.isEmpty) {
        return ProAccessResult(hasAccess: false);
      }

      final result = response.first;
      final shareId = result['share_id'] as String?;

      // If we got a share_id, link the email to this user
      if (shareId != null && userEmail != null) {
        await linkEmailShareToUser(shareId, userEmail);
      }

      return ProAccessResult(
        hasAccess: result['has_access'] as bool? ?? false,
        accessType: result['access_type'] as String?,
        expiresAt: result['expires_at'] != null
            ? DateTime.parse(result['expires_at'] as String)
            : null,
        productId: result['product_id'] as String?,
        shareId: shareId,
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

  /// Get shares granted to the current user (by user_id or email)
  Future<List<SubscriptionShare>> getReceivedShares() async {
    if (!ZagSupabaseAuth().isSignedIn) return [];

    try {
      final userId = ZagSupabaseAuth().uid;
      final userEmail = ZagSupabaseAuth().email;

      // Query by user_id OR email
      final response = await _client
          .from('subscription_shares')
          .select()
          .eq('status', 'active')
          .or('shared_with_user_id.eq.$userId,shared_with_email.eq.${userEmail?.toLowerCase()}')
          .order('created_at', ascending: false);

      return (response as List)
          .map((map) => SubscriptionShare.fromMap(map))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to get received shares', error, stack);
      return [];
    }
  }

  /// Grant share to an email address
  Future<({bool success, String? error, String? shareId})> grantShareByEmail({
    required String email,
    required String productId,
    required DateTime expiresAt,
  }) async {
    if (!ZagSupabaseAuth().isSignedIn) {
      return (success: false, error: 'Not signed in', shareId: null);
    }

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('grant_share_by_email', params: {
        'p_owner_user_id': userId,
        'p_owner_product_id': productId,
        'p_owner_expires_at': expiresAt.toUtc().toIso8601String(),
        'p_recipient_email': email.toLowerCase().trim(),
      });

      final result = response as Map<String, dynamic>;
      return (
        success: result['success'] as bool? ?? false,
        error: result['error'] as String?,
        shareId: result['share_id'] as String?,
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to grant share by email', error, stack);
      return (success: false, error: error.toString(), shareId: null);
    }
  }

  /// Link email-based share to user (called automatically on sign-in)
  Future<bool> linkEmailShareToUser(String shareId, String email) async {
    if (!ZagSupabaseAuth().isSignedIn) return false;

    try {
      final userId = ZagSupabaseAuth().uid;
      final response = await _client.rpc('link_email_share_to_user', params: {
        'p_user_id': userId,
        'p_user_email': email.toLowerCase().trim(),
        'p_share_id': shareId,
      });

      return response as bool? ?? false;
    } catch (error, stack) {
      ZagLogger().error('Failed to link email share to user', error, stack);
      return false;
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
