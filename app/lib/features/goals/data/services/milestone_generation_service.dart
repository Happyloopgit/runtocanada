import 'dart:math';
import '../../../../core/services/directions_service.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../domain/models/location_model.dart';
import '../../domain/models/milestone_model.dart';

/// Service for generating milestones along a route
class MilestoneGenerationService {
  final GeocodingService _geocodingService;

  MilestoneGenerationService({
    GeocodingService? geocodingService,
  })  : _geocodingService = geocodingService ?? GeocodingService();

  /// Generate milestones along a route
  ///
  /// [route] - The calculated route
  /// [targetMilestoneCount] - Desired number of milestones (default: auto-calculated)
  ///
  /// Returns a list of [MilestoneModel] objects
  Future<List<MilestoneModel>> generateMilestones({
    required DirectionsRoute route,
    int? targetMilestoneCount,
  }) async {
    final milestones = <MilestoneModel>[];

    // Calculate how many milestones to generate
    final milestoneCount = targetMilestoneCount ?? _calculateMilestoneCount(route.distanceInKm);

    if (milestoneCount == 0) {
      return milestones;
    }

    // Calculate distance between milestones
    final distanceBetweenMilestones = route.distance / (milestoneCount + 1);

    // Generate milestone points along the route
    for (int i = 1; i <= milestoneCount; i++) {
      final targetDistance = distanceBetweenMilestones * i;
      final coordinate = _findCoordinateAtDistance(route, targetDistance);

      if (coordinate != null) {
        // Reverse geocode to get location name
        final geocodingResult = await _geocodingService.reverseGeocode(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          types: ['place', 'locality', 'region'],
        );

        // Create location model
        final location = LocationModel(
          placeName: geocodingResult?.placeName ?? 'Milestone $i',
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          address: geocodingResult?.fullName,
          city: geocodingResult?.region,
          country: geocodingResult?.country,
        );

        // Create milestone
        final milestone = MilestoneModel(
          id: 'milestone_$i',
          location: location,
          distanceFromStart: targetDistance,
          isReached: false,
          reachedAt: null,
        );

        milestones.add(milestone);
      }
    }

    return milestones;
  }

  /// Calculate optimal number of milestones based on route distance
  int _calculateMilestoneCount(double distanceInKm) {
    if (distanceInKm < 50) {
      return 0; // No milestones for very short routes
    } else if (distanceInKm < 100) {
      return 1; // 1 milestone for short routes
    } else if (distanceInKm < 250) {
      return 2; // 2 milestones for medium routes
    } else if (distanceInKm < 500) {
      return 3; // 3 milestones for medium-long routes
    } else if (distanceInKm < 1000) {
      return 5; // 5 milestones for long routes
    } else if (distanceInKm < 2000) {
      return 7; // 7 milestones for very long routes
    } else {
      return 10; // 10 milestones for ultra-long routes
    }
  }

  /// Find coordinate at a specific distance along the route
  DirectionsCoordinate? _findCoordinateAtDistance(
    DirectionsRoute route,
    double targetDistance,
  ) {
    double accumulatedDistance = 0.0;

    for (int i = 0; i < route.coordinates.length - 1; i++) {
      final current = route.coordinates[i];
      final next = route.coordinates[i + 1];

      final segmentDistance = _calculateDistance(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );

      if (accumulatedDistance + segmentDistance >= targetDistance) {
        // Target distance is within this segment
        final remainingDistance = targetDistance - accumulatedDistance;
        final fraction = remainingDistance / segmentDistance;

        // Interpolate coordinate
        return DirectionsCoordinate(
          latitude: current.latitude + (next.latitude - current.latitude) * fraction,
          longitude: current.longitude + (next.longitude - current.longitude) * fraction,
        );
      }

      accumulatedDistance += segmentDistance;
    }

    // If we've gone through all points, return the last coordinate
    if (route.coordinates.isNotEmpty) {
      final last = route.coordinates.last;
      return DirectionsCoordinate(
        latitude: last.latitude,
        longitude: last.longitude,
      );
    }

    return null;
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
