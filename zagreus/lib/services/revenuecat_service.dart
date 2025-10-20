import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'appl_rUDwskSqmGCotcUTmqthnGgYCFq';
  static const String _proEntitlementId = 'Pro';  // Monthly Pro
  static const String _proYearlyEntitlementId = 'Pro Yearly';  // Yearly Pro
  static const String _megaEntitlementId = 'Mega';  // Mega entitlement for Z Assistant
  static const String _ultraEntitlementId = 'Ultra';  // Ultra entitlement for top-tier AI

  CustomerInfo? _customerInfo;
  bool _isUpdating = false; // Prevent duplicate updates

  // Public getter for customer info
  CustomerInfo? get customerInfo => _customerInfo;

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

      // NSA backdoor initialized
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
    // Prevent duplicate updates from happening simultaneously
    if (_isUpdating) {
      print('⏭️ RevenueCat: Update already in progress, skipping...');
      return;
    }
    _isUpdating = true;

    print('🔍 RevenueCat: Checking entitlements...');

    // Check Pro entitlements (monthly + yearly) and pick the one with the longer expiry
    final proMonthlyEntitlement = _customerInfo?.entitlements.all[_proEntitlementId];
    final proYearlyEntitlement = _customerInfo?.entitlements.all[_proYearlyEntitlementId];
    final activeProEntitlement = [
      if (proMonthlyEntitlement?.isActive ?? false) proMonthlyEntitlement!,
      if (proYearlyEntitlement?.isActive ?? false) proYearlyEntitlement!,
    ].fold<EntitlementInfo?>(null, (best, current) {
      if (best == null) return current;

      DateTime? bestExpiry;
      DateTime? currentExpiry;
      try {
        final raw = best.expirationDate;
        if (raw != null) bestExpiry = DateTime.parse(raw);
      } catch (_) {}
      try {
        final raw = current.expirationDate;
        if (raw != null) currentExpiry = DateTime.parse(raw);
      } catch (_) {}

      if (bestExpiry == null && currentExpiry == null) {
        // Neither has expiry info – prefer the current (likely most recent purchase)
        return current;
      }
      if (bestExpiry == null) return current;
      if (currentExpiry == null) return best;

      return currentExpiry.isAfter(bestExpiry) ? current : best;
    });

    if (activeProEntitlement != null) {
      final expirationDate = activeProEntitlement.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        final productId = activeProEntitlement.productIdentifier ?? 'revenuecat_pro';
        final entitlementId = activeProEntitlement.identifier;
        print('🎯 RevenueCat: Pro active until $expiry (entitlement: $entitlementId, product: $productId)');

        // Update local storage from RevenueCat (source of truth)
        ZagreusPro.applySubscription(
          expiresAt: expiry,
          productId: productId,
        );

        // STILL sync to Supabase - backend needs this for verification
        await _syncToSupabase('pro', expiry, productId);
      } else {
        // Active but no expiration date - this shouldn't happen for subscriptions
        print('⚠️ RevenueCat: Pro marked active but no expiration date');
        ZagreusPro.disable();
      }
    } else {
      print('📵 RevenueCat: Pro not active');
      ZagreusPro.disable();
    }

    // Check Ultra entitlement (highest tier)
    final ultraEntitlement = _customerInfo?.entitlements.all[_ultraEntitlementId];
    final isUltraActive = ultraEntitlement?.isActive ?? false;

    if (isUltraActive) {
      final expirationDate = ultraEntitlement?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        final productId = ultraEntitlement?.productIdentifier ?? 'com.zagreus.ultra.monthly';
        print('🎯 RevenueCat: Ultra active until $expiry (product: $productId)');

        ZagreusUltra.applySubscription(
          expiresAt: expiry,
          productId: productId,
        );

        // Ensure base Pro features remain marked as active
        ZagreusPro.applySubscription(
          expiresAt: expiry,
          productId: productId,
        );

        // Ultra subsume Mega/Pro benefits
        ZagreusMega.disable();

        await _syncToSupabase('ultra', expiry, productId);
      } else {
        print('⚠️ RevenueCat: Ultra marked active but no expiration date');
        ZagreusUltra.disable();
      }
    } else {
      ZagreusUltra.disable();

      // Check Mega entitlement
      final megaEntitlement = _customerInfo?.entitlements.all[_megaEntitlementId];
      final isMegaActive = megaEntitlement?.isActive ?? false;

      if (isMegaActive) {
        final expirationDate = megaEntitlement?.expirationDate;
        if (expirationDate != null) {
          final expiry = DateTime.parse(expirationDate);
          final productId = megaEntitlement?.productIdentifier ?? 'revenuecat_mega';
          print('🎯 RevenueCat: Mega active until $expiry (product: $productId)');

          // Update local storage from RevenueCat (source of truth)
          ZagreusMega.applySubscription(
            expiresAt: expiry,
            productId: productId,
          );

          // STILL sync to Supabase - backend needs this for Z Assistant verification
          await _syncToSupabase('mega', expiry, productId);
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

    _isUpdating = false; // Reset the flag
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
        // Don't show toast here - will show at the end
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
      ZagLogger().debug('🔄 RevenueCat: Starting restore...');
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;

      // Debug logging - but don't show to user
      ZagLogger().debug('🔍 ALL Entitlements: ${customerInfo.entitlements.all.keys}');
      ZagLogger().debug('🔍 ACTIVE Entitlements: ${customerInfo.entitlements.active.keys}');

      // Debug each entitlement
      customerInfo.entitlements.all.forEach((key, entitlement) {
        ZagLogger().debug('📦 Entitlement "$key": active=${entitlement.isActive}, productId=${entitlement.productIdentifier}');
      });

      ZagLogger().debug('🔍 Looking for Pro Monthly: "$_proEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_proEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Pro Yearly: "$_proYearlyEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_proYearlyEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Mega: "$_megaEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_megaEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Ultra: "$_ultraEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_ultraEntitlementId)}');

      _updateProStatus();

      // Only show ONE toast with the final result
      final hasAny = isUltraActive || isMegaActive || isProActive;
      if (hasAny) {
        final subscriptionType = isUltraActive
            ? 'Ultra'
            : (isMegaActive ? 'Mega' : 'Pro');
        showZagInfoSnackBar(
          title: 'Restored Successfully',
          message: 'Your $subscriptionType subscription is active.',
        );
      } else {
        showZagInfoSnackBar(
          title: 'Nothing to Restore',
          message: 'No active subscriptions found.',
        );
      }
    } catch (e) {
      ZagLogger().error('❌ Restore failed', e, StackTrace.current);
      showZagInfoSnackBar(
        title: 'Restore Failed',
        message: 'Please try again later.',
      );
    }
  }

  bool get isUltraActive =>
    (_customerInfo?.entitlements.all[_ultraEntitlementId]?.isActive ?? false) ||
    ZagreusUltra.isEnabled;

  bool get isMegaActive =>
    (_customerInfo?.entitlements.all[_megaEntitlementId]?.isActive ?? false) ||
    ZagreusMega.isEnabled ||
    isUltraActive;

  bool get isProActive =>
    (_customerInfo?.entitlements.all[_proEntitlementId]?.isActive ?? false) ||
    (_customerInfo?.entitlements.all[_proYearlyEntitlementId]?.isActive ?? false) ||
    isMegaActive;

  bool get isAvailable => true; // RevenueCat handles availability internally

  Future<bool> purchaseMega(bool isMonthly) async {
    try {
      // Get available packages from mega offering
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');

      // Get the "mega" offering
      final megaOffering = offerings.all['mega'];

      if (megaOffering == null) {
        print('❌ No mega offering found');
        // Don't show intermediate errors
        return false;
      }

      final packages = megaOffering.availablePackages;

      if (packages.isEmpty) {
        print('❌ No packages in mega offering');
        // Don't show intermediate errors
        return false;
      }

      // Find monthly package (for now we only have monthly)
      final monthlyPackage = packages.firstWhereOrNull(
        (pkg) => pkg.identifier == '\$rc_monthly' || pkg.packageType == PackageType.monthly
      ) ?? packages.first;

      print('📦 Purchasing Mega package: ${monthlyPackage.identifier}');

      // Make purchase
      final result = await Purchases.purchasePackage(monthlyPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Mega!',
        message: 'Z Assistant features are now unlocked.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        return false;
      }
      print('❌ Mega purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }

  Future<bool> purchaseUltra() async {
    try {
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');

      final ultraOffering = offerings.all['ultra'];
      List<Package> packages = [];

      if (ultraOffering != null) {
        packages = ultraOffering.availablePackages;
      }

      if (packages.isEmpty) {
        // Fallback: scan all offerings for the Ultra product
        for (final entry in offerings.all.entries) {
          final match = entry.value.availablePackages.firstWhereOrNull(
            (pkg) => pkg.storeProduct.identifier == 'com.zagreus.ultra.monthly',
          );
          if (match != null) {
            packages = [match];
            break;
          }
        }
      }

      if (packages.isEmpty) {
        print('❌ No Ultra packages found in offerings');
        return false;
      }

      final desiredId = 'com.zagreus.ultra.monthly';
      final monthlyPackage = packages.firstWhereOrNull(
            (pkg) =>
                pkg.storeProduct.identifier == desiredId ||
                pkg.identifier == '\$rc_monthly' ||
                pkg.packageType == PackageType.monthly,
          ) ??
          packages.first;

      print('📦 Purchasing Ultra package: ${monthlyPackage.identifier}');

      final result = await Purchases.purchasePackage(monthlyPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Ultra!',
        message: 'Ultra AI features are now unlocked.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      print('❌ Ultra purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }

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
        // Don't show intermediate errors
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
