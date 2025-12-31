import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/models/run_model.dart';
import '../../domain/models/route_point.dart';
import '../datasources/run_local_datasource.dart';

enum RunStatus {
  idle,
  running,
  paused,
  stopped,
}

class RunTrackingService {
  final LocationService _locationService;
  final RunLocalDataSource _runLocalDataSource;

  RunTrackingService({
    required LocationService locationService,
    required RunLocalDataSource runLocalDataSource,
  })  : _locationService = locationService,
        _runLocalDataSource = runLocalDataSource;

  // Run state
  RunStatus _status = RunStatus.idle;
  String? _currentRunId;
  String? _userId;
  DateTime? _startTime;
  DateTime? _pauseTime;
  int _totalPausedDuration = 0; // in seconds

  // Route tracking
  final List<RoutePoint> _routePoints = [];
  Position? _lastPosition;

  // Statistics
  double _totalDistance = 0.0; // in meters
  double _maxSpeed = 0.0; // m/s
  double _totalElevationGain = 0.0; // in meters

  // Stream controller for real-time updates
  final _statusController = StreamController<RunStatus>.broadcast();
  final _statsController = StreamController<RunStats>.broadcast();

  // Getters
  RunStatus get status => _status;
  String? get currentRunId => _currentRunId;
  List<RoutePoint> get routePoints => List.unmodifiable(_routePoints);
  Stream<RunStatus> get statusStream => _statusController.stream;
  Stream<RunStats> get statsStream => _statsController.stream;

  /// Start a new run
  Future<void> startRun(String userId) async {
    if (_status != RunStatus.idle) {
      throw Exception('Cannot start run: already tracking');
    }

    // Check and request permission
    final hasPermission = await _locationService.hasPermission();
    if (!hasPermission) {
      await _locationService.requestPermission();
    }

    // Initialize run
    _currentRunId = const Uuid().v4();
    _userId = userId;
    _startTime = DateTime.now();
    _status = RunStatus.running;
    _routePoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _totalElevationGain = 0.0;
    _totalPausedDuration = 0;
    _lastPosition = null;

    // Start listening to GPS updates
    await _locationService.startListening(
      onPositionUpdate: _onPositionUpdate,
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // Update every 5 meters
    );

    _statusController.add(_status);
    _emitStats();
  }

  /// Pause the current run
  void pauseRun() {
    if (_status != RunStatus.running) {
      throw Exception('Cannot pause: run is not running');
    }

    _status = RunStatus.paused;
    _pauseTime = DateTime.now();
    _statusController.add(_status);
  }

  /// Resume the paused run
  void resumeRun() {
    if (_status != RunStatus.paused) {
      throw Exception('Cannot resume: run is not paused');
    }

    if (_pauseTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseTime!).inSeconds;
      _totalPausedDuration += pauseDuration;
      _pauseTime = null;
    }

