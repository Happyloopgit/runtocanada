import 'package:hive/hive.dart';
import '../../domain/models/user_settings_hive.dart';
import '../../../../core/data/services/hive_service.dart';

class UserLocalDataSource {
  Box<UserSettingsHive>? _box;

  UserLocalDataSource() {
    // Don't initialize box in constructor - it will be lazy loaded
    // This prevents crashing when no user is logged in yet
  }

  /// Get the box if user is logged in, otherwise return null
  Box<UserSettingsHive>? get _getBox {
    if (_box != null) return _box;

    try {
      // Only try to get box if a user is logged in
      if (HiveService.currentUserId != null) {
        _box = HiveService.getBox<UserSettingsHive>(HiveService.userSettingsBox);
        return _box;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save or update user settings
  Future<void> saveUserSettings(UserSettingsHive settings) async {
    final box = _getBox;
    if (box == null) return;
    await box.put(settings.userId, settings);
  }

  /// Get user settings by user ID
  UserSettingsHive? getUserSettings(String userId) {
    final box = _getBox;
    if (box == null) return null;
    return box.get(userId);
  }

  /// Get user settings or create default
  Future<UserSettingsHive> getUserSettingsOrDefault(String userId) async {
    var settings = getUserSettings(userId);
    if (settings == null) {
      settings = UserSettingsHive.defaultSettings(userId);
      await saveUserSettings(settings);
    }
    return settings;
  }

  /// Update specific setting
  Future<void> updateSetting(
    String userId,
    UserSettingsHive Function(UserSettingsHive) update,
  ) async {
    final settings = await getUserSettingsOrDefault(userId);
    final updatedSettings = update(settings);
    await saveUserSettings(updatedSettings.copyWith(updatedAt: DateTime.now()));
  }

  /// Update metric preference
  Future<void> updateMetricPreference(String userId, bool useMetric) async {
    await updateSetting(userId, (settings) => settings.copyWith(useMetric: useMetric));
  }

  /// Update map style preference
  Future<void> updateMapStyle(String userId, String mapStyle) async {
    await updateSetting(userId, (settings) => settings.copyWith(mapStyle: mapStyle));
  }

  /// Update notifications enabled
  Future<void> updateNotificationsEnabled(String userId, bool enabled) async {
    await updateSetting(
      userId,
      (settings) => settings.copyWith(notificationsEnabled: enabled),
    );
  }

  /// Update milestone notifications
  Future<void> updateMilestoneNotifications(String userId, bool enabled) async {
    await updateSetting(
      userId,
      (settings) => settings.copyWith(milestoneNotifications: enabled),
    );
  }

  /// Update run reminders
  Future<void> updateRunReminders(String userId, bool enabled) async {
    await updateSetting(
      userId,
      (settings) => settings.copyWith(runReminders: enabled),
    );
  }

  /// Update premium status
  Future<void> updatePremiumStatus(
    String userId,
    bool isPremium, [
    DateTime? expiresAt,
  ]) async {
    await updateSetting(
      userId,
      (settings) => settings.copyWith(
        isPremium: isPremium,
        premiumExpiresAt: expiresAt,
      ),
    );
  }

  /// Check if user is premium
  bool isPremiumUser(String userId) {
    final settings = getUserSettings(userId);
    if (settings == null || !settings.isPremium) return false;

    // Check if premium has expired
    if (settings.premiumExpiresAt != null) {
      return DateTime.now().isBefore(settings.premiumExpiresAt!);
    }

    return settings.isPremium;
  }

  /// Delete user settings
  Future<void> deleteUserSettings(String userId) async {
    final box = _getBox;
    if (box == null) return;
    await box.delete(userId);
  }

  /// Clear all user settings
  Future<void> clearAllUserSettings() async {
    final box = _getBox;
    if (box == null) return;
    await box.clear();
  }

  /// Check if user settings exist
  bool hasUserSettings(String userId) {
    final box = _getBox;
    if (box == null) return false;
    return box.containsKey(userId);
  }

  /// Get all user settings (for admin/debug purposes)
  List<UserSettingsHive> getAllUserSettings() {
    final box = _getBox;
    if (box == null) return [];
    return box.values.toList();
  }

  /// Get default settings (first user or create new)
  Future<UserSettingsHive> getSettings() async {
    final box = _getBox;
    if (box == null || box.isEmpty) {
      // Return default settings without saving if no user is logged in
      return UserSettingsHive.defaultSettings('local');
    }
    return box.values.first;
  }

  /// Watch settings changes (stream)
  Stream<UserSettingsHive> watchSettings() {
    final box = _getBox;
    if (box == null) {
      // Return a stream with default settings when no user is logged in
      return Stream.value(UserSettingsHive.defaultSettings('local'));
    }
    return box.watch().map((event) {
      if (box.isEmpty) return UserSettingsHive.defaultSettings('local');
      return box.values.first;
    });
  }

  /// Save settings (alias for saveUserSettings)
  Future<void> saveSettings(UserSettingsHive settings) async {
    await saveUserSettings(settings);
  }
}
