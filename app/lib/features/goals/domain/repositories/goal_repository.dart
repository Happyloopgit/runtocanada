import '../models/goal_model.dart';

abstract class GoalRepository {
  /// Save a new goal
  Future<void> saveGoal(GoalModel goal);

  /// Get a goal by ID
  Future<GoalModel?> getGoalById(String id);

  /// Get all goals for a user
  Future<List<GoalModel>> getGoalsByUserId(String userId);

  /// Get active goal for user
  Future<GoalModel?> getActiveGoal(String userId);

  /// Get completed goals for user
  Future<List<GoalModel>> getCompletedGoals(String userId);

  /// Get goals sorted by creation date (newest first)
  Future<List<GoalModel>> getGoalsSortedByDate(String userId);

  /// Update a goal
  Future<void> updateGoal(GoalModel goal);

  /// Update goal progress
  Future<void> updateGoalProgress(String id, double newProgress);

  /// Delete a goal
  Future<void> deleteGoal(String id);

  /// Set a goal as active (deactivates other goals)
  Future<void> setGoalActive(String id);

  /// Check if user has an active goal
  Future<bool> hasActiveGoal(String userId);

  /// Get total number of goals by user
  Future<int> getTotalGoalCount(String userId);

  /// Sync goals to cloud
  Future<void> syncGoals(String userId);
}
