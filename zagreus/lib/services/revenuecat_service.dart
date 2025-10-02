import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'appl_rUDwskSqmGCotcUTmqthnGgYCFq';
  static const String _proEntitlementId = 'Pro';  // Note: Uppercase 'Pro' as shown in dashboard
  static const String _megaEntitlementId = 'Mega';  // Mega entitlement for Z Assistant

  CustomerInfo? _customerInfo;

  Future<void> initialize() async {
    try {
      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = null // Let RevenueCat generate anonymous ID
      );

      // Enable debug logs in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Get initial customer info
      await updateCustomerInfo();

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo = customerInfo;
        _updateProStatus();
      });

      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      print('❌ RevenueCat initialization failed: $e');
    }
  }

  Future<void> updateCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus();
    } catch (e) {
      print('❌ Failed to get customer info: $e');
    }
  }

  void _updateProStatus() async {
    print('🔍 RevenueCat: Checking entitlements...');
    print('🔍 All entitlements: ${_customerInfo?.entitlements.all.keys}');
    print('🔍 Active entitlements: ${_customerInfo?.entitlements.active.keys}');

    // Check Pro entitlement
    final isProActive = _customerInfo?.entitlements.all[_proEntitlementId]?.isActive ?? false;
    print('🔍 Pro entitlement "$_proEntitlementId" active: $isProActive');

    if (isProActive) {
      final expirationDate = _customerInfo?.entitlements.all[_proEntitlementId]?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        print('🎯 RevenueCat: Pro active until $expiry');

        // Update local storage
        ZagreusPro.applySubscription(
          expiresAt: expiry,
          productId: 'revenuecat_pro',
        );

        // Sync to Supabase for backend verification
        await _syncToSupabase('pro', expiry, 'revenuecat_pro');
      } else {
        // Active but no expiration date - this shouldn't happen for subscriptions
        print('⚠️ RevenueCat: Pro marked active but no expiration date');
        ZagreusPro.disable();
      }
    } else {
      print('📵 RevenueCat: Pro not active');
      ZagreusPro.disable();
    }

    // Check Mega entitlement
    final isMegaActive = _customerInfo?.entitlements.all[_megaEntitlementId]?.isActive ?? false;
    print('🔍 Mega entitlement "$_megaEntitlementId" active: $isMegaActive');

    if (isMegaActive) {
      final expirationDate = _customerInfo?.entitlements.all[_megaEntitlementId]?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        print('🎯 RevenueCat: Mega active until $expiry');

        // Update local storage
        ZagreusMega.applySubscription(
          expiresAt: expiry,
          productId: 'revenuecat_mega',
        );

        // Sync to Supabase for backend verification
        await _syncToSupabase('mega', expiry, 'revenuecat_mega');
      } else {
        // Active but no expiration date
        print('⚠️ RevenueCat: Mega marked active but no expiration date');
        ZagreusMega.disable();
      }
    } else {
      print('📵 RevenueCat: Mega not active');
      ZagreusMega.disable();
    }
  }

  Future<void> _syncToSupabase(String subscriptionType, DateTime expiresAt, String productId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        await supabase.rpc('upsert_subscription', params: {
          'p_user_id': user.id,
          'p_product_id': productId,
          'p_subscription_type': subscriptionType,
          'p_expires_at': expiresAt.toUtc().toIso8601String(),
        });
        print('✅ Synced $subscriptionType subscription to Supabase');
      } else {
        print('⚠️ No authenticated user - skipping Supabase sync');
      }
    } catch (e) {
      print('⚠️ Failed to sync subscription to Supabase: $e');
      // Don't throw - local storage still works
    }
  }

  Future<bool> purchaseMonthly() async {
    try {
      // Get available packages
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');
      print('🔍 Current offering: ${offerings.current?.identifier}');
      print('🔍 Available packages: ${offerings.current?.availablePackages.map((p) => p.identifier).toList()}');

      // Try to find monthly package by identifier, or just use the first available package
      final packages = offerings.current?.availablePackages ?? [];
      final monthlyPackage = packages.isNotEmpty
          ? packages.firstWhere(
              (pkg) => pkg.identifier == '\$rc_monthly',
              orElse: () => packages.first,
            )
          : null;

      if (monthlyPackage == null) {
        print('❌ No monthly package found in offerings');
        showZagInfoSnackBar(
          title: 'Error',
          message: 'Monthly subscription not available',
        );
        return false;
      }

      // Make purchase
      final result = await Purchases.purchasePackage(monthlyPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Pro!',
        message: 'Premium features are now unlocked.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        return false;
      }
      print('❌ Purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      print('🔄 RevenueCat: Starting restore...');
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;

      print('🔍 Entitlements: ${customerInfo.entitlements.all.keys}');
      print('🔍 Pro entitlement: ${customerInfo.entitlements.all[_proEntitlementId]}');
      print('🔍 Is Pro active: ${customerInfo.entitlements.all[_proEntitlementId]?.isActive}');
      print('🔍 Mega entitlement: ${customerInfo.entitlements.all[_megaEntitlementId]}');
      print('🔍 Is Mega active: ${customerInfo.entitlements.all[_megaEntitlementId]?.isActive}');
      print('🔍 All active purchases: ${customerInfo.activeSubscriptions}');
      print('🔍 All purchases: ${customerInfo.allPurchasedProductIdentifiers}');

      _updateProStatus();

      final hasProOrMega = (isProActive || isMegaActive);
      if (hasProOrMega) {
        showZagInfoSnackBar(
          title: 'Subscription Restored',
          message: 'Your Pro subscription has been restored.',
        );
      } else {
        showZagInfoSnackBar(
          title: 'No Subscription Found',
          message: 'No active subscription to restore.',
        );
      }
    } catch (e) {
      print('❌ Restore failed: $e');
      showZagInfoSnackBar(
        title: 'Restore Failed',
        message: 'Unable to restore purchases',
      );
    }
  }

  bool get isProActive =>
    _customerInfo?.entitlements.all[_proEntitlementId]?.isActive ?? false;

  bool get isMegaActive =>
    _customerInfo?.entitlements.all[_megaEntitlementId]?.isActive ?? false;

  bool get isAvailable => true; // RevenueCat handles availability internally

  Future<bool> purchaseYearly() async {
    try {
      // Get available packages
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');
      print('🔍 Current offering: ${offerings.current?.identifier}');
      print('🔍 Available packages: ${offerings.current?.availablePackages.map((p) => p.identifier).toList()}');

      // Also check all offerings, not just current
      for (final entry in offerings.all.entries) {
        print('📱 Offering "${entry.key}": ${entry.value.availablePackages.map((p) => '${p.identifier} (${p.packageType})').toList()}');
      }

      // Try to find yearly package by identifier
      final packages = offerings.current?.availablePackages ?? [];

      // Log all packages for debugging
      for (final pkg in packages) {
        print('📦 Package: ${pkg.identifier}, Type: ${pkg.packageType}, Price: ${pkg.storeProduct.priceString}');
      }

      // Find yearly package - try multiple approaches
      Package? yearlyPackage;

      // First try by identifier
      yearlyPackage = packages.firstWhereOrNull(
        (pkg) => pkg.identifier == '\$rc_annual'
      );

      // Then try by package type
      if (yearlyPackage == null) {
        yearlyPackage = packages.firstWhereOrNull(
          (pkg) => pkg.packageType == PackageType.annual
        );
      }

      // Then try by custom identifier (in case you named it differently)
      if (yearlyPackage == null) {
        yearlyPackage = packages.firstWhereOrNull(
          (pkg) => pkg.identifier.toLowerCase().contains('year') ||
                   pkg.identifier.toLowerCase().contains('annual')
        );
      }

      // Try looking for specific product ID
      if (yearlyPackage == null) {
        yearlyPackage = packages.firstWhereOrNull(
          (pkg) => pkg.storeProduct.identifier.contains('yearly') ||
                   pkg.storeProduct.identifier.contains('annual')
        );
      }

      // Check if there's a second package at all
      if (yearlyPackage == null && packages.length > 1) {
        print('⚠️ Multiple packages found but none match yearly criteria. Using index 1.');
        yearlyPackage = packages[1]; // If monthly is first, yearly might be second
      }

      // Last resort - pick the more expensive one (yearly should cost more)
      if (yearlyPackage == null && packages.length >= 2) {
        packages.sort((a, b) => b.storeProduct.price.compareTo(a.storeProduct.price));
        yearlyPackage = packages.first; // Most expensive should be yearly
      }

      if (yearlyPackage == null) {
        print('❌ No yearly package found in offerings');
        showZagInfoSnackBar(
          title: 'Error',
          message: 'Yearly subscription not available',
        );
        return false;
      }

      // Make purchase
      final result = await Purchases.purchasePackage(yearlyPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Pro!',
        message: 'Premium features are now unlocked for a year.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        return false;
      }
      print('❌ Purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }
}