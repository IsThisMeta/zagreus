import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';

/// Singleton service for caching subscription tier status
///
/// Checks premium status once at app boot and caches in memory.
/// Call refresh() when subscriptions change (purchase/restore/expiry).
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isPremium = false;
  bool _isInitialized = false;

  /// Initialize and cache subscription status
  void initialize() {
    _refreshCache();
    _isInitialized = true;

    // Also check for shared Pro access from Supabase
    ZagreusPro.checkSharedAccess();
  }

  /// Refresh cached subscription status
  /// Call this when subscriptions change (purchase, restore, expiry)
  void refresh() {
    _refreshCache();

    // Also recheck shared access
    ZagreusPro.checkSharedAccess();
  }

  void _refreshCache() {
    _isPremium = ZagreusPro.isEnabled ||
                 ZagreusMega.isEnabled ||
                 ZagreusUltra.isEnabled ||
                 ZagreusSupreme.isEnabled;
  }

  /// Check if user has any premium tier (Pro/Mega/Ultra/Supreme)
  /// Returns cached value - no DB reads!
  static bool get isPremium {
    if (!_instance._isInitialized) {
      // Fallback to live check if service not initialized
      return ZagreusPro.isEnabled ||
             ZagreusMega.isEnabled ||
             ZagreusUltra.isEnabled ||
             ZagreusSupreme.isEnabled;
    }
    return _instance._isPremium;
  }
}
