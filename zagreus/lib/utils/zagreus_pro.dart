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

  /// Set up boot module for first premium activation (Pro/Mega/Ultra)
  /// Public so it can be called from Pro, Mega, or Ultra helpers
  static void setProBootModule() {
    try {
      // Check if we've already done the first-time setup
      if (ZagreusDatabase.ZAGREUS_PRO_FIRST_ACTIVATION_COMPLETE.read()) {
        print('Premium tier already activated before - respecting boot module preference');
        return;
      }

      // First time a premium tier is being activated - set up boot module
      final currentModule = BIOSDatabase.BOOT_MODULE.read();

      // Save current module as user preference (for when they toggle off)
      if (currentModule != ZagModule.DISCOVER) {
        ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
      }

      // Set boot module to Dashboard
      BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);

      // Mark first activation as complete so we don't do this again
      ZagreusDatabase.ZAGREUS_PRO_FIRST_ACTIVATION_COMPLETE.update(true);

      print('Premium tier first activation: Setting boot module to Dashboard');
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
