// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 7;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      id: fields[0] as String,
      type: fields[1] as SyncItemType,
      itemId: fields[2] as String,
      createdAt: fields[3] as DateTime,
      retryCount: fields[4] as int,
      lastRetryAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.itemId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.lastRetryAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncItemTypeAdapter extends TypeAdapter<SyncItemType> {
  @override
  final int typeId = 6;

  @override
  SyncItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncItemType.run;
      case 1:
        return SyncItemType.goal;
      case 2:
        return SyncItemType.userSettings;
      default:
        return SyncItemType.run;
    }
  }

  @override
  void write(BinaryWriter writer, SyncItemType obj) {
    switch (obj) {
      case SyncItemType.run:
        writer.writeByte(0);
        break;
      case SyncItemType.goal:
        writer.writeByte(1);
        break;
      case SyncItemType.userSettings:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
