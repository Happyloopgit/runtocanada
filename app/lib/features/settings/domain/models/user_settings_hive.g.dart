// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsHiveAdapter extends TypeAdapter<UserSettingsHive> {
  @override
  final int typeId = 5;

  @override
  UserSettingsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsHive(
      userId: fields[0] as String,
      useMetric: fields[1] as bool,
      mapStyle: fields[2] as String,
      notificationsEnabled: fields[3] as bool,
      milestoneNotifications: fields[4] as bool,
      runReminders: fields[5] as bool,
      isPremium: fields[6] as bool,
      premiumExpiresAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.useMetric)
      ..writeByte(2)
      ..write(obj.mapStyle)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.milestoneNotifications)
      ..writeByte(5)
      ..write(obj.runReminders)
      ..writeByte(6)
      ..write(obj.isPremium)
      ..writeByte(7)
      ..write(obj.premiumExpiresAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
