import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../data/services/goal_service.dart';

/// Provider for GoalLocalDataSource
final goalLocalDataSourceProvider = Provider<GoalLocalDataSource>((ref) {
  return GoalLocalDataSource();
});

/// Provider for GoalService
final goalServiceProvider = Provider<GoalService>((ref) {
  final goalLocalDataSource = ref.watch(goalLocalDataSourceProvider);
  return GoalService(goalLocalDataSource: goalLocalDataSource);
});

/// Provider to check if user has an active goal
final hasActiveGoalProvider = Provider.family<bool, String>((ref, userId) {
  final goalService = ref.watch(goalServiceProvider);
  return goalService.hasActiveGoal(userId);
});

/// Provider to get progress stats for display
final goalProgressStatsProvider = Provider.family<Map<String, dynamic>?, String>((ref, userId) {
  final goalService = ref.watch(goalServiceProvider);
  return goalService.getProgressStats(userId);
});
