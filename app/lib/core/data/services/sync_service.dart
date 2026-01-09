import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/runs/domain/models/run_model.dart';
import '../../../features/goals/domain/models/goal_model.dart';
import '../datasources/firestore_datasource.dart';
import '../models/sync_queue_item.dart';
import '../../../features/runs/data/datasources/run_local_datasource.dart';
import '../../../features/goals/data/datasources/goal_local_datasource.dart';
import '../../services/directions_service.dart';
import 'hive_service.dart';

/// Service for synchronizing data between local (Hive) and cloud (Firestore)
class SyncService {
  final FirestoreDataSource _firestoreDataSource;
  final RunLocalDataSource _runLocalDataSource;
  final GoalLocalDataSource _goalLocalDataSource;
  final Connectivity _connectivity;

  Box<SyncQueueItem>? _syncQueueBox;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required FirestoreDataSource firestoreDataSource,
    required RunLocalDataSource runLocalDataSource,
    required GoalLocalDataSource goalLocalDataSource,
    Connectivity? connectivity,
  })  : _firestoreDataSource = firestoreDataSource,
        _runLocalDataSource = runLocalDataSource,
        _goalLocalDataSource = goalLocalDataSource,
        _connectivity = connectivity ?? Connectivity();

  /// Get the box if user is logged in, otherwise return null (TD-003)
  Box<SyncQueueItem>? get _getBox {
    if (_syncQueueBox != null) return _syncQueueBox;

    try {
      // Only try to get box if a user is logged in
      if (HiveService.currentUserId != null) {
        _syncQueueBox = HiveService.getBox<SyncQueueItem>(HiveService.syncQueueBox);
        return _syncQueueBox;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Initialize the sync service
  Future<void> initialize() async {
    // Try to initialize box - but don't crash if no user is logged in yet (TD-003)
    // The box will be accessed lazily when needed
    _syncQueueBox = _getBox;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (_hasInternetConnection([result])) {
        // Trigger sync when network becomes available
        processSyncQueue();
      }
    });

    // Start periodic sync (every 30 seconds)
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      processSyncQueue();
    });

    // Process queue on initialization (if user is logged in)
    if (_syncQueueBox != null) {
      processSyncQueue();
    }
  }

  /// Check if there's an internet connection
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Check current connectivity
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _hasInternetConnection([result]);
  }

  /// Add a run to the sync queue
  Future<void> queueRunForSync(RunModel run) async {
    final box = _getBox;
    if (box == null) return; // Skip if no user logged in

    final item = SyncQueueItem(
      id: run.id,
      type: SyncItemType.run,
      itemId: run.id,
      createdAt: DateTime.now(),
      retryCount: 0,
    );

    await box.put(item.id, item);
  }

  /// Add a goal to the sync queue
  Future<void> queueGoalForSync(GoalModel goal) async {
    final box = _getBox;
    if (box == null) return; // Skip if no user logged in

    final item = SyncQueueItem(
      id: goal.id,
      type: SyncItemType.goal,
      itemId: goal.id,
      createdAt: DateTime.now(),
      retryCount: 0,
    );

    await box.put(item.id, item);
  }

  /// Process the sync queue
  Future<void> processSyncQueue() async {
    if (_isSyncing) return; // Prevent concurrent syncs
    if (!await isOnline()) return; // Skip if offline

    final box = _getBox;
    if (box == null) {
      _isSyncing = false;
      return; // Skip if no user logged in
    }

    _isSyncing = true;

    try {
      final items = box.values.toList();
      if (items.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (final item in items) {
        try {
          await _syncItem(item);
          // Remove from queue after successful sync
          await box.delete(item.id);
        } catch (e) {
          // Increment retry count using copyWith
          final updatedItem = item.copyWith(
            retryCount: item.retryCount + 1,
            lastRetryAt: DateTime.now(),
          );

          // Keep in queue with updated retry count
          await box.put(item.id, updatedItem);

          // If retry count exceeds threshold, log error
          if (updatedItem.retryCount > 5) {
            // Could log to analytics or show user notification
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single item
  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.type) {
      case SyncItemType.run:
        await _syncRun(item.itemId);
        break;
      case SyncItemType.goal:
        await _syncGoal(item.itemId);
        break;
      case SyncItemType.userSettings:
        // Will implement in Sprint 14
        break;
    }
  }

  /// Sync a run to Firestore
  Future<void> _syncRun(String runId) async {
    final run = _runLocalDataSource.getRunById(runId);
    if (run == null) {
      throw Exception('Run not found in local database: $runId');
    }

    await _firestoreDataSource.saveRun(run);
  }

  /// Sync a goal to Firestore
  Future<void> _syncGoal(String goalId) async {
    final goal = _goalLocalDataSource.getGoalById(goalId);
    if (goal == null) {
      throw Exception('Goal not found in local database: $goalId');
    }

    await _firestoreDataSource.saveGoal(goal);
  }

  /// Manually sync a run (bypass queue)
  Future<void> syncRunNow(RunModel run) async {
    if (!await isOnline()) {
      await queueRunForSync(run);
      return;
    }

    try {
      await _firestoreDataSource.saveRun(run);
    } catch (e) {
      // Queue for later if sync fails
      await queueRunForSync(run);
      rethrow;
    }
  }

  /// Manually sync a goal (bypass queue)
  Future<void> syncGoalNow(GoalModel goal) async {
    if (!await isOnline()) {
      await queueGoalForSync(goal);
      return;
    }

    try {
      await _firestoreDataSource.saveGoal(goal);
    } catch (e) {
      // Queue for later if sync fails
      await queueGoalForSync(goal);
      rethrow;
    }
  }

  /// Fetch all runs from Firestore and save to local
  /// Uses timestamp-based conflict resolution to prevent data loss
  Future<void> fetchRunsFromCloud(String userId) async {
    if (!await isOnline()) {
      throw Exception('Cannot fetch runs while offline');
    }

    final cloudRuns = await _firestoreDataSource.fetchRuns(userId);

    for (final cloudRun in cloudRuns) {
      final localRun = _runLocalDataSource.getRunById(cloudRun.id);

      if (localRun == null) {
        // New run from cloud - save it
        await _runLocalDataSource.saveRun(cloudRun);
      } else {
        // Compare timestamps - keep newer version
        if (cloudRun.startTime.isAfter(localRun.startTime)) {
          await _runLocalDataSource.saveRun(cloudRun);
        }
        // else: local is newer, keep it (don't overwrite)
      }
    }
  }

  /// Fetch all goals from Firestore and save to local
  /// Uses timestamp-based conflict resolution to prevent data loss
  Future<void> fetchGoalsFromCloud(String userId) async {
    if (!await isOnline()) {
      throw Exception('Cannot fetch goals while offline');
    }

    final cloudGoals = await _firestoreDataSource.fetchGoals(userId);
    print('📥 Fetched ${cloudGoals.length} goals from Firestore');

    int saved = 0;
    int skipped = 0;

    for (final cloudGoal in cloudGoals) {
      final localGoal = _goalLocalDataSource.getGoalById(cloudGoal.id);

      if (localGoal == null) {
        // New goal from cloud - save it
        await _goalLocalDataSource.saveGoal(cloudGoal);
        saved++;
      } else {
        // Compare timestamps - keep newer version
        if (cloudGoal.updatedAt.isAfter(localGoal.updatedAt)) {
          await _goalLocalDataSource.saveGoal(cloudGoal);
          saved++;
        } else {
          skipped++;
        }
        // else: local is newer, keep it (don't overwrite)
      }
    }

    print('💾 Saved $saved goals, skipped $skipped (local newer)');
  }

  /// Full sync: Upload local data and download cloud data
  Future<void> performFullSync(String userId) async {
    if (!await isOnline()) {
      throw Exception('Cannot perform full sync while offline');
    }

    // First, process any pending queue items
    await processSyncQueue();

    // Then fetch from cloud (this will merge with local data)
    await fetchRunsFromCloud(userId);
    await fetchGoalsFromCloud(userId);

    // Regenerate missing route polylines
    await regenerateMissingRoutes(userId);
  }

  /// Regenerate route polylines for goals that are missing them
  /// This happens when goals are synced from Firestore (polyline excluded to save space)
  Future<void> regenerateMissingRoutes(String userId) async {
    try {
      final goals = _goalLocalDataSource.getGoalsByUserId(userId);
      final directionsService = DirectionsService();

      for (final goal in goals) {
        // Skip if route already exists
        if (goal.routePolyline.isNotEmpty) continue;

        print('🔄 Regenerating route for goal: ${goal.name}');

        // Build waypoints from start → milestones → destination
        final waypoints = <DirectionsCoordinate>[
          // Start location
          DirectionsCoordinate(
            latitude: goal.startLocation.latitude,
            longitude: goal.startLocation.longitude,
          ),
          // Milestone locations (ordered by distanceFromStart)
          ...goal.milestones
              .map((m) => DirectionsCoordinate(
                    latitude: m.location.latitude,
                    longitude: m.location.longitude,
                  ))
              .toList(),
          // Destination location
          DirectionsCoordinate(
            latitude: goal.destinationLocation.latitude,
            longitude: goal.destinationLocation.longitude,
          ),
        ];

        // Mapbox supports max 25 waypoints per request
        // If we have more, we need to batch requests
        if (waypoints.length <= 25) {
          final route = await directionsService.getRouteWithWaypoints(
            waypoints: waypoints,
          );

          if (route != null) {
            // Convert route coordinates to flat list [lat, lng, lat, lng, ...]
            final polyline = <double>[];
            for (final coord in route.coordinates) {
              polyline.add(coord.latitude);
              polyline.add(coord.longitude);
            }

            // Create updated goal with regenerated polyline
            final goalWithPolyline = GoalModel(
              id: goal.id,
              userId: goal.userId,
              name: goal.name,
              startLocation: goal.startLocation,
              destinationLocation: goal.destinationLocation,
              totalDistance: route.distance, // Use regenerated distance
              currentProgress: goal.currentProgress,
              milestones: goal.milestones,
              routePolyline: polyline, // Add regenerated polyline
              isActive: goal.isActive,
              isCompleted: goal.isCompleted,
              completedAt: goal.completedAt,
              isSynced: goal.isSynced,
              createdAt: goal.createdAt,
              updatedAt: goal.updatedAt,
            );
            await _goalLocalDataSource.saveGoal(goalWithPolyline);
            print('✅ Route regenerated: ${polyline.length / 2} coordinate pairs');
          } else {
            print('❌ Failed to regenerate route for ${goal.name}');
          }
        } else {
          // TODO: Handle routes with >25 waypoints (batch multiple requests)
          print('⚠️ Goal has ${waypoints.length} waypoints, need to batch requests');
        }
      }
    } catch (e) {
      print('❌ Error regenerating routes: $e');
      // Don't throw - sync should continue even if route regeneration fails
    }
  }

  /// Get sync queue status
  SyncQueueStatus getSyncQueueStatus() {
    final box = _getBox;
    if (box == null) {
      return SyncQueueStatus(
        pendingCount: 0,
        failedCount: 0,
        isSyncing: false,
      );
    }

    final items = box.values.toList();
    final pendingCount = items.length;
    final failedCount = items.where((item) => item.retryCount > 0).length;

    return SyncQueueStatus(
      pendingCount: pendingCount,
      failedCount: failedCount,
      isSyncing: _isSyncing,
    );
  }

  /// Clear the sync queue (use with caution)
  Future<void> clearSyncQueue() async {
    final box = _getBox;
    if (box == null) return;
    await box.clear();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}

/// Sync queue status information
class SyncQueueStatus {
  final int pendingCount;
  final int failedCount;
  final bool isSyncing;

  SyncQueueStatus({
    required this.pendingCount,
    required this.failedCount,
    required this.isSyncing,
  });

  bool get hasPendingItems => pendingCount > 0;
  bool get hasFailedItems => failedCount > 0;
  bool get isIdle => !isSyncing && pendingCount == 0;
}
