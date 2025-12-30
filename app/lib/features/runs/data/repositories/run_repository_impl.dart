import '../../domain/models/run_model.dart';
import '../../domain/repositories/run_repository.dart';
import '../datasources/run_local_datasource.dart';

class RunRepositoryImpl implements RunRepository {
  final RunLocalDataSource localDataSource;

  RunRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveRun(RunModel run) async {
    await localDataSource.saveRun(run);
  }

  @override
  Future<RunModel?> getRunById(String id) async {
    return localDataSource.getRunById(id);
  }

  @override
  Future<List<RunModel>> getRunsByUserId(String userId) async {
    return localDataSource.getRunsByUserId(userId);
  }

  @override
  Future<List<RunModel>> getRunsSortedByDate(String userId) async {
    return localDataSource.getRunsSortedByDate(userId);
  }

  @override
  Future<List<RunModel>> getRunsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return localDataSource.getRunsInDateRange(userId, startDate, endDate);
  }

  @override
  Future<double> getTotalDistanceByUser(String userId) async {
    return localDataSource.getTotalDistanceByUser(userId);
  }

  @override
  Future<int> getTotalRunCountByUser(String userId) async {
    return localDataSource.getTotalRunCountByUser(userId);
  }

  @override
  Future<void> updateRun(RunModel run) async {
    await localDataSource.updateRun(run);
  }

  @override
  Future<void> deleteRun(String id) async {
    await localDataSource.deleteRun(id);
  }

  @override
  Future<RunModel?> getLatestRun(String userId) async {
    return localDataSource.getLatestRun(userId);
  }

  @override
  Future<void> syncRuns(String userId) async {
    // TODO: Implement in Sprint 13 (Firebase Sync)
    // Get unsynced runs
    // Upload to Firestore
    // Mark as synced
  }
}
