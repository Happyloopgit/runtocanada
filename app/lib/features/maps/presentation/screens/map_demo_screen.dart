import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/core/services/location_service.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_map_widget.dart';
import 'package:run_to_canada/core/widgets/map_style_selector.dart';

/// Demo screen to test Mapbox integration
class MapDemoScreen extends StatefulWidget {
  const MapDemoScreen({super.key});

  @override
  State<MapDemoScreen> createState() => _MapDemoScreenState();
}

class _MapDemoScreenState extends State<MapDemoScreen> {
  final _locationService = LocationService();
  MapboxMap? _mapboxMap;
  MapStyle _currentMapStyle = MapStyle.streets;
  double? _currentLat;
  double? _currentLng;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      var permission = await _locationService.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        permission = await _locationService.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    // Move camera to current location if available
    if (_currentLat != null && _currentLng != null) {
      _moveCameraToLocation(_currentLat!, _currentLng!);
    }
  }

  Future<void> _moveCameraToLocation(double lat, double lng) async {
    if (_mapboxMap == null) return;

    final mapboxService = MapboxService();
    final cameraOptions = mapboxService.getCameraOptions(
      latitude: lat,
      longitude: lng,
      zoom: 15.0,
    );

    await _mapboxMap!.flyTo(
      cameraOptions,
      MapAnimationOptions(duration: 1500, startDelay: 0),
    );
  }

  void _showMapStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MapStyleSelector(
        currentStyle: _currentMapStyle,
        onStyleChanged: (style) {
          setState(() => _currentMapStyle = style);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapbox Integration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showMapStyleSelector,
            tooltip: 'Change Map Style',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : Stack(
              children: [
                CustomMapWidget(
                  initialLatitude: _currentLat,
                  initialLongitude: _currentLng,
                  mapStyle: _currentMapStyle,
                  onMapCreated: _onMapCreated,
                  showUserLocation: true,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildInfoCard(),
                ),
              ],
            ),
      floatingActionButton: _currentLat != null && _currentLng != null
          ? FloatingActionButton(
              onPressed: () => _moveCameraToLocation(_currentLat!, _currentLng!),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Map Demo',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Current Style: ${_currentMapStyle.displayName}',
            style: AppTextStyles.bodyMedium,
          ),
          if (_currentLat != null && _currentLng != null) ...[
            const SizedBox(height: 4),
            Text(
              'Location: ${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Tap the layers icon to change map style\nTap the location button to center on your location',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
