import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../data/services/goal_service.dart';
import '../../../../core/data/providers/sync_providers.dart';

/// Provider for GoalLocalDataSource
final goalLocalDataSourceProvider = Provider<GoalLocalDataSource>((ref) {
  return GoalLocalDataSource();
});

/// Provider for GoalService
final goalServiceProvider = Provider<GoalService>((ref) {
  final goalLocalDataSource = ref.watch(goalLocalDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return GoalService(
    goalLocalDataSource: goalLocalDataSource,
    syncService: syncService,
  );
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
