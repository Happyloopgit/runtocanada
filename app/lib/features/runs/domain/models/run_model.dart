import 'package:hive/hive.dart';
import 'route_point.dart';

part 'run_model.g.dart';

@HiveType(typeId: 0)
class RunModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final double totalDistance; // in meters

  @HiveField(5)
  final int duration; // in seconds

  @HiveField(6)
  final double averagePace; // min/km

  @HiveField(7)
  final double maxSpeed; // m/s

  @HiveField(8)
  final double calories; // estimated calories burned

  @HiveField(9)
  final double elevationGain; // in meters

  @HiveField(10)
  final List<RoutePoint> routePoints;

  @HiveField(11)
  final String? notes;

  @HiveField(12)
  final bool isSynced;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  RunModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.totalDistance,
    required this.duration,
    required this.averagePace,
    required this.maxSpeed,
    required this.calories,
    required this.elevationGain,
    required this.routePoints,
    this.notes,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters for computed values
  double get distanceInKm => totalDistance / 1000;
  double get distanceInMiles => totalDistance / 1609.34;

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedAveragePace {
    final minutes = averagePace.floor();
    final seconds = ((averagePace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} min/km';
  }

  // Firestore conversion
  factory RunModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RunModel(
      id: id,
      userId: data['userId'] as String,
      startTime: DateTime.parse(data['startTime'] as String),
      endTime: DateTime.parse(data['endTime'] as String),
      totalDistance: (data['totalDistance'] as num).toDouble(),
      duration: data['duration'] as int,
      averagePace: (data['averagePace'] as num).toDouble(),
      maxSpeed: (data['maxSpeed'] as num).toDouble(),
      calories: (data['calories'] as num).toDouble(),
      elevationGain: (data['elevationGain'] as num).toDouble(),
      routePoints: (data['routePoints'] as List)
          .map((point) => RoutePoint.fromJson(point as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] as String?,
      isSynced: true,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalDistance': totalDistance,
      'duration': duration,
      'averagePace': averagePace,
      'maxSpeed': maxSpeed,
      'calories': calories,
      'elevationGain': elevationGain,
      'routePoints': routePoints.map((point) => point.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updating
  RunModel copyWith({
    String? notes,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return RunModel(
      id: id,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      totalDistance: totalDistance,
      duration: duration,
      averagePace: averagePace,
      maxSpeed: maxSpeed,
      calories: calories,
      elevationGain: elevationGain,
      routePoints: routePoints,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RunModel(id: $id, distance: ${distanceInKm.toStringAsFixed(2)} km, duration: $formattedDuration)';
  }
}
