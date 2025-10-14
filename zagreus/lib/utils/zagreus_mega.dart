import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagreusMega {

  // RevenueCat is the ONLY source of truth
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
  }

  /// Apply subscription data sourced from RevenueCat ONLY.
  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) {
    final expiryUtc = expiresAt.toUtc();
    print('🔐 Mega: Setting expiry to $expiryUtc for product $productId');

    ZagreusDatabase.ZAGREUS_MEGA_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_MEGA_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    // Mega includes Pro features, so set up boot module on first activation
    ZagreusPro.setProBootModule();
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
