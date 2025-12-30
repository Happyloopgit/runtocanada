// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 4;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      startLocation: fields[3] as LocationModel,
      destinationLocation: fields[4] as LocationModel,
      totalDistance: fields[5] as double,
      currentProgress: fields[6] as double,
      milestones: (fields[7] as List).cast<MilestoneModel>(),
      routePolyline: (fields[8] as List).cast<double>(),
      isActive: fields[9] as bool,
      isCompleted: fields[10] as bool,
      completedAt: fields[11] as DateTime?,
      isSynced: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.startLocation)
      ..writeByte(4)
      ..write(obj.destinationLocation)
      ..writeByte(5)
      ..write(obj.totalDistance)
      ..writeByte(6)
      ..write(obj.currentProgress)
      ..writeByte(7)
      ..write(obj.milestones)
      ..writeByte(8)
      ..write(obj.routePolyline)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.completedAt)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
