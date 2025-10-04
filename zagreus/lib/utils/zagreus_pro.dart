import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/utils/zagreus_mega.dart';

class ZagreusPro {

  // RevenueCat is the ONLY source of truth
  static bool get isEnabled {
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

    _setProBootModule();
  }


  static void disable() {
    _disablePro();
  }

  static void _setProBootModule() {
    try {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      final userModuleSaved = ZagreusDatabase.USER_BOOT_MODULE.read();

      // Set to Discover if not already, and save user's preference
      if (currentModule != ZagModule.DISCOVER) {
        // Only save current as user preference if we haven't saved one yet
        // (dashboard is the default, so if it's still dashboard, this is first time)
        if (userModuleSaved == 'dashboard' || userModuleSaved.isEmpty) {
          ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
        }
        // Always set to Discover when Pro is activated
        BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
        print('Pro activated: Setting boot module to Discover');
      }
    } catch (e) {
      print('Error setting Pro boot module: $e');
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
