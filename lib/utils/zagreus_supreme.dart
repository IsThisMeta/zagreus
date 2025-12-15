import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagreusSupreme {
  static bool get isEnabled {
    if (!ZagreusDatabase.ZAGREUS_SUPREME_ENABLED.read()) {
      return false;
    }

    final expiryString = ZagreusDatabase.ZAGREUS_SUPREME_EXPIRY.read();
    if (expiryString.isEmpty) {
      print('⚠️ Supreme: No expiry date set - disabling Supreme');
      _disableSupreme();
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      final now = DateTime.now().toUtc();

      if (now.isAfter(expiry)) {
        print('⏰ Supreme: Subscription expired (was: $expiry, now: $now) - disabling');
        _disableSupreme();
        return false;
      }

      final remaining = expiry.difference(now);
      if (remaining.inMinutes < 60) {
        print('⏳ Supreme: Active - expires in ${remaining.inMinutes} minutes');
      }
    } catch (e) {
      print('❌ Supreme: Invalid expiry date - disabling');
      _disableSupreme();
      return false;
    }

    return true;
  }

  static void _disableSupreme() {
    ZagreusDatabase.ZAGREUS_SUPREME_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_SUPREME_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_SUPREME_SUBSCRIPTION_TYPE.update('');

    ZagreusPro.restoreBootModule();
  }

  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) {
    final expiryUtc = expiresAt.toUtc();
    print('🔐 Supreme: Setting expiry to $expiryUtc for product $productId');

    ZagreusDatabase.ZAGREUS_SUPREME_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_SUPREME_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_SUPREME_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    ZagreusPro.setProBootModule();
  }

  static void disable() {
    _disableSupreme();
  }

  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_SUPREME_EXPIRY.read();
    if (expiryString.isEmpty) return true;

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_SUPREME_SUBSCRIPTION_TYPE.read();
  }

  static String _subscriptionTypeFromProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('year')) return 'yearly';
    if (lower.contains('month')) return 'monthly';
    return lower;
  }
}
