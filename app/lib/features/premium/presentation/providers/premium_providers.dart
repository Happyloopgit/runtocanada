import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:run_to_canada/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:run_to_canada/features/premium/data/services/premium_service.dart';
import 'package:run_to_canada/features/premium/data/services/revenue_cat_service.dart';

/// Provider for RevenueCatService instance
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider for PremiumService instance
final premiumServiceProvider = Provider<PremiumService>((ref) {
  final goalLocalDataSource = GoalLocalDataSource();
  return PremiumService(goalLocalDataSource: goalLocalDataSource);
});

/// Provider for checking if user is premium
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.isPremiumUser();
});

/// Provider for checking if user has reached free tier limit
final hasReachedFreeLimitProvider = FutureProvider<bool>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.hasReachedFreeLimit();
});

/// Provider for remaining free distance
final remainingFreeDistanceProvider = FutureProvider<double>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.getRemainingFreeDistance();
});

/// Provider for free limit progress (0.0 to 1.0)
final freeLimitProgressProvider = FutureProvider<double>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.getFreeLimitProgress();
});

/// Provider for checking if user can create a new goal
final canCreateGoalProvider = FutureProvider<bool>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.canCreateGoal();
});

/// Provider for checking if user can start a new run
final canStartRunProvider = FutureProvider<bool>((ref) async {
  final premiumService = ref.watch(premiumServiceProvider);
  return await premiumService.canStartRun();
});

/// Provider for RevenueCat offerings
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return await revenueCatService.getOfferings();
});

/// Provider for subscription packages (monthly and annual)
final subscriptionPackagesProvider = FutureProvider<Map<String, Package?>>((ref) async {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return await revenueCatService.getSubscriptionPackages();
});

/// Provider for customer info stream
final customerInfoStreamProvider = StreamProvider<CustomerInfo>((ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return revenueCatService.customerInfoStream;
});

/// Provider for current customer info
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return await revenueCatService.getCustomerInfo();
});
