import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';

class ZagreusPro {

  // RevenueCat is the ONLY source of truth
  static bool get isEnabled {
    if (ZagreusUltra.isEnabled) {
      return true;
    }

    // Check if Mega is enabled (includes Pro)
    if (ZagreusMega.isEnabled) {
      return true;
    }

    // Check if Pro is enabled locally
    if (!ZagreusDatabase.ZAGREUS_PRO_ENABLED.read()) {
      return false;
    }

    // Check if subscription has expired
    final expiryString = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    if (expiryString.isEmpty) {
      print('⚠️ Pro: No expiry date set - disabling Pro');
      _disablePro();
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      final now = DateTime.now().toUtc();

      if (now.isAfter(expiry)) {
        print('⏰ Pro: Subscription expired (was: $expiry, now: $now) - disabling');
        _disablePro();
        return false;
      }

      // Log time remaining on first check
      final remaining = expiry.difference(now);
      if (remaining.inMinutes < 60) {
        print('⏳ Pro: Active - expires in ${remaining.inMinutes} minutes');
      }
    } catch (e) {
      print('❌ Pro: Invalid expiry date - disabling');
      _disablePro();
      return false;
    }

    return true;
  }

  static void _disablePro() {
    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update('');
    if (ZagreusDatabase.SETTINGS_LOCK_ENABLED.read()) {
      ZagreusDatabase.SETTINGS_LOCK_ENABLED.update(false);
      ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC.update(false);
    }

    restoreBootModule();
  }

  /// Restore boot module when all premium tiers are disabled
  static void restoreBootModule() {
    // Only restore if no premium tier is active
    if (ZagreusDatabase.ZAGREUS_PRO_ENABLED.read() ||
        ZagreusDatabase.ZAGREUS_MEGA_ENABLED.read() ||
        ZagreusDatabase.ZAGREUS_ULTRA_ENABLED.read()) {
      print('Premium still active, keeping Discover boot module');
      return;
    }

    // All premium tiers disabled - restore user's preference
    final userPreference = ZagreusDatabase.USER_BOOT_MODULE.read();
    if (userPreference.isNotEmpty) {
      final preferredModule = ZagModule.fromKey(userPreference);
      if (preferredModule != null && preferredModule != ZagModule.DISCOVER) {
        BIOSDatabase.BOOT_MODULE.update(preferredModule);
        print('Premium expired: Restoring boot module to $userPreference');
        return;
      }
    }

    // No preference saved, default to DASHBOARD
    BIOSDatabase.BOOT_MODULE.update(ZagModule.DASHBOARD);
    print('Premium expired: Restoring boot module to DASHBOARD');
  }

  /// Apply subscription data sourced from RevenueCat ONLY.
  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) {
    final expiryUtc = expiresAt.toUtc();
    print('🔐 Pro: Setting expiry to $expiryUtc for product $productId');

    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    setProBootModule();
  }


  static void disable() {
    _disablePro();
  }

  /// Set boot module to Discover for premium users
  /// Public so it can be called from Pro, Mega, or Ultra helpers
  static void setProBootModule() {
    try {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();

      // If already on Discover, nothing to do
      if (currentModule == ZagModule.DISCOVER) {
        print('Boot module already set to Discover');
        return;
      }

      // Save current module as user preference (for when premium expires)
      ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);

      // Set boot module to Discover (premium Dashboard)
      BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);

      print('Premium tier active: Setting boot module to Discover');
    } catch (e) {
      print('Error setting premium boot module: $e');
    }
  }

  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    if (expiryString.isEmpty) return true;

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.read();
  }

  static String _subscriptionTypeFromProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('year')) return 'yearly';
    if (lower.contains('month')) return 'monthly';
    return lower;
  }
}