    _status = RunStatus.running;
    _statusController.add(_status);
  }

  /// Stop the current run and save it
  Future<RunModel?> stopRun({String? notes}) async {
    if (_status != RunStatus.running && _status != RunStatus.paused) {
      throw Exception('Cannot stop: no active run');
    }

    // Stop listening to GPS
    await _locationService.stopListening();

    final endTime = DateTime.now();
    final startTime = _startTime!;

    // Calculate total duration (excluding paused time)
    int totalDuration = endTime.difference(startTime).inSeconds - _totalPausedDuration;

    // Calculate average pace (min/km)
    double averagePace = 0.0;
    if (_totalDistance > 0) {
      final distanceInKm = _totalDistance / 1000;
      final durationInMinutes = totalDuration / 60;
      averagePace = durationInMinutes / distanceInKm;
    }

    // Estimate calories (rough estimate: 60 calories per km)
    final calories = (_totalDistance / 1000) * 60;

    // Create run model
    final run = RunModel(
      id: _currentRunId!,
      userId: _userId!,
      startTime: startTime,
      endTime: endTime,
      totalDistance: _totalDistance,
      duration: totalDuration,
      averagePace: averagePace,
      maxSpeed: _maxSpeed,
      calories: calories,
      elevationGain: _totalElevationGain,
      routePoints: List.from(_routePoints),
      notes: notes,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Hive
    await _runLocalDataSource.saveRun(run);

    // Reset state
    _status = RunStatus.stopped;
    _currentRunId = null;
    _userId = null;
    _startTime = null;
    _pauseTime = null;
    _totalPausedDuration = 0;
    _routePoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _totalElevationGain = 0.0;
    _lastPosition = null;

    _statusController.add(_status);

    return run;
  }

  /// Cancel the current run without saving
  Future<void> cancelRun() async {
    await _locationService.stopListening();

    _status = RunStatus.idle;
    _currentRunId = null;
    _userId = null;
    _startTime = null;
    _pauseTime = null;
    _totalPausedDuration = 0;
    _routePoints.clear();
    _totalDistance = 0.0;
    _maxSpeed = 0.0;
    _totalElevationGain = 0.0;
    _lastPosition = null;

    _statusController.add(_status);
  }

  /// Handle position updates from GPS
  void _onPositionUpdate(Position position) {
    // Only process if running (not paused)
    if (_status != RunStatus.running) return;

    // Create route point
    final routePoint = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      timestamp: DateTime.now(),
      speed: position.speed,
      accuracy: position.accuracy,
    );

    _routePoints.add(routePoint);

    // Calculate distance from last position
    if (_lastPosition != null) {
      final distance = _locationService.calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      _totalDistance += distance;

      // Calculate elevation gain
      if (position.altitude > _lastPosition!.altitude) {
        _totalElevationGain += (position.altitude - _lastPosition!.altitude);
      }
    }

    // Update max speed
    if (position.speed > _maxSpeed) {
      _maxSpeed = position.speed;
    }

    _lastPosition = position;

    // Emit updated stats
    _emitStats();

    // Save to Hive periodically (every 10 points)
    if (_routePoints.length % 10 == 0) {
      _saveProgress();
    }
  }

  /// Save current progress to Hive
  Future<void> _saveProgress() async {
    // TODO: Implement auto-save to Hive for crash recovery
    // This will be useful if app crashes during a run
  }

  /// Emit current statistics
  void _emitStats() {
    if (_startTime == null) return;

    final now = DateTime.now();
    int duration = now.difference(_startTime!).inSeconds - _totalPausedDuration;

    // If paused, use pause time
    if (_status == RunStatus.paused && _pauseTime != null) {
      duration = _pauseTime!.difference(_startTime!).inSeconds - _totalPausedDuration;
    }

    // Calculate current pace (min/km)
    double currentPace = 0.0;
    if (_totalDistance > 0 && duration > 0) {
      final distanceInKm = _totalDistance / 1000;
      final durationInMinutes = duration / 60;
      currentPace = durationInMinutes / distanceInKm;
    }

    final stats = RunStats(
      distance: _totalDistance,
      duration: duration,
      pace: currentPace,
      speed: _lastPosition?.speed ?? 0.0,
      maxSpeed: _maxSpeed,
      elevationGain: _totalElevationGain,
      routePointsCount: _routePoints.length,
    );

    _statsController.add(stats);
  }

  /// Get current statistics
  RunStats getCurrentStats() {
    if (_startTime == null) {
      return RunStats(
        distance: 0,
        duration: 0,
        pace: 0,
        speed: 0,
        maxSpeed: 0,
        elevationGain: 0,
        routePointsCount: 0,
      );
    }

    final now = DateTime.now();
    int duration = now.difference(_startTime!).inSeconds - _totalPausedDuration;

    if (_status == RunStatus.paused && _pauseTime != null) {
      duration = _pauseTime!.difference(_startTime!).inSeconds - _totalPausedDuration;
    }

    double currentPace = 0.0;
    if (_totalDistance > 0 && duration > 0) {
      final distanceInKm = _totalDistance / 1000;
      final durationInMinutes = duration / 60;
      currentPace = durationInMinutes / distanceInKm;
    }

    return RunStats(
      distance: _totalDistance,
      duration: duration,
      pace: currentPace,
      speed: _lastPosition?.speed ?? 0.0,
      maxSpeed: _maxSpeed,
      elevationGain: _totalElevationGain,
      routePointsCount: _routePoints.length,
    );
  }

  /// Dispose and cleanup
  void dispose() {
    _locationService.dispose();
    _statusController.close();
    _statsController.close();
  }
}

/// Real-time run statistics
class RunStats {
  final double distance; // meters
  final int duration; // seconds
  final double pace; // min/km
  final double speed; // m/s
  final double maxSpeed; // m/s
  final double elevationGain; // meters
  final int routePointsCount;

  RunStats({
    required this.distance,
    required this.duration,
    required this.pace,
    required this.speed,
    required this.maxSpeed,
    required this.elevationGain,
    required this.routePointsCount,
  });

  double get distanceInKm => distance / 1000;
  double get distanceInMiles => distance / 1609.34;
  double get speedInKmh => speed * 3.6;
  double get maxSpeedInKmh => maxSpeed * 3.6;

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedPace {
    if (pace.isInfinite || pace.isNaN || pace <= 0) {
      return '--:--';
    }
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
