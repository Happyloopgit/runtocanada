import 'package:hive/hive.dart';
import '../../domain/models/goal_model.dart';
import '../../../../core/data/services/hive_service.dart';

class GoalLocalDataSource {
  late Box<GoalModel> _box;

  GoalLocalDataSource() {
    _box = HiveService.getBox<GoalModel>(HiveService.goalsBox);
  }

  /// Save a new goal
  Future<void> saveGoal(GoalModel goal) async {
    await _box.put(goal.id, goal);
  }

  /// Get a goal by ID
  GoalModel? getGoalById(String id) {
    return _box.get(id);
  }

  /// Get all goals
  List<GoalModel> getAllGoals() {
    return _box.values.toList();
  }

  /// Get goals by user ID
  List<GoalModel> getGoalsByUserId(String userId) {
    return _box.values.where((goal) => goal.userId == userId).toList();
  }

  /// Get active goal for user (only one active goal at a time)
  GoalModel? getActiveGoal(String userId) {
    return _box.values.firstWhere(
      (goal) => goal.userId == userId && goal.isActive && !goal.isCompleted,
      orElse: () => _box.values.first, // This will throw if empty, which is fine
    );
  }

  /// Get active goal safely (returns null if none)
  GoalModel? getActiveGoalSafe(String userId) {
    try {
      return _box.values.firstWhere(
        (goal) => goal.userId == userId && goal.isActive && !goal.isCompleted,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get completed goals
  List<GoalModel> getCompletedGoals(String userId) {
    return _box.values
        .where((goal) => goal.userId == userId && goal.isCompleted)
        .toList();
  }

  /// Get goals sorted by creation date (newest first)
  List<GoalModel> getGoalsSortedByDate(String userId) {
    final goals = getGoalsByUserId(userId);
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    await _box.put(goal.id, goal);
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String id, double newProgress) async {
    final goal = _box.get(id);
    if (goal != null) {
      final isNowCompleted = newProgress >= goal.totalDistance;
      final updatedGoal = goal.copyWith(
        currentProgress: newProgress,
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updatedGoal);
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  /// Deactivate all goals for a user
  Future<void> deactivateAllGoals(String userId) async {
    final goals = getGoalsByUserId(userId);
    for (final goal in goals) {
      if (goal.isActive) {
        final updatedGoal = goal.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _box.put(goal.id, updatedGoal);
      }
    }
  }

  /// Set a goal as active (deactivates other goals)
  Future<void> setGoalActive(String id) async {
    final goal = _box.get(id);
    if (goal != null) {
      // Deactivate all other goals for this user
      await deactivateAllGoals(goal.userId);

      // Activate this goal
      final updatedGoal = goal.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updatedGoal);
    }
  }

  /// Get unsynced goals
  List<GoalModel> getUnsyncedGoals(String userId) {
    return _box.values
        .where((goal) => goal.userId == userId && !goal.isSynced)
        .toList();
  }

  /// Mark goal as synced
  Future<void> markGoalAsSynced(String id) async {
    final goal = _box.get(id);
    if (goal != null) {
      final updatedGoal = goal.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updatedGoal);
    }
  }

  /// Clear all goals (for testing or logout)
  Future<void> clearAllGoals() async {
    await _box.clear();
  }

  /// Check if user has any goals
  bool hasGoals(String userId) {
    return _box.values.any((goal) => goal.userId == userId);
  }

  /// Check if user has an active goal
  bool hasActiveGoal(String userId) {
    return getActiveGoalSafe(userId) != null;
  }

  /// Get total number of goals by user
  int getTotalGoalCount(String userId) {
    return _box.values.where((goal) => goal.userId == userId).length;
  }

  /// Check if box is empty
  bool isEmpty() {
    return _box.isEmpty;
  }
}
