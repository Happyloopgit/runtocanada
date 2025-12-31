import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/firestore_datasource.dart';
import '../services/sync_service.dart';
import '../../../features/runs/data/datasources/run_local_datasource.dart';
import '../../../features/goals/data/datasources/goal_local_datasource.dart';

/// Provider for FirestoreDataSource
final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSource();
});

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final firestoreDataSource = ref.watch(firestoreDataSourceProvider);
  final runLocalDataSource = RunLocalDataSource();
  final goalLocalDataSource = GoalLocalDataSource();

  final service = SyncService(
    firestoreDataSource: firestoreDataSource,
    runLocalDataSource: runLocalDataSource,
    goalLocalDataSource: goalLocalDataSource,
  );

  // Initialize the service
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for sync queue status
final syncQueueStatusProvider = Provider<SyncQueueStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.getSyncQueueStatus();
});

/// Provider for checking if online
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.isOnline();
});
