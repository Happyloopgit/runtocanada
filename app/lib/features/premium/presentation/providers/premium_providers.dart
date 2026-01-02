import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:run_to_canada/features/premium/data/services/premium_service.dart';

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
