import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';
import 'package:zagreus/system/network/local_switching_service.dart';
import 'package:zagreus/services/subscription_service.dart';
import 'package:zagreus/supabase/subscription_shares.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'appl_rUDwskSqmGCotcUTmqthnGgYCFq';
  static const String _proEntitlementId = 'Pro';  // Monthly Pro
  static const String _proYearlyEntitlementId = 'Pro Yearly';  // Yearly Pro
  static const String _proLifetimeEntitlementId = 'Pro Lifetime';  // Lifetime Pro
  static const String _megaEntitlementId = 'Mega';  // Mega entitlement for Z-Bot
  static const String _ultraEntitlementId = 'Ultra';  // Ultra entitlement for top-tier AI
  static const String _supremeEntitlementId = 'Supreme';  // Supreme entitlement for GPT-5-Pro
  static const String proMonthlyProductId = 'com.zagreus.pro.monthly.v2';
  static const String proYearlyProductId = 'com.zagreus.pro.yearly';
  static const String proLifetimeProductId = 'com.zagreus.pro.lifetime';
  static const String megaMonthlyProductId = 'com.zagreus.mega.monthly';
  static const String megaYearlyProductId = 'com.zagreus.mega.yearly';
  static const String ultraMonthlyProductId = 'com.zagreus.ultra.monthly';
  static const String ultraYearlyProductId = 'com.zagreus.ultra.yearly';
  static const String supremeMonthlyProductId = 'com.zagreus.supreme.monthly';
  static const String supremeYearlyProductId = 'com.zagreus.supreme.yearly';

  CustomerInfo? _customerInfo;
  bool _isUpdating = false; // Prevent duplicate updates
  bool _isConfigured = false;
  final Map<String, IntroEligibilityStatus> _trialEligibilityCache = {};

  // Public getter for customer info
  CustomerInfo? get customerInfo => _customerInfo;
  bool get isConfigured => _isConfigured;

  Future<void> initialize() async {
    try {
      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = null // Let RevenueCat generate anonymous ID
      );
      _isConfigured = true;

      // Enable minimal logging in debug mode to avoid JWT token spam
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.info);
      }

      // NSA backdoor initialized
      // Get initial customer info (without triggering status update yet)
      _customerInfo = await Purchases.getCustomerInfo();

      // Listen to customer info updates (this will fire immediately and update status)
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

    // Check Pro Lifetime entitlement first (takes priority)
    final proLifetimeEntitlement = _customerInfo?.entitlements.all[_proLifetimeEntitlementId];
    final isProLifetimeActive = proLifetimeEntitlement?.isActive ?? false;

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

    final supremeEntitlement = _customerInfo?.entitlements.all[_supremeEntitlementId];
    final ultraEntitlement = _customerInfo?.entitlements.all[_ultraEntitlementId];
    final megaEntitlement = _customerInfo?.entitlements.all[_megaEntitlementId];

    final isSupremeActive = supremeEntitlement?.isActive ?? false;
    final isUltraActive = ultraEntitlement?.isActive ?? false;
    final isMegaActive = megaEntitlement?.isActive ?? false;
    final hasHigherTier = isSupremeActive || isUltraActive || isMegaActive;

    // Handle Pro Lifetime first (takes priority, no expiry)
    if (isProLifetimeActive) {
      final productId = proLifetimeEntitlement?.productIdentifier ?? proLifetimeProductId;
      print('🎯 RevenueCat: Pro Lifetime active (product: $productId)');

      // Apply lifetime subscription with far-future expiry
      ZagreusPro.applyLifetimeSubscription(productId: productId);
    } else if (activeProEntitlement != null) {
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

        // Note: Backend syncs subscription during device registration
      } else {
        // Active but no expiration date - this shouldn't happen for subscriptions
        print('⚠️ RevenueCat: Pro marked active but no expiration date');
        ZagreusPro.disable();
      }
    } else {
      if (hasHigherTier) {
        print('📵 RevenueCat: Pro not active (higher tier active)');
      } else {
        print('📵 RevenueCat: Pro not active');
        ZagreusPro.disable();
      }
    }

    // Check Supreme entitlement (highest tier)

    if (isSupremeActive) {
      final expirationDate = supremeEntitlement?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        final productId =
            supremeEntitlement?.productIdentifier ?? supremeMonthlyProductId;
        print('🎯 RevenueCat: Supreme active until $expiry (product: $productId)');

        ZagreusSupreme.applySubscription(
          expiresAt: expiry,
          productId: productId,
        );

        // Ensure base Pro features remain marked as active
        ZagreusPro.applySubscription(
          expiresAt: expiry,
          productId: productId,
        );

        // Sync to Supabase for share management (Supreme gets 10 shares)
        ZagSupabaseShares().syncMasterSubscription(
          productId: productId,
          expiresAt: expiry,
        );

        // Supreme subsumes Ultra/Mega/Pro benefits
        ZagreusUltra.disable();
        ZagreusMega.disable();
      } else {
        print('⚠️ RevenueCat: Supreme marked active but no expiration date');
        ZagreusSupreme.disable();
      }
    } else {
      print('📵 RevenueCat: Supreme not active');
      ZagreusSupreme.disable();

      // Check Ultra entitlement

      if (isUltraActive) {
      final expirationDate = ultraEntitlement?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        final productId =
            ultraEntitlement?.productIdentifier ?? ultraMonthlyProductId;
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

        // Sync to Supabase for share management (Ultra gets 5 shares)
        ZagSupabaseShares().syncMasterSubscription(
          productId: productId,
          expiresAt: expiry,
        );

        // Ultra subsume Mega/Pro benefits
        ZagreusMega.disable();

        // Note: Backend syncs subscription during device registration
      } else {
        print('⚠️ RevenueCat: Ultra marked active but no expiration date');
        ZagreusUltra.disable();
      }
    } else {
      print('📵 RevenueCat: Ultra not active');
      ZagreusUltra.disable();

      // Check Mega entitlement

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

          // Sync to Supabase for share management (Mega gets 1 share)
          ZagSupabaseShares().syncMasterSubscription(
            productId: productId,
            expiresAt: expiry,
          );

          // Note: Backend syncs subscription during device registration
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
    }

    if (!ZagreusPro.isEnabled) {
      await ZagLocalConnectionService().disableAdvancedSwitching();
    }

    // Refresh subscription cache for instant UI updates
    SubscriptionService().refresh();

    _isUpdating = false; // Reset the flag
  }

  // Note: Subscription syncing to Supabase is now handled by the backend
  // during device registration, not directly from the app

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
      ZagLogger().debug('🔍 Looking for Pro Lifetime: "$_proLifetimeEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_proLifetimeEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Mega: "$_megaEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_megaEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Ultra: "$_ultraEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_ultraEntitlementId)}');
      ZagLogger().debug('🔍 Looking for Supreme: "$_supremeEntitlementId" - Found: ${customerInfo.entitlements.all.containsKey(_supremeEntitlementId)}');

      _updateProStatus();

      // Only show ONE toast with the final result
      final hasAny = isSupremeActive || isUltraActive || isMegaActive || isProActive;
      if (hasAny) {
        final subscriptionType = isSupremeActive
            ? 'Supreme'
            : isUltraActive
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

  bool get isSupremeActive =>
    (_customerInfo?.entitlements.all[_supremeEntitlementId]?.isActive ?? false) ||
    ZagreusSupreme.isEnabled;

  bool get isUltraActive =>
    (_customerInfo?.entitlements.all[_ultraEntitlementId]?.isActive ?? false) ||
    ZagreusUltra.isEnabled ||
    isSupremeActive;

  bool get isMegaActive =>
    (_customerInfo?.entitlements.all[_megaEntitlementId]?.isActive ?? false) ||
    ZagreusMega.isEnabled ||
    isUltraActive;

  bool get isProActive =>
    (_customerInfo?.entitlements.all[_proEntitlementId]?.isActive ?? false) ||
    (_customerInfo?.entitlements.all[_proYearlyEntitlementId]?.isActive ?? false) ||
    (_customerInfo?.entitlements.all[_proLifetimeEntitlementId]?.isActive ?? false) ||
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

      Package? selectedPackage;
      if (isMonthly) {
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.identifier == '\$rc_monthly' ||
              pkg.packageType == PackageType.monthly ||
              pkg.identifier.toLowerCase().contains('month') ||
              pkg.storeProduct.identifier.toLowerCase().contains('month'),
        );
      } else {
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.identifier == '\$rc_annual' ||
              pkg.packageType == PackageType.annual ||
              pkg.identifier.toLowerCase().contains('year') ||
              pkg.identifier.toLowerCase().contains('annual') ||
              pkg.storeProduct.identifier.toLowerCase().contains('year') ||
              pkg.storeProduct.identifier.toLowerCase().contains('annual'),
        );

        // Fallback: if multiple packages exist, prefer the more expensive for yearly
        if (selectedPackage == null && packages.length > 1) {
          packages.sort(
            (a, b) => b.storeProduct.price.compareTo(a.storeProduct.price),
          );
          selectedPackage = packages.first;
        }
      }

      selectedPackage ??= packages.first;

      print('📦 Purchasing Mega package: ${selectedPackage.identifier}');

      // Make purchase
      final result = await Purchases.purchasePackage(selectedPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Mega!',
        message: 'Z-Bot features are now unlocked.',
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

  Future<Map<String, bool>> getTrialEligibility(List<String> productIds) async {
    final result = <String, bool>{};
    final missing = productIds
        .where((id) => !_trialEligibilityCache.containsKey(id))
        .toList();

    if (missing.isNotEmpty) {
      try {
        final eligibilityMap =
            await Purchases.checkTrialOrIntroductoryPriceEligibility(missing);
        eligibilityMap.forEach((productId, eligibility) {
          if (eligibility != null) {
            _trialEligibilityCache[productId] = eligibility.status;
          }
        });
      } catch (e) {
        print('⚠️ RevenueCat: Failed to check trial eligibility: $e');
      }
    }

    for (final id in productIds) {
      final status = _trialEligibilityCache[id];
      result[id] = _isIntroEligible(status);
    }
    return result;
  }

  bool _isIntroEligible(IntroEligibilityStatus? status) {
    if (status == null) return true; // default to showing trial copy
    return status == IntroEligibilityStatus.introEligibilityStatusEligible ||
        status == IntroEligibilityStatus.introEligibilityStatusUnknown;
  }

  Future<bool> purchaseUltra(bool isMonthly) async {
    try {
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');

      final ultraOffering = offerings.all['ultra'];
      List<Package> packages = [];

      if (ultraOffering != null) {
        packages = ultraOffering.availablePackages;
      }

      if (packages.isEmpty) {
        // Fallback: scan all offerings for Ultra products
        for (final entry in offerings.all.entries) {
          final match = entry.value.availablePackages.firstWhereOrNull(
            (pkg) {
              final id = pkg.storeProduct.identifier.toLowerCase();
              if (isMonthly) {
                return id.contains('ultra') && id.contains('month');
              }
              return id.contains('ultra') &&
                     (id.contains('year') || id.contains('annual'));
            },
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

      Package? selectedPackage;
      if (isMonthly) {
        const desiredId = ultraMonthlyProductId;
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.storeProduct.identifier == desiredId ||
              pkg.identifier == '\$rc_monthly' ||
              pkg.packageType == PackageType.monthly ||
              pkg.identifier.toLowerCase().contains('month'),
        );
      } else {
        const desiredId = ultraYearlyProductId;
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.storeProduct.identifier == desiredId ||
              pkg.identifier == '\$rc_annual' ||
              pkg.packageType == PackageType.annual ||
              pkg.identifier.toLowerCase().contains('year') ||
              pkg.identifier.toLowerCase().contains('annual') ||
              pkg.storeProduct.identifier.toLowerCase().contains('year') ||
              pkg.storeProduct.identifier.toLowerCase().contains('annual'),
        );

        if (selectedPackage == null && packages.length > 1) {
          packages.sort(
            (a, b) => b.storeProduct.price.compareTo(a.storeProduct.price),
          );
          selectedPackage = packages.first;
        }
      }

      selectedPackage ??= packages.first;

      print('📦 Purchasing Ultra package: ${selectedPackage.identifier}');

      final result = await Purchases.purchasePackage(selectedPackage);
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

  Future<bool> purchaseSupreme(bool isMonthly) async {
    try {
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');

      final supremeOffering = offerings.all['supreme'];
      List<Package> packages = [];

      if (supremeOffering != null) {
        packages = supremeOffering.availablePackages;
      }

      if (packages.isEmpty) {
        // Fallback: scan all offerings for Supreme products
        for (final entry in offerings.all.entries) {
          final match = entry.value.availablePackages.firstWhereOrNull(
            (pkg) {
              final id = pkg.storeProduct.identifier.toLowerCase();
              if (isMonthly) {
                return id.contains('supreme') && id.contains('month');
              }
              return id.contains('supreme') &&
                     (id.contains('year') || id.contains('annual'));
            },
          );
          if (match != null) {
            packages = [match];
            break;
          }
        }
      }

      if (packages.isEmpty) {
        print('❌ No Supreme packages found in offerings');
        return false;
      }

      Package? selectedPackage;
      if (isMonthly) {
        const desiredId = supremeMonthlyProductId;
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.storeProduct.identifier == desiredId ||
              pkg.identifier == '\$rc_monthly' ||
              pkg.packageType == PackageType.monthly ||
              pkg.identifier.toLowerCase().contains('month'),
        );
      } else {
        const desiredId = supremeYearlyProductId;
        selectedPackage = packages.firstWhereOrNull(
          (pkg) =>
              pkg.storeProduct.identifier == desiredId ||
              pkg.identifier == '\$rc_annual' ||
              pkg.packageType == PackageType.annual ||
              pkg.identifier.toLowerCase().contains('year') ||
              pkg.identifier.toLowerCase().contains('annual') ||
              pkg.storeProduct.identifier.toLowerCase().contains('year') ||
              pkg.storeProduct.identifier.toLowerCase().contains('annual'),
        );

        if (selectedPackage == null && packages.length > 1) {
          packages.sort(
            (a, b) => b.storeProduct.price.compareTo(a.storeProduct.price),
          );
          selectedPackage = packages.first;
        }
      }

      selectedPackage ??= packages.first;

      print('📦 Purchasing Supreme package: ${selectedPackage.identifier}');

      final result = await Purchases.purchasePackage(selectedPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Supreme!',
        message: 'Supreme AI features are now unlocked.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      print('❌ Supreme purchase failed: $e');
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

  Future<bool> purchaseProLifetime() async {
    try {
      // Get available packages
      final offerings = await Purchases.getOfferings();

      print('🔍 RevenueCat Offerings: ${offerings.all.keys}');

      // Look for lifetime package in the default or pro offering
      Package? lifetimePackage;

      // Check current offering first
      final packages = offerings.current?.availablePackages ?? [];
      lifetimePackage = packages.firstWhereOrNull(
        (pkg) => pkg.storeProduct.identifier == proLifetimeProductId ||
                 pkg.identifier.toLowerCase().contains('lifetime') ||
                 pkg.packageType == PackageType.lifetime,
      );

      // If not found in current, check all offerings
      if (lifetimePackage == null) {
        for (final entry in offerings.all.entries) {
          final match = entry.value.availablePackages.firstWhereOrNull(
            (pkg) => pkg.storeProduct.identifier == proLifetimeProductId ||
                     pkg.identifier.toLowerCase().contains('lifetime') ||
                     pkg.packageType == PackageType.lifetime,
          );
          if (match != null) {
            lifetimePackage = match;
            break;
          }
        }
      }

      if (lifetimePackage == null) {
        print('❌ No lifetime package found in offerings');
        return false;
      }

      print('📦 Purchasing Pro Lifetime package: ${lifetimePackage.identifier}');

      // Make purchase
      final result = await Purchases.purchasePackage(lifetimePackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Pro!',
        message: 'Premium features are now unlocked forever.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        return false;
      }
      print('❌ Lifetime purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }
}
