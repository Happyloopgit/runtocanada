import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import '../../../app/env.dart';

/// Model representing a route from Mapbox Directions API
class DirectionsRoute {
  final double distance; // meters
  final double duration; // seconds
  final List<DirectionsCoordinate> coordinates;
  final String? geometry; // GeoJSON geometry string

  DirectionsRoute({
    required this.distance,
    required this.duration,
    required this.coordinates,
    this.geometry,
  });

  /// Get distance in kilometers
  double get distanceInKm => distance / 1000;

  /// Get distance in miles
  double get distanceInMiles => distance / 1609.34;

  /// Get duration in hours
  double get durationInHours => duration / 3600;

  factory DirectionsRoute.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    List<DirectionsCoordinate> coordinates = [];

    // Parse geometry (polyline encoded or GeoJSON)
    if (geometry is Map && geometry['coordinates'] != null) {
      final coords = geometry['coordinates'] as List;
      coordinates = coords.map((coord) {
        return DirectionsCoordinate(
          longitude: (coord[0] as num).toDouble(),
          latitude: (coord[1] as num).toDouble(),
        );
      }).toList();
    }

    return DirectionsRoute(
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      coordinates: coordinates,
      geometry: geometry is String ? geometry : jsonEncode(geometry),
    );
  }
}

/// Model representing a coordinate point
class DirectionsCoordinate {
  final double longitude;
  final double latitude;

  DirectionsCoordinate({
    required this.longitude,
    required this.latitude,
  });

  @override
  String toString() => '[$longitude, $latitude]';
}

/// Service for Mapbox Directions API
/// Calculates routes between locations
class DirectionsService {
  static const String _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
  final String _accessToken;
  final Dio _dio;

  DirectionsService({String? accessToken})
      : _accessToken = accessToken ?? Env.mapboxToken,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  /// Get driving route between two points
  ///
  /// [startLng] - Start longitude
  /// [startLat] - Start latitude
  /// [endLng] - End longitude
  /// [endLat] - End latitude
  /// [alternatives] - Whether to return alternative routes
  /// [steps] - Whether to include turn-by-turn steps
  ///
  /// Returns a [DirectionsRoute] or null if no route found
  Future<DirectionsRoute?> getRoute({
    required double startLng,
    required double startLat,
    required double endLng,
    required double endLat,
    bool alternatives = false,
    bool steps = false,
  }) async {
    try {
      final coordinates = '$startLng,$startLat;$endLng,$endLat';
      final queryParameters = <String, dynamic>{
        'access_token': _accessToken,
        'alternatives': alternatives.toString(),
        'geometries': 'geojson',
        'overview': 'full',
        'steps': steps.toString(),
      };

      final response = await _dio.get(
        '$_baseUrl/driving/$coordinates',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>;

        if (routes.isNotEmpty) {
          return DirectionsRoute.fromJson(routes.first as Map<String, dynamic>);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      } else {
        throw Exception('Directions API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      }
      throw Exception('Failed to get route: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }

  /// Get route between multiple waypoints
  ///
  /// [waypoints] - List of [DirectionsCoordinate] waypoints
  /// [alternatives] - Whether to return alternative routes
  ///
  /// Returns a [DirectionsRoute] or null if no route found
  Future<DirectionsRoute?> getRouteWithWaypoints({
    required List<DirectionsCoordinate> waypoints,
    bool alternatives = false,
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('At least 2 waypoints required');
    }

    try {
      final coordinates = waypoints
          .map((wp) => '${wp.longitude},${wp.latitude}')
          .join(';');

      final queryParameters = <String, dynamic>{
        'access_token': _accessToken,
        'alternatives': alternatives.toString(),
        'geometries': 'geojson',
        'overview': 'full',
      };

      final response = await _dio.get(
        '$_baseUrl/driving/$coordinates',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>;

        if (routes.isNotEmpty) {
          return DirectionsRoute.fromJson(routes.first as Map<String, dynamic>);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      } else {
        throw Exception('Directions API error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Mapbox access token');
      }
      throw Exception('Failed to get route: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }

  /// Calculate distance along route to a specific point index
  ///
  /// [route] - The route to calculate along
  /// [pointIndex] - Index of the point to calculate distance to
  ///
  /// Returns distance in meters
  double calculateDistanceToPoint(DirectionsRoute route, int pointIndex) {
    if (pointIndex < 0 || pointIndex >= route.coordinates.length) {
      throw ArgumentError('Invalid point index');
    }

    double totalDistance = 0.0;

    for (int i = 0; i < pointIndex; i++) {
      final current = route.coordinates[i];
      final next = route.coordinates[i + 1];
      totalDistance += _calculateDistance(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
    }

    return totalDistance;
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
