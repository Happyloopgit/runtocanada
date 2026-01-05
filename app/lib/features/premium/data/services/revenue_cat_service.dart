import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:run_to_canada/app/env.dart';

/// Service to handle RevenueCat in-app purchases and subscriptions
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat SDK
  /// Call this early in app startup, after Firebase is initialized
  Future<void> initialize({required String userId}) async {
    if (_isInitialized) return;

    try {
      // Configure the SDK based on platform
      String apiKey;

      if (Platform.isIOS) {
        apiKey = Env.revenueCatAppleApiKey;
      } else if (Platform.isAndroid) {
        apiKey = Env.revenueCatGoogleApiKey;
      } else {
        throw UnsupportedError('Platform not supported for in-app purchases');
      }

      // Create configuration with debug logs enabled in non-production
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = userId;

      if (Env.enableDebugLogs) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(configuration);

      // Login the user to RevenueCat
      await Purchases.logIn(userId);

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }

  /// Get available subscription offerings
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      throw Exception('Failed to fetch offerings: $e');
    }
  }

  /// Get monthly and annual packages from current offering
  Future<Map<String, Package?>> getSubscriptionPackages() async {
    try {
      final offerings = await getOfferings();

      if (offerings == null || offerings.current == null) {
        return {'monthly': null, 'annual': null};
      }

      final currentOffering = offerings.current!;

      // Try to find packages by identifier
      Package? monthlyPackage;
      Package? annualPackage;

      // Search through available packages
      for (var package in currentOffering.availablePackages) {
        if (package.storeProduct.identifier == Env.monthlyProductId ||
            package.packageType == PackageType.monthly) {
          monthlyPackage = package;
        } else if (package.storeProduct.identifier == Env.annualProductId ||
            package.packageType == PackageType.annual) {
          annualPackage = package;
        }
      }

      return {
        'monthly': monthlyPackage,
        'annual': annualPackage,
      };
    } catch (e) {
      throw Exception('Failed to get subscription packages: $e');
    }
  }

  /// Purchase a subscription package
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw Exception('Purchase was cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        throw Exception('User is not allowed to make purchases');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        throw Exception('Payment is pending');
      } else {
        throw Exception('Purchase failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }

  /// Restore previous purchases
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }

  /// Check if user has active premium subscription
  /// Checks for the "premium" entitlement created in RevenueCat dashboard
  Future<bool> hasPremiumAccess() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Check for specific "premium" entitlement
      // This entitlement should be created in RevenueCat dashboard
      // and linked to both monthly and annual products
      final premiumEntitlement = customerInfo.entitlements.all['premium'];
      final isPremium = premiumEntitlement?.isActive ?? false;

      return isPremium;
    } catch (e) {
      // In case of error, assume not premium
      return false;
    }
  }

  /// Get customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      throw Exception('Failed to get customer info: $e');
    }
  }

  /// Logout current user from RevenueCat
  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      // Logout errors can usually be ignored
      // ignore: avoid_print
      print('RevenueCat logout error: $e');
    }
  }

  /// Set user attributes for analytics
  Future<void> setUserAttributes(Map<String, String> attributes) async {
    try {
      for (var entry in attributes.entries) {
        await Purchases.setAttributes({entry.key: entry.value});
      }
    } catch (e) {
      // Attribute errors can usually be ignored
      // ignore: avoid_print
      print('Failed to set user attributes: $e');
    }
  }

  /// Listen to customer info updates
  /// Returns a stream that emits whenever the user's subscription status changes
  Stream<CustomerInfo> get customerInfoStream {
    // Note: The SDK automatically notifies when customer info changes
    // For now, we'll create a periodic stream that fetches customer info
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      return await Purchases.getCustomerInfo();
    }).asyncMap((event) => event);
  }

  /// Helper to get formatted price for a package
  String getFormattedPrice(Package package) {
    return package.storeProduct.priceString;
  }

  /// Helper to check if annual package offers savings vs monthly
  String? getAnnualSavings(Package? monthlyPackage, Package? annualPackage) {
    if (monthlyPackage == null || annualPackage == null) return null;

    try {
      final monthlyPrice = monthlyPackage.storeProduct.price;
      final annualPrice = annualPackage.storeProduct.price;
      final yearlyMonthlyPrice = monthlyPrice * 12;

      if (yearlyMonthlyPrice <= annualPrice) return null; // No savings

      final savings = ((yearlyMonthlyPrice - annualPrice) / yearlyMonthlyPrice * 100).round();
      return '$savings%';
    } catch (e) {
      return null;
    }
  }

  /// Helper to get monthly equivalent price for annual package
  String? getMonthlyEquivalent(Package? annualPackage) {
    if (annualPackage == null) return null;

    try {
      final annualPrice = annualPackage.storeProduct.price;
      final monthlyEquivalent = annualPrice / 12;
      final currencyCode = annualPackage.storeProduct.currencyCode;

      // Format to 2 decimal places
      return '$currencyCode ${monthlyEquivalent.toStringAsFixed(2)}/month';
    } catch (e) {
      return null;
    }
  }
}
