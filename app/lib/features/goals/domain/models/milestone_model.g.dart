// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MilestoneModelAdapter extends TypeAdapter<MilestoneModel> {
  @override
  final int typeId = 3;

  @override
  MilestoneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MilestoneModel(
      id: fields[0] as String,
      location: fields[1] as LocationModel,
      distanceFromStart: fields[2] as double,
      photoUrl: fields[3] as String?,
      description: fields[4] as String?,
      funFact: fields[5] as String?,
      isReached: fields[6] as bool,
      reachedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MilestoneModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.distanceFromStart)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.funFact)
      ..writeByte(6)
      ..write(obj.isReached)
      ..writeByte(7)
      ..write(obj.reachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
