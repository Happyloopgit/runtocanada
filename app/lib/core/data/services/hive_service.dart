import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/runs/domain/models/run_model.dart';
import '../../../features/runs/domain/models/route_point.dart';
import '../../../features/goals/domain/models/goal_model.dart';
import '../../../features/goals/domain/models/location_model.dart';
import '../../../features/goals/domain/models/milestone_model.dart';
import '../../../features/settings/domain/models/user_settings_hive.dart';
import '../models/sync_queue_item.dart';

class HiveService {
  // Global (non-user-specific) boxes
  static const String cacheBox = 'cache';

  // Current user ID (null when no user is logged in)
  static String? _currentUserId;

  /// Get the current user ID
  static String? get currentUserId => _currentUserId;

  /// Generate user-scoped box name
  static String _getUserBoxName(String userId, String boxType) {
    return 'user_${userId}_$boxType';
  }

  /// Box type identifiers
  static const String _runsBoxType = 'runs';
  static const String _goalsBoxType = 'goals';
  static const String _userSettingsBoxType = 'settings';
  static const String _syncQueueBoxType = 'syncQueue';

  /// Get box names for current user (backward compatibility)
  static String get runsBox => _currentUserId != null
      ? _getUserBoxName(_currentUserId!, _runsBoxType)
      : throw StateError('No user logged in. Call initializeForUser() first.');

  static String get goalsBox => _currentUserId != null
      ? _getUserBoxName(_currentUserId!, _goalsBoxType)
      : throw StateError('No user logged in. Call initializeForUser() first.');

  static String get userSettingsBox => _currentUserId != null
      ? _getUserBoxName(_currentUserId!, _userSettingsBoxType)
      : throw StateError('No user logged in. Call initializeForUser() first.');

  static String get syncQueueBox => _currentUserId != null
      ? _getUserBoxName(_currentUserId!, _syncQueueBoxType)
      : throw StateError('No user logged in. Call initializeForUser() first.');

  /// Initialize Hive and register all type adapters (called once at app start)
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all type adapters
    Hive.registerAdapter(RunModelAdapter());
    Hive.registerAdapter(RoutePointAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(LocationModelAdapter());
    Hive.registerAdapter(MilestoneModelAdapter());
    Hive.registerAdapter(UserSettingsHiveAdapter());
    Hive.registerAdapter(SyncItemTypeAdapter());
    Hive.registerAdapter(SyncQueueItemAdapter());

    // Open global boxes only
    await openGlobalBoxes();
  }

  /// Open global (non-user-specific) boxes
  static Future<void> openGlobalBoxes() async {
    if (!Hive.isBoxOpen(cacheBox)) {
      await Hive.openBox(cacheBox);
    }
  }

  /// Initialize boxes for a specific user (called after login)
  static Future<void> initializeForUser(String userId) async {
    // Close previous user's boxes if any
    if (_currentUserId != null && _currentUserId != userId) {
      await closeUserBoxes();
    }

    _currentUserId = userId;

    // Open user-scoped boxes
    final userRunsBox = _getUserBoxName(userId, _runsBoxType);
    final userGoalsBox = _getUserBoxName(userId, _goalsBoxType);
    final userSettingsBoxName = _getUserBoxName(userId, _userSettingsBoxType);
    final userSyncQueueBox = _getUserBoxName(userId, _syncQueueBoxType);

    if (!Hive.isBoxOpen(userRunsBox)) {
      await Hive.openBox<RunModel>(userRunsBox);
    }
    if (!Hive.isBoxOpen(userGoalsBox)) {
      await Hive.openBox<GoalModel>(userGoalsBox);
    }
    if (!Hive.isBoxOpen(userSettingsBoxName)) {
      await Hive.openBox<UserSettingsHive>(userSettingsBoxName);
    }
    if (!Hive.isBoxOpen(userSyncQueueBox)) {
      await Hive.openBox<SyncQueueItem>(userSyncQueueBox);
    }
  }

