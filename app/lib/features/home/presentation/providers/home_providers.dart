import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/goals/domain/models/goal_model.dart';
import 'package:run_to_canada/features/goals/domain/models/milestone_model.dart';
import 'package:run_to_canada/features/goals/presentation/providers/goal_service_provider.dart';

/// Provider to get active goal for current user
final activeGoalProvider = FutureProvider<GoalModel?>((ref) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return null;

  final goalService = ref.watch(goalServiceProvider);
  return goalService.getActiveGoal(userAsync.uid);
});

/// Provider to check if current user has an active goal
final hasActiveGoalProvider = FutureProvider<bool>((ref) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return false;

  final goalService = ref.watch(goalServiceProvider);
  return goalService.hasActiveGoal(userAsync.uid);
});

/// Provider to get next milestone for current user
final nextMilestoneProvider = FutureProvider<MilestoneModel?>((ref) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return null;

  final goalService = ref.watch(goalServiceProvider);
  return goalService.getNextMilestone(userAsync.uid);
});

/// Provider to get progress stats for current user
final progressStatsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return null;

  final goalService = ref.watch(goalServiceProvider);
  return goalService.getProgressStats(userAsync.uid);
});

/// Provider to get goal title (e.g., "Toronto to Vancouver")
final goalTitleProvider = FutureProvider<String?>((ref) async {
  final goal = await ref.watch(activeGoalProvider.future);
  return goal?.name;
});

/// Provider to get covered distance in km
final coveredDistanceProvider = FutureProvider<double>((ref) async {
  final stats = await ref.watch(progressStatsProvider.future);
  if (stats == null) return 0.0;

  final currentProgress = stats['currentProgress'] as double? ?? 0.0;
  return currentProgress / 1000; // Convert meters to km
});

/// Provider to get remaining distance in km
final remainingDistanceProvider = FutureProvider<double>((ref) async {
  final stats = await ref.watch(progressStatsProvider.future);
  if (stats == null) return 0.0;

  final remainingDistance = stats['remainingDistance'] as double? ?? 0.0;
  return remainingDistance / 1000; // Convert meters to km
});

/// Provider to get weekly trend percentage
/// TODO: Implement real weekly trend calculation based on run history
final weeklyTrendProvider = FutureProvider<double?>((ref) async {
  // For now, return null to indicate no trend data
  // In the future, calculate based on last 7 days of runs
  return null;
});

/// Home screen data model
class HomeScreenData {
  final GoalModel? activeGoal;
  final MilestoneModel? nextMilestone;
  final Map<String, dynamic>? progressStats;
  final bool hasActiveGoal;

  HomeScreenData({
    required this.activeGoal,
    required this.nextMilestone,
    required this.progressStats,
    required this.hasActiveGoal,
  });

  String? get goalTitle => activeGoal?.name;

  double get coveredDistanceKm =>
      (progressStats?['currentProgress'] as double? ?? 0.0) / 1000;

  double get remainingDistanceKm =>
      (progressStats?['remainingDistance'] as double? ?? 0.0) / 1000;

  double get progressPercentage =>
      progressStats?['progressPercentage'] as double? ?? 0.0;

  int get milestonesReached =>
      progressStats?['milestonesReached'] as int? ?? 0;

  int get totalMilestones =>
      progressStats?['totalMilestones'] as int? ?? 0;
}

/// Provider that combines all home screen data
final homeScreenDataProvider = FutureProvider<HomeScreenData>((ref) async {
  final activeGoal = await ref.watch(activeGoalProvider.future);
  final nextMilestone = await ref.watch(nextMilestoneProvider.future);
  final progressStats = await ref.watch(progressStatsProvider.future);
  final hasActiveGoal = await ref.watch(hasActiveGoalProvider.future);

  return HomeScreenData(
    activeGoal: activeGoal,
    nextMilestone: nextMilestone,
    progressStats: progressStats,
    hasActiveGoal: hasActiveGoal,
  );
});
