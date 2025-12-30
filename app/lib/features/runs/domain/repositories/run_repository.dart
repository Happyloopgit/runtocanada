import '../models/run_model.dart';

abstract class RunRepository {
  /// Save a new run
  Future<void> saveRun(RunModel run);

  /// Get a run by ID
  Future<RunModel?> getRunById(String id);

  /// Get all runs for a user
  Future<List<RunModel>> getRunsByUserId(String userId);

  /// Get runs sorted by date (newest first)
  Future<List<RunModel>> getRunsSortedByDate(String userId);

  /// Get runs within a date range
  Future<List<RunModel>> getRunsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get total distance run by user
  Future<double> getTotalDistanceByUser(String userId);

  /// Get total number of runs by user
  Future<int> getTotalRunCountByUser(String userId);

  /// Update a run
  Future<void> updateRun(RunModel run);

  /// Delete a run
  Future<void> deleteRun(String id);

  /// Get latest run by user
  Future<RunModel?> getLatestRun(String userId);

  /// Sync runs to cloud
  Future<void> syncRuns(String userId);
}
