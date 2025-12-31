import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/features/runs/domain/models/route_point.dart';

/// A widget for displaying live route tracking during an active run
class LiveRouteMapWidget extends StatefulWidget {
  final List<RoutePoint> routePoints;
  final double height;
  final MapStyle? mapStyle;
  final bool followCurrentPosition;

  const LiveRouteMapWidget({
    super.key,
    required this.routePoints,
    this.height = 250.0,
    this.mapStyle,
    this.followCurrentPosition = true,
  });

  @override
  State<LiveRouteMapWidget> createState() => _LiveRouteMapWidgetState();
}

class _LiveRouteMapWidgetState extends State<LiveRouteMapWidget> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  PolylineAnnotation? _routePolyline;
  CircleAnnotation? _startMarker;
  CircleAnnotation? _currentPositionMarker;
  final MapboxService _mapboxService = MapboxService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(LiveRouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update route when new points are added
    if (widget.routePoints.length != oldWidget.routePoints.length) {
      _updateRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routePoints.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gps_not_fixed,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Waiting for GPS signal...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get camera options - follow current position if enabled
    final CameraOptions cameraOptions;
    if (widget.followCurrentPosition && widget.routePoints.isNotEmpty) {
      final lastPoint = widget.routePoints.last;
      cameraOptions = _mapboxService.getCameraOptions(
        latitude: lastPoint.latitude,
        longitude: lastPoint.longitude,
        zoom: 16.0,
      );
    } else if (widget.routePoints.length == 1) {
      final point = widget.routePoints.first;
      cameraOptions = _mapboxService.getCameraOptions(
        latitude: point.latitude,
        longitude: point.longitude,
        zoom: 16.0,
      );
    } else {
      final positions = widget.routePoints.map((point) =>
        Position(point.longitude, point.latitude)
      ).toList();
      cameraOptions = _mapboxService.getRouteCameraOptions(
        coordinates: positions,
        paddingPercent: 0.2,
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapWidget(
          styleUri: (widget.mapStyle ?? MapStyle.outdoors).styleUri,
          cameraOptions: cameraOptions,
          onMapCreated: _onMapCreated,
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create annotation managers
    _polylineManager = await _mapboxMap!.annotations.createPolylineAnnotationManager();
    _circleManager = await _mapboxMap!.annotations.createCircleAnnotationManager();

    // Draw initial route
    _updateRoute();
  }

  void _updateRoute() async {
    if (_polylineManager == null || _circleManager == null) return;
    if (widget.routePoints.isEmpty) return;

    // Convert RoutePoints to Positions
    final positions = widget.routePoints.map((point) =>
      Position(point.longitude, point.latitude)
    ).toList();

    // Update or create polyline
    if (_routePolyline != null) {
      // Delete existing polyline and create new one
      await _polylineManager!.delete(_routePolyline!);
    }
    // Create new polyline
    final polylineOptions = _mapboxService.createPolyline(
      coordinates: positions,
      color: 0xFF0066FF, // Blue for live tracking
      width: 6.0,
    );
    _routePolyline = await _polylineManager!.create(polylineOptions);

    // Add start marker (only once)
    if (_startMarker == null && widget.routePoints.isNotEmpty) {
      final startPoint = widget.routePoints.first;
      final startMarkerOptions = _mapboxService.createStartMarker(
        latitude: startPoint.latitude,
        longitude: startPoint.longitude,
      );
      _startMarker = await _circleManager!.create(startMarkerOptions);
    }

    // Update current position marker
    if (widget.routePoints.isNotEmpty) {
      final currentPoint = widget.routePoints.last;

      if (_currentPositionMarker != null) {
        // Delete existing marker
        await _circleManager!.delete(_currentPositionMarker!);
      }

      // Create new marker
      final markerOptions = CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            currentPoint.longitude,
            currentPoint.latitude,
          ),
        ),
        circleColor: 0xFF0066FF, // Blue
        circleRadius: 10.0,
        circleStrokeWidth: 3.0,
        circleStrokeColor: 0xFFFFFFFF, // White border
      );
      _currentPositionMarker = await _circleManager!.create(markerOptions);

      // Update camera to follow if enabled
      if (widget.followCurrentPosition && _mapboxMap != null) {
        final newCamera = _mapboxService.getCameraOptions(
          latitude: currentPoint.latitude,
          longitude: currentPoint.longitude,
          zoom: 16.0,
        );
        _mapboxMap!.setCamera(newCamera);
      }
    }
  }

  @override
  void dispose() {
    _polylineManager?.deleteAll();
    _circleManager?.deleteAll();
    super.dispose();
  }
}
