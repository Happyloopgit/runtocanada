import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/features/runs/domain/models/route_point.dart';

/// A reusable widget for displaying run routes on a Mapbox map
class RouteMapWidget extends StatefulWidget {
  final List<RoutePoint> routePoints;
  final double height;
  final MapStyle? mapStyle;
  final bool showStartMarker;
  final bool showEndMarker;
  final int routeColor;
  final double routeWidth;

  const RouteMapWidget({
    super.key,
    required this.routePoints,
    this.height = 250.0,
    this.mapStyle,
    this.showStartMarker = true,
    this.showEndMarker = true,
    this.routeColor = 0xFFD32F2F, // Canadian red
    this.routeWidth = 5.0,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  final MapboxService _mapboxService = MapboxService();

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
                Icons.map_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'No route data available',
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

    // Convert RoutePoints to Positions
    final positions = widget.routePoints.map((point) =>
      Position(point.longitude, point.latitude)
    ).toList();

    // Get camera options to fit the route
    final cameraOptions = _mapboxService.getRouteCameraOptions(
      coordinates: positions,
      paddingPercent: 0.15,
    );

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

    // Draw the route and markers
    _drawRoute();
  }

  void _drawRoute() async {
    if (_polylineManager == null || _circleManager == null) return;
    if (widget.routePoints.isEmpty) return;

    // Convert RoutePoints to Positions
    final positions = widget.routePoints.map((point) =>
      Position(point.longitude, point.latitude)
    ).toList();

    // Draw polyline
    final polylineOptions = _mapboxService.createPolyline(
      coordinates: positions,
      color: widget.routeColor,
      width: widget.routeWidth,
    );
    await _polylineManager!.create(polylineOptions);

    // Add start marker (green)
    if (widget.showStartMarker && widget.routePoints.isNotEmpty) {
      final startPoint = widget.routePoints.first;
      final startMarker = _mapboxService.createStartMarker(
        latitude: startPoint.latitude,
        longitude: startPoint.longitude,
      );
      await _circleManager!.create(startMarker);
    }

    // Add end marker (red)
    if (widget.showEndMarker && widget.routePoints.length > 1) {
      final endPoint = widget.routePoints.last;
      final endMarker = _mapboxService.createEndMarker(
        latitude: endPoint.latitude,
        longitude: endPoint.longitude,
      );
      await _circleManager!.create(endMarker);
    }
  }

  @override
  void dispose() {
    _polylineManager?.deleteAll();
    _circleManager?.deleteAll();
    super.dispose();
  }
}
