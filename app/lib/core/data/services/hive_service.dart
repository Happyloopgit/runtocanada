import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/runs/domain/models/run_model.dart';
import '../../../features/runs/domain/models/route_point.dart';
import '../../../features/goals/domain/models/goal_model.dart';
import '../../../features/goals/domain/models/location_model.dart';
import '../../../features/goals/domain/models/milestone_model.dart';
import '../../../features/settings/domain/models/user_settings_hive.dart';
import '../models/sync_queue_item.dart';

class HiveService {
  static const String runsBox = 'runs';
  static const String goalsBox = 'goals';
  static const String userSettingsBox = 'userSettings';
  static const String syncQueueBox = 'syncQueue';
  static const String cacheBox = 'cache';

  /// Initialize Hive and register all type adapters
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

    // Open all boxes
    await openBoxes();
  }

  /// Open all Hive boxes
  static Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(runsBox)) {
      await Hive.openBox<RunModel>(runsBox);
    }
    if (!Hive.isBoxOpen(goalsBox)) {
      await Hive.openBox<GoalModel>(goalsBox);
    }
    if (!Hive.isBoxOpen(userSettingsBox)) {
      await Hive.openBox<UserSettingsHive>(userSettingsBox);
    }
    if (!Hive.isBoxOpen(syncQueueBox)) {
      await Hive.openBox<SyncQueueItem>(syncQueueBox);
    }
    if (!Hive.isBoxOpen(cacheBox)) {
      await Hive.openBox(cacheBox); // Generic box for various cache data
    }
  }

  /// Get a specific box
  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Compact all boxes to optimize storage
  static Future<void> compactAllBoxes() async {
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
    if (Hive.isBoxOpen(cacheBox)) {
      await Hive.box(cacheBox).compact();
    }
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all data (use with caution, for logout/testing)
  static Future<void> clearAllData() async {
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
    if (Hive.isBoxOpen(cacheBox)) {
      await Hive.box(cacheBox).clear();
    }
  }

  /// Delete all boxes (for account deletion)
  static Future<void> deleteAllBoxes() async {
    await Hive.deleteBoxFromDisk(runsBox);
    await Hive.deleteBoxFromDisk(goalsBox);
    await Hive.deleteBoxFromDisk(userSettingsBox);
    await Hive.deleteBoxFromDisk(syncQueueBox);
    await Hive.deleteBoxFromDisk(cacheBox);
  }
}
