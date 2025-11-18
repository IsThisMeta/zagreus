import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagreusUltra {
  static bool get isEnabled {
    if (!ZagreusDatabase.ZAGREUS_ULTRA_ENABLED.read()) {
      return false;
    }

    final expiryString = ZagreusDatabase.ZAGREUS_ULTRA_EXPIRY.read();
    if (expiryString.isEmpty) {
      print('⚠️ Ultra: No expiry date set - disabling Ultra');
      _disableUltra();
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      final now = DateTime.now().toUtc();

      if (now.isAfter(expiry)) {
        print('⏰ Ultra: Subscription expired (was: $expiry, now: $now) - disabling');
        _disableUltra();
        return false;
      }

      final remaining = expiry.difference(now);
      if (remaining.inMinutes < 60) {
        print('⏳ Ultra: Active - expires in ${remaining.inMinutes} minutes');
      }
    } catch (e) {
      print('❌ Ultra: Invalid expiry date - disabling');
      _disableUltra();
      return false;
    }

    return true;
  }

  static void _disableUltra() {
    ZagreusDatabase.ZAGREUS_ULTRA_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_ULTRA_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_ULTRA_SUBSCRIPTION_TYPE.update('');

    ZagreusPro.restoreBootModule();
  }

  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) {
    final expiryUtc = expiresAt.toUtc();
    print('🔐 Ultra: Setting expiry to $expiryUtc for product $productId');

    ZagreusDatabase.ZAGREUS_ULTRA_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_ULTRA_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_ULTRA_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    ZagreusPro.setProBootModule();
  }

  static void disable() {
    _disableUltra();
  }

  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_ULTRA_EXPIRY.read();
    if (expiryString.isEmpty) return true;

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_ULTRA_SUBSCRIPTION_TYPE.read();
  }

  static String _subscriptionTypeFromProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('year')) return 'yearly';
    if (lower.contains('month')) return 'monthly';
    return lower;
  }
}
