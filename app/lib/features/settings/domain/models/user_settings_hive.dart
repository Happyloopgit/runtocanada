import 'package:hive/hive.dart';

part 'user_settings_hive.g.dart';

@HiveType(typeId: 5)
class UserSettingsHive extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final bool useMetric; // true = km, false = miles

  @HiveField(2)
  final String mapStyle; // 'streets', 'satellite', 'outdoors'

  @HiveField(3)
  final bool notificationsEnabled;

  @HiveField(4)
  final bool milestoneNotifications;

  @HiveField(5)
  final bool runReminders;

  @HiveField(6)
  final bool isPremium;

  @HiveField(7)
  final DateTime? premiumExpiresAt;

  @HiveField(8)
  final DateTime updatedAt;

  UserSettingsHive({
    required this.userId,
    this.useMetric = true,
    this.mapStyle = 'streets',
    this.notificationsEnabled = true,
    this.milestoneNotifications = true,
    this.runReminders = false,
    this.isPremium = false,
    this.premiumExpiresAt,
    required this.updatedAt,
  });

  factory UserSettingsHive.defaultSettings(String userId) {
    return UserSettingsHive(
      userId: userId,
      updatedAt: DateTime.now(),
    );
  }

  UserSettingsHive copyWith({
    bool? useMetric,
    String? mapStyle,
    bool? notificationsEnabled,
    bool? milestoneNotifications,
    bool? runReminders,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsHive(
      userId: userId,
      useMetric: useMetric ?? this.useMetric,
      mapStyle: mapStyle ?? this.mapStyle,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      milestoneNotifications: milestoneNotifications ?? this.milestoneNotifications,
      runReminders: runReminders ?? this.runReminders,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'useMetric': useMetric,
      'mapStyle': mapStyle,
      'notificationsEnabled': notificationsEnabled,
      'milestoneNotifications': milestoneNotifications,
      'runReminders': runReminders,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettingsHive.fromJson(Map<String, dynamic> json) {
    return UserSettingsHive(
      userId: json['userId'] as String,
      useMetric: json['useMetric'] as bool? ?? true,
      mapStyle: json['mapStyle'] as String? ?? 'streets',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      milestoneNotifications: json['milestoneNotifications'] as bool? ?? true,
      runReminders: json['runReminders'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserSettingsHive(userId: $userId, metric: $useMetric, premium: $isPremium)';
  }
}
