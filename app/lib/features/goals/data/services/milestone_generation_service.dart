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
  /// Uses adaptive spacing: starts small for quick wins, gradually increases
  Future<List<MilestoneModel>> generateMilestones({
    required DirectionsRoute route,
    int? targetMilestoneCount,
  }) async {
    final milestones = <MilestoneModel>[];

    // Generate adaptive milestone distances (in meters)
    final milestoneDistances = _generateAdaptiveMilestoneDistances(route.distance);

    if (milestoneDistances.isEmpty) {
      return milestones;
    }

    // Generate milestone points along the route
    for (int i = 0; i < milestoneDistances.length; i++) {
      final targetDistance = milestoneDistances[i];
      final coordinate = _findCoordinateAtDistance(route, targetDistance);

      if (coordinate != null) {
        // Reverse geocode to get location name
        // Priority: place (city/town) > locality > address components
        // Exclude 'region' to avoid getting state names
        final geocodingResult = await _geocodingService.reverseGeocode(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          types: ['place', 'locality'], // Removed 'region' to avoid state names
        );

        // Create location model
        // Use address field (which contains city name for 'place' type) or fall back
        final cityName = geocodingResult?.address ?? geocodingResult?.region;
        final milestoneNumber = i + 1; // 1-indexed for display
        final location = LocationModel(
          placeName: cityName ?? 'Milestone $milestoneNumber',
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          address: geocodingResult?.fullName,
          city: cityName,
          country: geocodingResult?.country,
        );

        // Create milestone
        final milestone = MilestoneModel(
          id: 'milestone_$milestoneNumber',
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

  /// Generate adaptive milestone distances that start small and gradually increase
  /// Psychology: Quick early wins motivate users, larger gaps acceptable later
  ///
  /// Example for 1743km route:
  /// - Milestone 1: 50km (quick first achievement!)
  /// - Milestone 2: 100km (+50km gap)
  /// - Milestone 3: 175km (+75km gap)
  /// - Milestone 4: 275km (+100km gap)
  /// - And so on with gradually increasing gaps
  List<double> _generateAdaptiveMilestoneDistances(double totalDistance) {
    final distances = <double>[];
    final distanceInKm = totalDistance / 1000;

    // No milestones for very short routes
    if (distanceInKm < 25) {
      return distances;
    }

    // Starting parameters
    double currentDistance = 0;
    double initialGap = 50000; // Start with 50km gap (in meters)
    double gapIncrement = 25000; // Increase gap by 25km each time (slower growth)
    double currentGap = initialGap;

    // Generate milestones until we reach the total distance
    while (currentDistance + currentGap < totalDistance) {
      currentDistance += currentGap;
      distances.add(currentDistance);

      // Gradually increase the gap for next milestone
      currentGap += gapIncrement;

      // Cap maximum gap at 250km to keep it reasonable
      if (currentGap > 250000) {
        currentGap = 250000;
      }
    }

    return distances;
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
