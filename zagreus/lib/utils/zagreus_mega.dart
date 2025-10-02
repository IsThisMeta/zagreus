import 'package:zagreus/database/tables/zagreus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';

class ZagreusMega {

  static bool? _cachedMegaStatus;
  static DateTime? _cacheExpiry;

  /// Clear the cached Mega status (useful for testing)
  static void clearCache() {
    _cachedMegaStatus = null;
    _cacheExpiry = null;
  }

  static Future<bool> get isEnabledAsync async {
    // Check cache first (valid for 5 minutes)
    if (_cachedMegaStatus != null &&
        _cacheExpiry != null &&
        DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedMegaStatus!;
    }

    // Try to check Supabase first
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Check subscription in database
        final response = await supabase
            .rpc('has_active_mega', params: {'p_user_id': user.id});

        if (response != null) {
          _cachedMegaStatus = response as bool;
          _cacheExpiry = DateTime.now().add(Duration(minutes: 5));

          // Update local storage to match server
          if (_cachedMegaStatus!) {
            ZagreusDatabase.ZAGREUS_MEGA_ENABLED.update(true);
          } else {
            _disableMega();
          }

          return _cachedMegaStatus!;
        }
      }
    } catch (e) {
      print('Error checking Mega status from server: $e');
    }

    // Fallback to local storage
    return isEnabled;
  }

  // Synchronous version for backward compatibility
  static bool get isEnabled {
    // Check if Mega is enabled locally
    if (!ZagreusDatabase.ZAGREUS_MEGA_ENABLED.read()) {
      return false;
    }

    // Check if subscription has expired
    final expiryString = ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.read();
    if (expiryString.isEmpty) {
      print('⚠️ Mega: No expiry date set - disabling Mega');
      _disableMega();
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      final now = DateTime.now().toUtc();

      if (now.isAfter(expiry)) {
        print('⏰ Mega: Subscription expired (was: $expiry, now: $now) - disabling');
        _disableMega();
        return false;
      }

      // Log time remaining on first check
      final remaining = expiry.difference(now);
      if (remaining.inMinutes < 60) {
        print('⏳ Mega: Active - expires in ${remaining.inMinutes} minutes');
      }
    } catch (e) {
      print('❌ Mega: Invalid expiry date - disabling');
      _disableMega();
      return false;
    }

    return true;
  }

  static void _disableMega() {
    ZagreusDatabase.ZAGREUS_MEGA_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_MEGA_SUBSCRIPTION_TYPE.update('');
    clearCache();
  }

  /// Apply subscription data sourced from Apple/Supabase.
  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) async {
    final expiryUtc = expiresAt.toUtc();
    print('🔐 Mega: Setting expiry to $expiryUtc for product $productId');

    ZagreusDatabase.ZAGREUS_MEGA_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_MEGA_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    clearCache();

    // Sync to Supabase for backend verification
    await _syncToSupabase(expiryUtc, productId);
  }

  static Future<void> _syncToSupabase(DateTime expiresAt, String productId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        await supabase.rpc('upsert_subscription', params: {
          'p_user_id': user.id,
          'p_product_id': productId,
          'p_subscription_type': 'mega',
          'p_expires_at': expiresAt.toIso8601String(),
        });
        print('✅ Synced Mega subscription to Supabase');
      } else {
        print('⚠️ No authenticated user - skipping Supabase sync');
      }
    } catch (e) {
      print('⚠️ Failed to sync Mega subscription to Supabase: $e');
      // Don't throw - local storage still works
    }
  }

  static void disable() {
    _disableMega();
  }

  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.read();
    if (expiryString.isEmpty) return true;

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_MEGA_SUBSCRIPTION_TYPE.read();
  }

  static String _subscriptionTypeFromProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('year')) return 'yearly';
    if (lower.contains('month')) return 'monthly';
    return lower;
  }
}
