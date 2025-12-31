import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';

/// Reusable map widget with Mapbox integration
class CustomMapWidget extends StatefulWidget {
  /// Initial camera position (latitude, longitude)
  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;

  /// Map style
  final MapStyle mapStyle;

  /// Callback when map is created
  final void Function(MapboxMap)? onMapCreated;

  /// Show user location
  final bool showUserLocation;

  /// Enable map interactions (zoom, pan, rotate)
  final bool enableInteractions;

  const CustomMapWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 14.0,
    this.mapStyle = MapStyle.streets,
    this.onMapCreated,
    this.showUserLocation = true,
    this.enableInteractions = true,
  });

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  final _mapboxService = MapboxService();

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('mapbox_map'),
      cameraOptions: _getCameraOptions(),
      styleUri: widget.mapStyle.styleUri,
      onMapCreated: _onMapCreated,
    );
  }

  CameraOptions _getCameraOptions() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      return _mapboxService.getCameraOptions(
        latitude: widget.initialLatitude!,
        longitude: widget.initialLongitude!,
        zoom: widget.initialZoom,
      );
    }

    // Default to Toronto, Canada if no coordinates provided
    return _mapboxService.getCameraOptions(
      latitude: 43.6532,
      longitude: -79.3832,
      zoom: widget.initialZoom,
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    // Configure map gestures
    if (!widget.enableInteractions) {
      await mapboxMap.gestures.updateSettings(
        GesturesSettings(
          rotateEnabled: false,
          pitchEnabled: false,
          scrollEnabled: false,
          simultaneousRotateAndPinchToZoomEnabled: false,
          pinchToZoomEnabled: false,
        ),
      );
    }

    // Enable location puck if showUserLocation is true
    if (widget.showUserLocation) {
      await _enableLocationPuck(mapboxMap);
    }

    // Call the onMapCreated callback
    widget.onMapCreated?.call(mapboxMap);
  }

  Future<void> _enableLocationPuck(MapboxMap mapboxMap) async {
    try {
      await mapboxMap.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );
    } catch (e) {
      // Location puck setup failed, but don't crash the app
      debugPrint('Failed to enable location puck: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
