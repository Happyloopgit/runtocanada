import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing the authenticated user
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final UserSettings settings;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.premiumExpiresAt,
    required this.settings,
  });

  /// Create a UserModel from Firebase Auth user
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: displayName ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      settings: UserSettings.defaultSettings(),
    );
  }

  /// Create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isPremium: data['isPremium'] ?? false,
      premiumExpiresAt: data['premiumExpiresAt'] != null
          ? (data['premiumExpiresAt'] as Timestamp).toDate()
          : null,
      settings: data['settings'] != null
          ? UserSettings.fromMap(data['settings'])
          : UserSettings.defaultSettings(),
    );
  }

  /// Convert UserModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt != null
          ? Timestamp.fromDate(premiumExpiresAt!)
          : null,
      'settings': settings.toMap(),
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    UserSettings? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      settings: settings ?? this.settings,
    );
  }

  /// Check if user has active premium subscription
  bool get hasActivePremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return false;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }
}

/// User settings model
class UserSettings {
  final String distanceUnit; // 'km' or 'miles'
  final String temperatureUnit; // 'celsius' or 'fahrenheit'
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticFeedbackEnabled;
  final bool darkModeEnabled;
  final String? goalDestination; // e.g., 'Toronto', 'Vancouver'
  final double? goalDistanceKm; // Total distance to goal

  UserSettings({
    required this.distanceUnit,
    required this.temperatureUnit,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.hapticFeedbackEnabled,
    required this.darkModeEnabled,
    this.goalDestination,
    this.goalDistanceKm,
  });

  /// Default settings
  factory UserSettings.defaultSettings() {
    return UserSettings(
      distanceUnit: 'km',
      temperatureUnit: 'celsius',
      notificationsEnabled: true,
      soundEnabled: true,
      hapticFeedbackEnabled: true,
      darkModeEnabled: false,
    );
  }

  /// Create UserSettings from map
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      distanceUnit: map['distanceUnit'] ?? 'km',
      temperatureUnit: map['temperatureUnit'] ?? 'celsius',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      hapticFeedbackEnabled: map['hapticFeedbackEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      goalDestination: map['goalDestination'],
      goalDistanceKm: map['goalDistanceKm']?.toDouble(),
    );
  }

  /// Convert UserSettings to map
  Map<String, dynamic> toMap() {
    return {
      'distanceUnit': distanceUnit,
      'temperatureUnit': temperatureUnit,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'darkModeEnabled': darkModeEnabled,
      'goalDestination': goalDestination,
      'goalDistanceKm': goalDistanceKm,
    };
  }

  /// Create a copy of UserSettings with updated fields
  UserSettings copyWith({
    String? distanceUnit,
    String? temperatureUnit,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticFeedbackEnabled,
    bool? darkModeEnabled,
    String? goalDestination,
    double? goalDistanceKm,
  }) {
    return UserSettings(
      distanceUnit: distanceUnit ?? this.distanceUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      goalDestination: goalDestination ?? this.goalDestination,
      goalDistanceKm: goalDistanceKm ?? this.goalDistanceKm,
    );
  }
}
