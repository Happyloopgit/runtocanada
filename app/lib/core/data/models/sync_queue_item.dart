import 'package:hive/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 6)
enum SyncItemType {
  @HiveField(0)
  run,
  @HiveField(1)
  goal,
  @HiveField(2)
  userSettings,
}

@HiveType(typeId: 7)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncItemType type;

  @HiveField(2)
  final String itemId; // ID of the run/goal/settings

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retryCount;

  @HiveField(5)
  final DateTime? lastRetryAt;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.itemId,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
  });

  SyncQueueItem copyWith({
    int? retryCount,
    DateTime? lastRetryAt,
  }) {
    return SyncQueueItem(
      id: id,
      type: type,
      itemId: itemId,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
    );
  }

  @override
  String toString() {
    return 'SyncQueueItem(type: $type, itemId: $itemId, retries: $retryCount)';
  }
}
