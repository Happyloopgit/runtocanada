// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunModelAdapter extends TypeAdapter<RunModel> {
  @override
  final int typeId = 0;

  @override
  RunModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      totalDistance: fields[4] as double,
      duration: fields[5] as int,
      averagePace: fields[6] as double,
      maxSpeed: fields[7] as double,
      calories: fields[8] as double,
      elevationGain: fields[9] as double,
      routePoints: (fields[10] as List).cast<RoutePoint>(),
      notes: fields[11] as String?,
      isSynced: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RunModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.totalDistance)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.averagePace)
      ..writeByte(7)
      ..write(obj.maxSpeed)
      ..writeByte(8)
      ..write(obj.calories)
      ..writeByte(9)
      ..write(obj.elevationGain)
      ..writeByte(10)
      ..write(obj.routePoints)
      ..writeByte(11)
      ..write(obj.notes)
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
      other is RunModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
