import 'package:hive/hive.dart';
import '../../domain/models/goal_model.dart';
import '../../../../core/data/services/hive_service.dart';

class GoalLocalDataSource {
  Box<GoalModel>? _box;

  GoalLocalDataSource() {
    // Don't initialize box in constructor - it will be lazy loaded
    // This prevents crashing when no user is logged in yet (TD-003)
  }

  /// Get the box if user is logged in, otherwise return null
  Box<GoalModel>? get _getBox {
    if (_box != null) return _box;

    try {
      // Only try to get box if a user is logged in
      if (HiveService.currentUserId != null) {
        _box = HiveService.getBox<GoalModel>(HiveService.goalsBox);
        return _box;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save a new goal
  Future<void> saveGoal(GoalModel goal) async {
    final box = _getBox;
    if (box == null) {
      throw Exception('Cannot save goal: No user logged in (currentUserId: ${HiveService.currentUserId})');
    }
    await box.put(goal.id, goal);
  }

  /// Get a goal by ID
  GoalModel? getGoalById(String id) {
    final box = _getBox;
    if (box == null) return null;
    return box.get(id);
  }

  /// Get all goals
  List<GoalModel> getAllGoals() {
    final box = _getBox;
    if (box == null) return [];
    return box.values.toList();
  }

  /// Get goals by user ID
  List<GoalModel> getGoalsByUserId(String userId) {
    final box = _getBox;
    if (box == null) return [];
    return box.values.where((goal) => goal.userId == userId).toList();
  }

  /// Get active goal for user (only one active goal at a time)
  GoalModel? getActiveGoal(String userId) {
    final box = _getBox;
    if (box == null) return null;
    try {
      return box.values.firstWhere(
        (goal) => goal.userId == userId && goal.isActive && !goal.isCompleted,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get active goal safely (returns null if none)
  GoalModel? getActiveGoalSafe(String userId) {
    return getActiveGoal(userId);
  }

  /// Get completed goals
  List<GoalModel> getCompletedGoals(String userId) {
    final box = _getBox;
    if (box == null) return [];
    return box.values
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
    final box = _getBox;
    if (box == null) return;
    await box.put(goal.id, goal);
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String id, double newProgress) async {
    final box = _getBox;
    if (box == null) return;
    final goal = box.get(id);
    if (goal != null) {
      final isNowCompleted = newProgress >= goal.totalDistance;
      final updatedGoal = goal.copyWith(
        currentProgress: newProgress,
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedGoal);
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    final box = _getBox;
    if (box == null) return;
    await box.delete(id);
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
        await updateGoal(updatedGoal);
      }
    }
  }

  /// Set a goal as active (deactivates other goals)
  Future<void> setGoalActive(String id) async {
    final box = _getBox;
    if (box == null) return;
    final goal = box.get(id);
    if (goal != null) {
      // Deactivate all other goals for this user
      await deactivateAllGoals(goal.userId);

      // Activate this goal
      final updatedGoal = goal.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedGoal);
    }
  }

  /// Get unsynced goals
  List<GoalModel> getUnsyncedGoals(String userId) {
    final box = _getBox;
    if (box == null) return [];
    return box.values
        .where((goal) => goal.userId == userId && !goal.isSynced)
        .toList();
  }

  /// Mark goal as synced
  Future<void> markGoalAsSynced(String id) async {
    final box = _getBox;
    if (box == null) return;
    final goal = box.get(id);
    if (goal != null) {
      final updatedGoal = goal.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedGoal);
    }
  }

  /// Clear all goals (for testing or logout)
  Future<void> clearAllGoals() async {
    final box = _getBox;
    if (box == null) return;
    await box.clear();
  }

  /// Check if user has any goals
  bool hasGoals(String userId) {
    final box = _getBox;
    if (box == null) return false;
    return box.values.any((goal) => goal.userId == userId);
  }

  /// Check if user has an active goal
  bool hasActiveGoal(String userId) {
    return getActiveGoalSafe(userId) != null;
  }

  /// Get total number of goals by user
  int getTotalGoalCount(String userId) {
    final box = _getBox;
    if (box == null) return 0;
    return box.values.where((goal) => goal.userId == userId).length;
  }

  /// Check if box is empty
  bool isEmpty() {
    final box = _getBox;
    if (box == null) return true;
    return box.isEmpty;
  }
}
