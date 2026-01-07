import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal_model.dart';
import 'goal_service_provider.dart';

/// Provider to get all goals for a user, sorted by date (newest first)
/// Using FutureProvider with autoDispose to refresh on changes
final userGoalsProvider = FutureProvider.autoDispose.family<List<GoalModel>, String>((ref, userId) async {
  final dataSource = ref.watch(goalLocalDataSourceProvider);
  return dataSource.getGoalsSortedByDate(userId);
});

/// Provider to get active goal for user
final activeGoalProvider = Provider.family<GoalModel?, String>((ref, userId) {
  final dataSource = ref.watch(goalLocalDataSourceProvider);
  return dataSource.getActiveGoalSafe(userId);
});

/// Provider to get saved (inactive) goals for user
final savedGoalsProvider = Provider.family<List<GoalModel>, String>((ref, userId) {
  final dataSource = ref.watch(goalLocalDataSourceProvider);
  final allGoals = dataSource.getGoalsByUserId(userId);
  return allGoals.where((goal) => !goal.isActive && !goal.isCompleted).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Provider to get completed goals for user
final completedGoalsProvider = Provider.family<List<GoalModel>, String>((ref, userId) {
  final dataSource = ref.watch(goalLocalDataSourceProvider);
  return dataSource.getCompletedGoals(userId)
    ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
});
