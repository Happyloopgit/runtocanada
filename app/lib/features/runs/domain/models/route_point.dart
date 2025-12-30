import 'package:hive/hive.dart';

part 'route_point.g.dart';

@HiveType(typeId: 1)
class RoutePoint extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double altitude;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double speed; // m/s

  @HiveField(5)
  final double accuracy; // meters

  RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    required this.speed,
    required this.accuracy,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      speed: json['speed'] as double,
      accuracy: json['accuracy'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'accuracy': accuracy,
    };
  }

  @override
  String toString() {
    return 'RoutePoint(lat: $latitude, lng: $longitude, time: $timestamp)';
  }
}