  /// Close current user's boxes (called on logout)
  static Future<void> closeUserBoxes() async {
    if (_currentUserId == null) return;

    final userRunsBox = _getUserBoxName(_currentUserId!, _runsBoxType);
    final userGoalsBox = _getUserBoxName(_currentUserId!, _goalsBoxType);
    final userSettingsBoxName = _getUserBoxName(_currentUserId!, _userSettingsBoxType);
    final userSyncQueueBox = _getUserBoxName(_currentUserId!, _syncQueueBoxType);

    if (Hive.isBoxOpen(userRunsBox)) {
      await Hive.box<RunModel>(userRunsBox).close();
    }
    if (Hive.isBoxOpen(userGoalsBox)) {
      await Hive.box<GoalModel>(userGoalsBox).close();
    }
    if (Hive.isBoxOpen(userSettingsBoxName)) {
      await Hive.box<UserSettingsHive>(userSettingsBoxName).close();
    }
    if (Hive.isBoxOpen(userSyncQueueBox)) {
      await Hive.box<SyncQueueItem>(userSyncQueueBox).close();
    }

    _currentUserId = null;
  }

  /// Get a specific box
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Compact all boxes to optimize storage (for current user)
  static Future<void> compactAllBoxes() async {
    if (_currentUserId == null) return;

    try {
      if (Hive.isBoxOpen(runsBox)) {
        await Hive.box<RunModel>(runsBox).compact();
      }
      if (Hive.isBoxOpen(goalsBox)) {
        await Hive.box<GoalModel>(goalsBox).compact();
      }
      if (Hive.isBoxOpen(userSettingsBox)) {
        await Hive.box<UserSettingsHive>(userSettingsBox).compact();
      }
      if (Hive.isBoxOpen(syncQueueBox)) {
        await Hive.box<SyncQueueItem>(syncQueueBox).compact();
      }
    } catch (e) {
      // Ignore errors if boxes aren't open
    }

    if (Hive.isBoxOpen(cacheBox)) {
      await Hive.box(cacheBox).compact();
    }
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    await closeUserBoxes();
    await Hive.close();
  }

  /// Clear current user's data (use with caution)
  static Future<void> clearAllData() async {
    if (_currentUserId == null) return;

    if (Hive.isBoxOpen(runsBox)) {
      await Hive.box<RunModel>(runsBox).clear();
    }
    if (Hive.isBoxOpen(goalsBox)) {
      await Hive.box<GoalModel>(goalsBox).clear();
    }
    if (Hive.isBoxOpen(userSettingsBox)) {
      await Hive.box<UserSettingsHive>(userSettingsBox).clear();
    }
    if (Hive.isBoxOpen(syncQueueBox)) {
      await Hive.box<SyncQueueItem>(syncQueueBox).clear();
    }
  }

  /// Delete specific user's boxes from disk (for account deletion)
  static Future<void> deleteUserBoxes(String userId) async {
    // Close boxes first if they belong to current user
    if (_currentUserId == userId) {
      await closeUserBoxes();
    }

    // Delete from disk
    await Hive.deleteBoxFromDisk(_getUserBoxName(userId, _runsBoxType));
    await Hive.deleteBoxFromDisk(_getUserBoxName(userId, _goalsBoxType));
    await Hive.deleteBoxFromDisk(_getUserBoxName(userId, _userSettingsBoxType));
    await Hive.deleteBoxFromDisk(_getUserBoxName(userId, _syncQueueBoxType));
  }

  /// Delete all boxes (legacy - now only deletes global boxes)
  /// For user data deletion, use deleteUserBoxes(userId)
  static Future<void> deleteAllBoxes() async {
    // Close user boxes first
    await closeUserBoxes();

    // Delete global cache
    if (Hive.isBoxOpen(cacheBox)) {
      await Hive.box(cacheBox).close();
    }
    await Hive.deleteBoxFromDisk(cacheBox);
  }
}
