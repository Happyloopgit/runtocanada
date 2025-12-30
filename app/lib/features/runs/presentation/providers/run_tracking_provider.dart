import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/services/location_service.dart';
import 'package:run_to_canada/features/runs/data/datasources/run_local_datasource.dart';
import 'package:run_to_canada/features/runs/data/services/run_tracking_service.dart';

/// Provider for the run tracking service singleton
final runTrackingServiceProvider = Provider<RunTrackingService>((ref) {
  final locationService = LocationService();
  final runLocalDataSource = RunLocalDataSource();

  return RunTrackingService(
    locationService: locationService,
    runLocalDataSource: runLocalDataSource,
  );
});

/// Provider for the current run status
final runStatusProvider = StreamProvider<RunStatus>((ref) {
  final trackingService = ref.watch(runTrackingServiceProvider);
  return trackingService.statusStream;
});

/// Provider for the current run stats
final runStatsProvider = StreamProvider<RunStats>((ref) {
  final trackingService = ref.watch(runTrackingServiceProvider);
  return trackingService.statsStream;
});
