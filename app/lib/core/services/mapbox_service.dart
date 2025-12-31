import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/app/env.dart';

/// Map style options for the app
enum MapStyle {
  streets('mapbox://styles/mapbox/streets-v12', 'Streets'),
  outdoors('mapbox://styles/mapbox/outdoors-v12', 'Outdoors'),
  light('mapbox://styles/mapbox/light-v11', 'Light'),
  dark('mapbox://styles/mapbox/dark-v11', 'Dark'),
  satellite('mapbox://styles/mapbox/satellite-v9', 'Satellite'),
  satelliteStreets('mapbox://styles/mapbox/satellite-streets-v12', 'Satellite Streets');

  const MapStyle(this.styleUri, this.displayName);

  final String styleUri;
  final String displayName;
}

/// Service class for managing Mapbox functionality
class MapboxService {
  /// Singleton instance
  static final MapboxService _instance = MapboxService._internal();
  factory MapboxService() => _instance;
  MapboxService._internal();

  /// Get Mapbox access token from environment
  String get accessToken => Env.mapboxToken;

  /// Default map style
  MapStyle defaultStyle = MapStyle.streets;

  /// Get camera options for a specific location
  CameraOptions getCameraOptions({
    required double latitude,
    required double longitude,
    double zoom = 14.0,
    double? bearing,
    double? pitch,
  }) {
    return CameraOptions(
      center: Point(coordinates: Position(longitude, latitude)),
      zoom: zoom,
      bearing: bearing,
      pitch: pitch,
    );
  }

  /// Get bounds camera options to fit multiple coordinates
  CameraOptions getBoundsCameraOptions({
    required List<Position> coordinates,
    MbxEdgeInsets? padding,
  }) {
    if (coordinates.isEmpty) {
      throw ArgumentError('Coordinates list cannot be empty');
    }

    if (coordinates.length == 1) {
      return getCameraOptions(
        latitude: coordinates.first.lat.toDouble(),
        longitude: coordinates.first.lng.toDouble(),
      );
    }

    // Calculate bounds
    double minLat = coordinates.first.lat.toDouble();
    double maxLat = coordinates.first.lat.toDouble();
    double minLng = coordinates.first.lng.toDouble();
    double maxLng = coordinates.first.lng.toDouble();

    for (final coord in coordinates) {
      final lat = coord.lat.toDouble();
      final lng = coord.lng.toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Center point
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    return getCameraOptions(
      latitude: centerLat,
      longitude: centerLng,
      zoom: 12.0,
    );
  }

  /// Create a circle annotation for location marker
  CircleAnnotationOptions createLocationMarker({
    required double latitude,
    required double longitude,
    int color = 0xFF0066FF,
    double radius = 10.0,
  }) {
    return CircleAnnotationOptions(
      geometry: Point(coordinates: Position(longitude, latitude)),
      circleColor: color,
      circleRadius: radius,
      circleStrokeWidth: 2.0,
      circleStrokeColor: 0xFFFFFFFF,
    );
  }

  /// Create a polyline from list of coordinates
  PolylineAnnotationOptions createPolyline({
    required List<Position> coordinates,
    int color = 0xFF0066FF,
    double width = 5.0,
  }) {
    final points = coordinates.map((pos) =>
      Position(pos.lng, pos.lat)
    ).toList();

    return PolylineAnnotationOptions(
      geometry: LineString(coordinates: points),
      lineColor: color,
      lineWidth: width,
      lineJoin: LineJoin.ROUND,
    );
  }

  /// Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}
