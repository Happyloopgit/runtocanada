import 'package:hive/hive.dart';
import 'location_model.dart';
import 'milestone_model.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 4)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final LocationModel startLocation;

  @HiveField(4)
  final LocationModel destinationLocation;

  @HiveField(5)
  final double totalDistance; // in meters

  @HiveField(6)
  final double currentProgress; // in meters

  @HiveField(7)
  final List<MilestoneModel> milestones;

  @HiveField(8)
  final List<double> routePolyline; // encoded route as list of lat/lng pairs

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final bool isCompleted;

  @HiveField(11)
  final DateTime? completedAt;

  @HiveField(12)
  final bool isSynced;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.startLocation,
    required this.destinationLocation,
    required this.totalDistance,
    this.currentProgress = 0.0,
    required this.milestones,
    required this.routePolyline,
    this.isActive = true,
    this.isCompleted = false,
    this.completedAt,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters for computed values
  double get totalDistanceInKm => totalDistance / 1000;
  double get totalDistanceInMiles => totalDistance / 1609.34;
  double get currentProgressInKm => currentProgress / 1000;
  double get currentProgressInMiles => currentProgress / 1609.34;
  double get remainingDistanceInKm => (totalDistance - currentProgress) / 1000;
  double get remainingDistanceInMiles => (totalDistance - currentProgress) / 1609.34;
  double get progressPercentage => (currentProgress / totalDistance) * 100;

  int get milestonesReached => milestones.where((m) => m.isReached).length;
  int get totalMilestones => milestones.length;

  // Get current virtual location based on progress
  LocationModel? get currentVirtualLocation {
    if (currentProgress <= 0) return startLocation;
    if (currentProgress >= totalDistance) return destinationLocation;

    // Find the milestone closest to current progress
    MilestoneModel? closestMilestone;
    double minDistance = double.infinity;

    for (final milestone in milestones) {
      final distance = (milestone.distanceFromStart - currentProgress).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestMilestone = milestone;
      }
    }

    return closestMilestone?.location;
  }

  // Next milestone to reach
  MilestoneModel? get nextMilestone {
    for (final milestone in milestones) {
      if (!milestone.isReached && milestone.distanceFromStart > currentProgress) {
        return milestone;
      }
    }
    return null;
  }

  // Firestore conversion
  factory GoalModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GoalModel(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      startLocation: LocationModel.fromJson(data['startLocation'] as Map<String, dynamic>),
      destinationLocation: LocationModel.fromJson(data['destinationLocation'] as Map<String, dynamic>),
      totalDistance: (data['totalDistance'] as num).toDouble(),
      currentProgress: (data['currentProgress'] as num).toDouble(),
      milestones: (data['milestones'] as List)
          .map((m) => MilestoneModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      // routePolyline not synced - empty list, will be regenerated from start/destination
      routePolyline: [],
      isActive: data['isActive'] as bool? ?? true,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      isSynced: true,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startLocation': startLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'totalDistance': totalDistance,
      'currentProgress': currentProgress,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      // routePolyline excluded - too large for Firestore, regenerate from start/destination
      'isActive': isActive,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  GoalModel copyWith({
    String? name,
    double? currentProgress,
    List<MilestoneModel>? milestones,
    bool? isActive,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      startLocation: startLocation,
      destinationLocation: destinationLocation,
      totalDistance: totalDistance,
      currentProgress: currentProgress ?? this.currentProgress,
      milestones: milestones ?? this.milestones,
      routePolyline: routePolyline,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GoalModel(name: $name, progress: ${progressPercentage.toStringAsFixed(1)}%, milestones: $milestonesReached/$totalMilestones)';
  }
}
