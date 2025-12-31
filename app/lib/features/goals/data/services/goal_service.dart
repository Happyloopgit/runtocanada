import '../../domain/models/goal_model.dart';
import '../../domain/models/milestone_model.dart';
import '../datasources/goal_local_datasource.dart';
import '../../../../core/data/services/sync_service.dart';

/// Result of updating goal progress
class GoalProgressResult {
  final GoalModel updatedGoal;
  final List<MilestoneModel> newlyReachedMilestones;
  final bool goalCompleted;
  final double previousProgress;
  final double newProgress;

  GoalProgressResult({
    required this.updatedGoal,
    required this.newlyReachedMilestones,
    required this.goalCompleted,
    required this.previousProgress,
    required this.newProgress,
  });

  bool get hasNewMilestones => newlyReachedMilestones.isNotEmpty;

  double get progressAdded => newProgress - previousProgress;

  double get progressPercentage => (newProgress / updatedGoal.totalDistance) * 100;
}

/// Service class for managing goal progress and milestone detection
class GoalService {
  final GoalLocalDataSource _goalLocalDataSource;
  final SyncService? _syncService;

  GoalService({
    required GoalLocalDataSource goalLocalDataSource,
    SyncService? syncService,
  })  : _goalLocalDataSource = goalLocalDataSource,
        _syncService = syncService;

  /// Update goal progress after a run completes
  /// Returns null if no active goal exists
  Future<GoalProgressResult?> updateGoalProgress({
    required String userId,
    required double runDistance, // in meters
  }) async {
    // Fetch active goal for user
    final activeGoal = _goalLocalDataSource.getActiveGoalSafe(userId);

    if (activeGoal == null) {
      return null; // No active goal to update
    }

    // Calculate new progress (cap at total distance)
    final previousProgress = activeGoal.currentProgress;
    final newProgress = (previousProgress + runDistance).clamp(0.0, activeGoal.totalDistance);

    // Detect newly reached milestones
    final newlyReachedMilestones = _detectNewlyReachedMilestones(
      milestones: activeGoal.milestones,
      previousProgress: previousProgress,
      newProgress: newProgress,
    );

    // Update milestones with reached status
    final updatedMilestones = activeGoal.milestones.map((milestone) {
      final isNewlyReached = newlyReachedMilestones.any((m) => m.id == milestone.id);
      if (isNewlyReached) {
        return milestone.copyWith(
          isReached: true,
          reachedAt: DateTime.now(),
        );
      }
      return milestone;
    }).toList();

    // Check if goal is now completed
    final goalCompleted = newProgress >= activeGoal.totalDistance;

    // Create updated goal
    final updatedGoal = activeGoal.copyWith(
      currentProgress: newProgress,
      milestones: updatedMilestones,
      isCompleted: goalCompleted,
      completedAt: goalCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
      isSynced: false, // Mark for sync
    );

    // Save updated goal to Hive
    await _goalLocalDataSource.updateGoal(updatedGoal);

    // Queue goal for cloud sync if sync service is available
    if (_syncService != null) {
      await _syncService.queueGoalForSync(updatedGoal);
    }

    return GoalProgressResult(
      updatedGoal: updatedGoal,
      newlyReachedMilestones: newlyReachedMilestones,
      goalCompleted: goalCompleted,
      previousProgress: previousProgress,
      newProgress: newProgress,
    );
  }

  /// Detect milestones that were crossed between previous and new progress
  List<MilestoneModel> _detectNewlyReachedMilestones({
    required List<MilestoneModel> milestones,
    required double previousProgress,
    required double newProgress,
  }) {
    final newlyReached = <MilestoneModel>[];

    for (final milestone in milestones) {
      // Skip already reached milestones
      if (milestone.isReached) continue;

      // Check if milestone was crossed
      // Milestone is reached if its distance is between previous and new progress
      if (milestone.distanceFromStart > previousProgress &&
          milestone.distanceFromStart <= newProgress) {
        newlyReached.add(milestone);
      }
    }

    // Sort by distance (closest first)
    newlyReached.sort((a, b) => a.distanceFromStart.compareTo(b.distanceFromStart));

    return newlyReached;
  }

  /// Get the active goal for a user
  GoalModel? getActiveGoal(String userId) {
    return _goalLocalDataSource.getActiveGoalSafe(userId);
  }

  /// Check if user has an active goal
  bool hasActiveGoal(String userId) {
    return _goalLocalDataSource.hasActiveGoal(userId);
  }

  /// Get next milestone to reach for active goal
  MilestoneModel? getNextMilestone(String userId) {
    final goal = getActiveGoal(userId);
    return goal?.nextMilestone;
  }

  /// Get progress statistics for active goal
  Map<String, dynamic>? getProgressStats(String userId) {
    final goal = getActiveGoal(userId);
    if (goal == null) return null;

    return {
      'totalDistance': goal.totalDistance,
      'currentProgress': goal.currentProgress,
      'progressPercentage': goal.progressPercentage,
      'remainingDistance': goal.totalDistance - goal.currentProgress,
      'milestonesReached': goal.milestonesReached,
      'totalMilestones': goal.totalMilestones,
      'isCompleted': goal.isCompleted,
    };
  }

  /// Manually mark a milestone as reached (for testing or admin purposes)
  Future<void> markMilestoneReached({
    required String goalId,
    required String milestoneId,
  }) async {
    final goal = _goalLocalDataSource.getGoalById(goalId);
    if (goal == null) return;

    final updatedMilestones = goal.milestones.map((milestone) {
      if (milestone.id == milestoneId && !milestone.isReached) {
        return milestone.copyWith(
          isReached: true,
          reachedAt: DateTime.now(),
        );
      }
      return milestone;
    }).toList();

    final updatedGoal = goal.copyWith(
      milestones: updatedMilestones,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _goalLocalDataSource.updateGoal(updatedGoal);
  }

  /// Reset goal progress (for testing purposes)
  Future<void> resetGoalProgress(String goalId) async {
    final goal = _goalLocalDataSource.getGoalById(goalId);
    if (goal == null) return;

    // Reset all milestones
    final resetMilestones = goal.milestones.map((milestone) {
      return milestone.copyWith(
        isReached: false,
        reachedAt: null,
      );
    }).toList();

    final resetGoal = goal.copyWith(
      currentProgress: 0.0,
      milestones: resetMilestones,
      isCompleted: false,
      completedAt: null,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _goalLocalDataSource.updateGoal(resetGoal);
  }

  /// Complete goal (mark as finished)
  Future<void> completeGoal(String goalId) async {
    final goal = _goalLocalDataSource.getGoalById(goalId);
    if (goal == null) return;

    // Mark all milestones as reached
    final completedMilestones = goal.milestones.map((milestone) {
      if (!milestone.isReached) {
        return milestone.copyWith(
          isReached: true,
          reachedAt: DateTime.now(),
        );
      }
      return milestone;
    }).toList();

    final completedGoal = goal.copyWith(
      currentProgress: goal.totalDistance,
      milestones: completedMilestones,
      isCompleted: true,
      isActive: false,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _goalLocalDataSource.updateGoal(completedGoal);
  }
}
