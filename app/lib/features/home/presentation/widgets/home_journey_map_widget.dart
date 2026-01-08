import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../goals/domain/models/goal_model.dart';
import '../../../goals/domain/models/milestone_model.dart';

/// Lightweight map widget for home screen
/// Shows the journey route with current position and next milestone
class HomeJourneyMapWidget extends StatefulWidget {
  final GoalModel goal;
  final MilestoneModel? nextMilestone;

  const HomeJourneyMapWidget({
    super.key,
    required this.goal,
    this.nextMilestone,
  });

  @override
  State<HomeJourneyMapWidget> createState() => _HomeJourneyMapWidgetState();
}

class _HomeJourneyMapWidgetState extends State<HomeJourneyMapWidget> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  PointAnnotationManager? _markerManager;
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    // If no route polyline, show placeholder
    if (widget.goal.routePolyline.isEmpty) {
      return Container(
        color: AppColors.surfaceDark,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                'Route not available',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Convert flat list [lat, lng, lat, lng...] to Position list
    final positions = <Position>[];
    for (int i = 0; i < widget.goal.routePolyline.length - 1; i += 2) {
      positions.add(Position(
        widget.goal.routePolyline[i + 1], // longitude
        widget.goal.routePolyline[i],     // latitude
      ));
    }

    // Calculate camera bounds
    final bounds = _calculateBounds(positions);
    final center = Point(
      coordinates: Position(
        (bounds['minLng']! + bounds['maxLng']!) / 2,
        (bounds['minLat']! + bounds['maxLat']!) / 2,
      ),
    );

    return MapWidget(
      styleUri: MapboxStyles.OUTDOORS,
      cameraOptions: CameraOptions(
        center: center,
        zoom: _calculateZoom(bounds),
      ),
      onMapCreated: _onMapCreated,
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    try {
      // Create managers
      _polylineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
      _markerManager = await mapboxMap.annotations.createPointAnnotationManager();

      // Draw route
      await _drawRoute();

      // Draw markers
      await _drawMarkers();

      // Position camera
      await _positionCamera();

      setState(() {
        _isMapReady = true;
      });
    } catch (e) {
      print('❌ Error setting up map: $e');
    }
  }

  Future<void> _drawRoute() async {
    if (_polylineManager == null || widget.goal.routePolyline.isEmpty) return;

    try {
      // Convert flat list to LineString coordinates
      final coordinates = <Position>[];
      for (int i = 0; i < widget.goal.routePolyline.length - 1; i += 2) {
        coordinates.add(Position(
          widget.goal.routePolyline[i + 1], // longitude
          widget.goal.routePolyline[i],     // latitude
        ));
      }

      // Create polyline
      final lineString = LineString(coordinates: coordinates);
      final polylineOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: Colors.blue.value,
        lineWidth: 4.0,
        lineOpacity: 0.9,
      );

      await _polylineManager!.create(polylineOptions);
      print('✅ Route polyline drawn with ${coordinates.length} points');
    } catch (e) {
      print('❌ Error drawing route: $e');
    }
  }

  Future<void> _drawMarkers() async {
    if (_markerManager == null) return;

    try {
      final markers = <PointAnnotationOptions>[];

      // 1. Start marker (green)
      markers.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(
          widget.goal.startLocation.longitude,
          widget.goal.startLocation.latitude,
        )),
        iconSize: 1.0,
        iconColor: Colors.green.value,
        iconImage: 'marker',
      ));

      // 2. Current position marker (blue) - based on progress
      final currentPosition = _calculateCurrentPosition();
      if (currentPosition != null) {
        markers.add(PointAnnotationOptions(
          geometry: Point(coordinates: currentPosition),
          iconSize: 1.2,
          iconColor: Colors.blue.value,
          iconImage: 'marker',
        ));
      }

      // 3. Next milestone marker (orange) if exists
      if (widget.nextMilestone != null) {
        markers.add(PointAnnotationOptions(
          geometry: Point(coordinates: Position(
            widget.nextMilestone!.location.longitude,
            widget.nextMilestone!.location.latitude,
          )),
          iconSize: 1.0,
          iconColor: Colors.orange.value,
          iconImage: 'marker',
        ));
      }

      // 4. Destination marker (red)
      markers.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(
          widget.goal.destinationLocation.longitude,
          widget.goal.destinationLocation.latitude,
        )),
        iconSize: 1.0,
        iconColor: Colors.red.value,
        iconImage: 'marker',
      ));

      await _markerManager!.createMulti(markers);
      print('✅ Drew ${markers.length} markers');
    } catch (e) {
      print('❌ Error drawing markers: $e');
    }
  }

  Position? _calculateCurrentPosition() {
    if (widget.goal.routePolyline.isEmpty) return null;

    // Calculate progress percentage
    final progressPercent = widget.goal.currentProgress / widget.goal.totalDistance;
    if (progressPercent <= 0) return null;

    // Convert flat list to positions
    final positions = <Position>[];
    for (int i = 0; i < widget.goal.routePolyline.length - 1; i += 2) {
      positions.add(Position(
        widget.goal.routePolyline[i + 1], // longitude
        widget.goal.routePolyline[i],     // latitude
      ));
    }

    // Find point along route based on progress
    final targetIndex = (positions.length * progressPercent).floor();
    final clampedIndex = targetIndex.clamp(0, positions.length - 1);

    return positions[clampedIndex];
  }

  Future<void> _positionCamera() async {
    if (_mapboxMap == null || widget.goal.routePolyline.isEmpty) return;

    try {
      // Convert flat list to positions
      final positions = <Position>[];
      for (int i = 0; i < widget.goal.routePolyline.length - 1; i += 2) {
        positions.add(Position(
          widget.goal.routePolyline[i + 1], // longitude
          widget.goal.routePolyline[i],     // latitude
        ));
      }

      // Calculate bounds
      final bounds = _calculateBounds(positions);

      // Use Mapbox's built-in cameraForCoordinateBounds
      final coordinateBounds = CoordinateBounds(
        southwest: Point(coordinates: Position(
          bounds['minLng']!,
          bounds['minLat']!,
        )),
        northeast: Point(coordinates: Position(
          bounds['maxLng']!,
          bounds['maxLat']!,
        )),
        infiniteBounds: false,
      );

      final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
        coordinateBounds,
        MbxEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
        null, // bearing
        null, // pitch
        null, // maxZoom
        null, // offset
      );

      if (cameraOptions != null) {
        await _mapboxMap!.setCamera(cameraOptions);
        print('✅ Camera positioned to show full route');
      }
    } catch (e) {
      print('❌ Error positioning camera: $e');
    }
  }

  Map<String, double> _calculateBounds(List<Position> positions) {
    if (positions.isEmpty) {
      return {
        'minLat': 0.0,
        'maxLat': 0.0,
        'minLng': 0.0,
        'maxLng': 0.0,
      };
    }

    double minLat = positions.first.lat.toDouble();
    double maxLat = positions.first.lat.toDouble();
    double minLng = positions.first.lng.toDouble();
    double maxLng = positions.first.lng.toDouble();

    for (final pos in positions) {
      final lat = pos.lat.toDouble();
      final lng = pos.lng.toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  double _calculateZoom(Map<String, double> bounds) {
    final latSpan = bounds['maxLat']! - bounds['minLat']!;
    final lngSpan = bounds['maxLng']! - bounds['minLng']!;
    final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;

    // Simple zoom calculation
    if (maxSpan > 50) return 4.0;
    if (maxSpan > 20) return 5.0;
    if (maxSpan > 10) return 6.0;
    if (maxSpan > 5) return 7.0;
    if (maxSpan > 2) return 8.0;
    if (maxSpan > 1) return 9.0;
    if (maxSpan > 0.5) return 10.0;
    return 11.0;
  }

  @override
  void dispose() {
    // Cleanup handled by Mapbox
    super.dispose();
  }
}
