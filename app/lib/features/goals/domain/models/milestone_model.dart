import 'package:hive/hive.dart';
import 'location_model.dart';

part 'milestone_model.g.dart';

@HiveType(typeId: 3)
class MilestoneModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final LocationModel location;

  @HiveField(2)
  final double distanceFromStart; // in meters

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? funFact;

  @HiveField(6)
  final bool isReached;

  @HiveField(7)
  final DateTime? reachedAt;

  MilestoneModel({
    required this.id,
    required this.location,
    required this.distanceFromStart,
    this.photoUrl,
    this.description,
    this.funFact,
    this.isReached = false,
    this.reachedAt,
  });

  // Getters for computed values
  double get distanceInKm => distanceFromStart / 1000;
  double get distanceInMiles => distanceFromStart / 1609.34;

  String get cityName => location.city ?? location.placeName;

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as String,
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      distanceFromStart: (json['distanceFromStart'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      funFact: json['funFact'] as String?,
      isReached: json['isReached'] as bool? ?? false,
      reachedAt: json['reachedAt'] != null
          ? DateTime.parse(json['reachedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location.toJson(),
      'distanceFromStart': distanceFromStart,
      'photoUrl': photoUrl,
      'description': description,
      'funFact': funFact,
      'isReached': isReached,
      'reachedAt': reachedAt?.toIso8601String(),
    };
  }

  MilestoneModel copyWith({
    bool? isReached,
    DateTime? reachedAt,
    String? photoUrl,
    String? description,
    String? funFact,
  }) {
    return MilestoneModel(
      id: id,
      location: location,
      distanceFromStart: distanceFromStart,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      funFact: funFact ?? this.funFact,
      isReached: isReached ?? this.isReached,
      reachedAt: reachedAt ?? this.reachedAt,
    );
  }

  @override
  String toString() {
    return 'MilestoneModel(city: $cityName, distance: ${distanceInKm.toStringAsFixed(2)} km, reached: $isReached)';
  }
}
