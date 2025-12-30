import '../../domain/models/goal_model.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource localDataSource;

  GoalRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveGoal(GoalModel goal) async {
    await localDataSource.saveGoal(goal);
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    return localDataSource.getGoalById(id);
  }

  @override
  Future<List<GoalModel>> getGoalsByUserId(String userId) async {
    return localDataSource.getGoalsByUserId(userId);
  }

  @override
  Future<GoalModel?> getActiveGoal(String userId) async {
    return localDataSource.getActiveGoalSafe(userId);
  }

  @override
  Future<List<GoalModel>> getCompletedGoals(String userId) async {
    return localDataSource.getCompletedGoals(userId);
  }

  @override
  Future<List<GoalModel>> getGoalsSortedByDate(String userId) async {
    return localDataSource.getGoalsSortedByDate(userId);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await localDataSource.updateGoal(goal);
  }

  @override
  Future<void> updateGoalProgress(String id, double newProgress) async {
    await localDataSource.updateGoalProgress(id, newProgress);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await localDataSource.deleteGoal(id);
  }

  @override
  Future<void> setGoalActive(String id) async {
    await localDataSource.setGoalActive(id);
  }

  @override
  Future<bool> hasActiveGoal(String userId) async {
    return localDataSource.hasActiveGoal(userId);
  }

  @override
  Future<int> getTotalGoalCount(String userId) async {
    return localDataSource.getTotalGoalCount(userId);
  }

  @override
  Future<void> syncGoals(String userId) async {
    // TODO: Implement in Sprint 13 (Firebase Sync)
    // Get unsynced goals
    // Upload to Firestore
    // Mark as synced
  }
}
