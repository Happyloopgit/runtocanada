import 'package:hive/hive.dart';
import '../../domain/models/user_settings_hive.dart';
import '../../../../core/data/services/hive_service.dart';

class UserLocalDataSource {
  late Box<UserSettingsHive> _box;

  UserLocalDataSource() {
    _box = HiveService.getBox<UserSettingsHive>(HiveService.userSettingsBox);
  }

  /// Save or update user settings
  Future<void> saveUserSettings(UserSettingsHive settings) async {
    await _box.put(settings.userId, settings);
  }

  /// Get user settings by user ID
  UserSettingsHive? getUserSettings(String userId) {
    return _box.get(userId);
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
    await _box.delete(userId);
  }

  /// Clear all user settings
  Future<void> clearAllUserSettings() async {
    await _box.clear();
  }

  /// Check if user settings exist
  bool hasUserSettings(String userId) {
    return _box.containsKey(userId);
  }

  /// Get all user settings (for admin/debug purposes)
  List<UserSettingsHive> getAllUserSettings() {
    return _box.values.toList();
  }
}
