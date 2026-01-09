import 'package:hive/hive.dart';
import '../../domain/models/run_model.dart';
import '../../../../core/data/services/hive_service.dart';

class RunLocalDataSource {
  Box<RunModel>? _box;

  RunLocalDataSource() {
    // Don't initialize box in constructor - it will be lazy loaded
    // This prevents crashing when no user is logged in yet (TD-003)
  }

  /// Get the box if user is logged in, otherwise return null
  Box<RunModel>? get _getBox {
    if (_box != null) return _box;

    try {
      // Only try to get box if a user is logged in
      if (HiveService.currentUserId != null) {
        _box = HiveService.getBox<RunModel>(HiveService.runsBox);
        return _box;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save a new run
  Future<void> saveRun(RunModel run) async {
    final box = _getBox;
    if (box == null) {
      throw Exception('Cannot save run: No user logged in (currentUserId: ${HiveService.currentUserId})');
    }
    await box.put(run.id, run);
  }

  /// Get a run by ID
  RunModel? getRunById(String id) {
    final box = _getBox;
    if (box == null) return null;
    return box.get(id);
  }

  /// Get all runs
  List<RunModel> getAllRuns() {
    final box = _getBox;
    if (box == null) return [];
    return box.values.toList();
  }

  /// Get runs by user ID
  List<RunModel> getRunsByUserId(String userId) {
    final box = _getBox;
    if (box == null) return [];
    return box.values.where((run) => run.userId == userId).toList();
  }

  /// Get runs sorted by date (newest first)
  List<RunModel> getRunsSortedByDate(String userId) {
    final runs = getRunsByUserId(userId);
    runs.sort((a, b) => b.startTime.compareTo(a.startTime));
    return runs;
  }

  /// Get runs within a date range
  List<RunModel> getRunsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final box = _getBox;
    if (box == null) return [];
    return box.values
        .where((run) =>
            run.userId == userId &&
            run.startTime.isAfter(startDate) &&
            run.startTime.isBefore(endDate))
        .toList();
  }

  /// Get total distance run by user
  double getTotalDistanceByUser(String userId) {
    final box = _getBox;
    if (box == null) return 0.0;
    return box.values
        .where((run) => run.userId == userId)
        .fold(0.0, (sum, run) => sum + run.totalDistance);
  }

  /// Get total number of runs by user
  int getTotalRunCountByUser(String userId) {
    final box = _getBox;
    if (box == null) return 0;
    return box.values.where((run) => run.userId == userId).length;
  }

  /// Update a run
  Future<void> updateRun(RunModel run) async {
    final box = _getBox;
    if (box == null) return;
    await box.put(run.id, run);
  }

  /// Delete a run
  Future<void> deleteRun(String id) async {
    final box = _getBox;
    if (box == null) return;
    await box.delete(id);
  }

  /// Get unsynced runs
  List<RunModel> getUnsyncedRuns(String userId) {
    final box = _getBox;
    if (box == null) return [];
    return box.values
        .where((run) => run.userId == userId && !run.isSynced)
        .toList();
  }

  /// Mark run as synced
  Future<void> markRunAsSynced(String id) async {
    final box = _getBox;
    if (box == null) return;
    final run = box.get(id);
    if (run != null) {
      final updatedRun = run.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedRun);
    }
  }

  /// Clear all runs (for testing or logout)
  Future<void> clearAllRuns() async {
    final box = _getBox;
    if (box == null) return;
    await box.clear();
  }

  /// Get latest run by user
  RunModel? getLatestRun(String userId) {
    final runs = getRunsSortedByDate(userId);
    return runs.isNotEmpty ? runs.first : null;
  }

  /// Check if box is empty
  bool isEmpty() {
    final box = _getBox;
    if (box == null) return true;
    return box.isEmpty;
  }

  /// Get total number of runs
  int getRunCount() {
    final box = _getBox;
    if (box == null) return 0;
    return box.length;
  }
}
