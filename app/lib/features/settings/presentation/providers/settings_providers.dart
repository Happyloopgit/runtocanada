import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/features/settings/domain/models/user_settings_hive.dart';
import 'package:run_to_canada/features/settings/data/datasources/user_local_datasource.dart';
import 'package:run_to_canada/core/data/services/hive_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider for UserLocalDataSource
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSource();
});

/// Provider for current user settings
/// Returns default settings when no user is logged in
final userSettingsProvider = StreamProvider<UserSettingsHive>((ref) {
  final dataSource = ref.watch(userLocalDataSourceProvider);
  return dataSource.watchSettings();
});

/// Settings state notifier
class SettingsNotifier extends StateNotifier<UserSettingsHive> {
  final UserLocalDataSource _dataSource;

  SettingsNotifier(this._dataSource)
      : super(UserSettingsHive.defaultSettings('local')) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _dataSource.getSettings();
    state = settings;
  }

  Future<void> setUseMetricUnits(bool value) async {
    state = state.copyWith(useMetric: value, updatedAt: DateTime.now());
    await _dataSource.saveSettings(state);
  }

  Future<void> setDefaultMapStyle(MapStyle style) async {
    state = state.copyWith(
      mapStyle: _mapStyleToString(style),
      updatedAt: DateTime.now(),
    );
    await _dataSource.saveSettings(state);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(
      notificationsEnabled: value,
      updatedAt: DateTime.now(),
    );
    await _dataSource.saveSettings(state);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    state = state.copyWith(
      darkModeEnabled: value,
      updatedAt: DateTime.now(),
    );
    await _dataSource.saveSettings(state);
  }

  String _mapStyleToString(MapStyle style) {
    switch (style) {
      case MapStyle.streets:
        return 'streets';
      case MapStyle.outdoors:
        return 'outdoors';
      case MapStyle.light:
        return 'light';
      case MapStyle.dark:
        return 'dark';
      case MapStyle.satellite:
        return 'satellite';
      case MapStyle.satelliteStreets:
        return 'satelliteStreets';
    }
  }

  /// Delete user account and all data
  Future<void> deleteAccount() async {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final userId = user.uid;

    // Delete Firestore data
    final firestore = FirebaseFirestore.instance;

    // Delete runs
    final runsSnapshot = await firestore
        .collection('runs')
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in runsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete goals
    final goalsSnapshot = await firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in goalsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete user profile
    await firestore.collection('users').doc(userId).delete();

    // Delete user-specific Hive boxes from disk
    await HiveService.deleteUserBoxes(userId);

    // Delete Firebase Auth account
    await user.delete();
  }
}

/// Provider for settings notifier
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, UserSettingsHive>((ref) {
  final dataSource = ref.watch(userLocalDataSourceProvider);
  return SettingsNotifier(dataSource);
});

/// Provider for just the dark mode state (for MaterialApp to watch)
final darkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.darkModeEnabled;
});
