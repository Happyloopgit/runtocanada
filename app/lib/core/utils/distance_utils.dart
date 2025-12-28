import 'dart:math';
import '../constants/app_constants.dart';

/// Utility class for distance calculations
class DistanceUtils {
  /// Calculate distance between two points using Haversine formula
  /// Returns distance in meters
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371000; // meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format distance for display
  static String formatDistance(double meters, {required String unit}) {
    if (unit == AppConstants.imperialUnit) {
      // Convert to miles
      final double miles = meters * AppConstants.metersToMiles;
      if (miles < 0.1) {
        return '${(miles * 5280).toStringAsFixed(0)} ft';
      }
      return '${miles.toStringAsFixed(2)} mi';
    } else {
      // Convert to kilometers
      final double km = meters * AppConstants.metersToKm;
      if (km < 1) {
        return '${meters.toStringAsFixed(0)} m';
      }
      return '${km.toStringAsFixed(2)} km';
    }
  }

  /// Calculate pace (min/km or min/mile)
  static String formatPace(double distance, int durationSeconds,
      {required String unit}) {
    if (distance == 0 || durationSeconds == 0) {
      return '0:00';
    }

    double paceMinutes;
    String paceUnit;

    if (unit == AppConstants.imperialUnit) {
      // min/mile
      final double miles = distance * AppConstants.metersToMiles;
      paceMinutes = (durationSeconds / 60) / miles;
      paceUnit = 'min/mi';
    } else {
      // min/km
      final double km = distance * AppConstants.metersToKm;
      paceMinutes = (durationSeconds / 60) / km;
      paceUnit = 'min/km';
    }

    final int minutes = paceMinutes.floor();
    final int seconds = ((paceMinutes - minutes) * 60).round();

    return '$minutes:${seconds.toString().padLeft(2, '0')} $paceUnit';
  }

  /// Calculate speed (km/h or mph)
  static String formatSpeed(double distance, int durationSeconds,
      {required String unit}) {
    if (distance == 0 || durationSeconds == 0) {
      return '0.0';
    }

    final double hours = durationSeconds / 3600;

    if (unit == AppConstants.imperialUnit) {
      final double miles = distance * AppConstants.metersToMiles;
      final double mph = miles / hours;
      return '${mph.toStringAsFixed(1)} mph';
    } else {
      final double km = distance * AppConstants.metersToKm;
      final double kmh = km / hours;
      return '${kmh.toStringAsFixed(1)} km/h';
    }
  }

  /// Estimate calories burned
  /// Using METs (Metabolic Equivalent of Task)
  /// Running METs ≈ 9.8 for moderate pace
  static double estimateCalories({
    required double distanceMeters,
    required int durationSeconds,
    double weightKg = 70, // Default average weight
  }) {
    // Calculate average speed in km/h
    final double hours = durationSeconds / 3600;
    final double km = distanceMeters * AppConstants.metersToKm;
    final double speedKmh = km / hours;

    // Estimate METs based on speed
    double mets;
    if (speedKmh < 6) {
      mets = 6.0; // Walking/slow jogging
    } else if (speedKmh < 8) {
      mets = 8.3; // Light running
    } else if (speedKmh < 10) {
      mets = 9.8; // Moderate running
    } else if (speedKmh < 12) {
      mets = 11.0; // Fast running
    } else {
      mets = 12.3; // Very fast running
    }

    // Calories = METs × weight (kg) × time (hours)
    final double calories = mets * weightKg * hours;

    return calories;
  }
}
