import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Request background location permission (Android 10+)
  Future<bool> requestBackgroundPermission() async {
    if (await Permission.locationAlways.isGranted) {
      return true;
    }

    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        final permission = await requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return position;
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  /// Start listening to position updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5, // meters
    int timeLimit = 0, // milliseconds, 0 = no limit
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: timeLimit > 0 ? Duration(milliseconds: timeLimit) : null,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Start listening to position updates with callback
  Future<void> startListening({
    required Function(Position) onPositionUpdate,
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5,
  }) async {
    // Check permission first
    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      final permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }

    // Cancel existing subscription if any
    await stopListening();

    // Start listening
    _positionStreamSubscription = getPositionStream(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    ).listen(
      onPositionUpdate,
      onError: (error) {
        // Log error in production
      },
    );
  }

  /// Stop listening to position updates
  Future<void> stopListening() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Dispose and cleanup
  void dispose() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
