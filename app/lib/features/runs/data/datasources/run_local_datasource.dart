import 'package:hive/hive.dart';
import '../../domain/models/run_model.dart';
import '../../../../core/data/services/hive_service.dart';

class RunLocalDataSource {
  late Box<RunModel> _box;

  RunLocalDataSource() {
    _box = HiveService.getBox<RunModel>(HiveService.runsBox);
  }

  /// Save a new run
  Future<void> saveRun(RunModel run) async {
    await _box.put(run.id, run);
  }

  /// Get a run by ID
  RunModel? getRunById(String id) {
    return _box.get(id);
  }

  /// Get all runs
  List<RunModel> getAllRuns() {
    return _box.values.toList();
  }

  /// Get runs by user ID
  List<RunModel> getRunsByUserId(String userId) {
    return _box.values.where((run) => run.userId == userId).toList();
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
    return _box.values
        .where((run) =>
            run.userId == userId &&
            run.startTime.isAfter(startDate) &&
            run.startTime.isBefore(endDate))
        .toList();
  }

  /// Get total distance run by user
  double getTotalDistanceByUser(String userId) {
    return _box.values
        .where((run) => run.userId == userId)
        .fold(0.0, (sum, run) => sum + run.totalDistance);
  }

  /// Get total number of runs by user
  int getTotalRunCountByUser(String userId) {
    return _box.values.where((run) => run.userId == userId).length;
  }

  /// Update a run
  Future<void> updateRun(RunModel run) async {
    await _box.put(run.id, run);
  }

  /// Delete a run
  Future<void> deleteRun(String id) async {
    await _box.delete(id);
  }

  /// Get unsynced runs
  List<RunModel> getUnsyncedRuns(String userId) {
    return _box.values
        .where((run) => run.userId == userId && !run.isSynced)
        .toList();
  }

  /// Mark run as synced
  Future<void> markRunAsSynced(String id) async {
    final run = _box.get(id);
    if (run != null) {
      final updatedRun = run.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updatedRun);
    }
  }

  /// Clear all runs (for testing or logout)
  Future<void> clearAllRuns() async {
    await _box.clear();
  }

  /// Get latest run by user
  RunModel? getLatestRun(String userId) {
    final runs = getRunsSortedByDate(userId);
    return runs.isNotEmpty ? runs.first : null;
  }

  /// Check if box is empty
  bool isEmpty() {
    return _box.isEmpty;
  }

  /// Get total number of runs
  int getRunCount() {
    return _box.length;
  }
}
