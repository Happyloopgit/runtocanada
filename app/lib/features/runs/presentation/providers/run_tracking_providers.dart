import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../data/datasources/run_local_datasource.dart';
import '../../data/services/run_tracking_service.dart';

/// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Run Local DataSource Provider
final runLocalDataSourceProvider = Provider<RunLocalDataSource>((ref) {
  return RunLocalDataSource();
});

/// Run Tracking Service Provider
final runTrackingServiceProvider = Provider<RunTrackingService>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final runLocalDataSource = ref.watch(runLocalDataSourceProvider);

  return RunTrackingService(
    locationService: locationService,
    runLocalDataSource: runLocalDataSource,
  );
});

/// Run Status Stream Provider
final runStatusStreamProvider = StreamProvider<RunStatus>((ref) {
  final service = ref.watch(runTrackingServiceProvider);
  return service.statusStream;
});

/// Run Stats Stream Provider
final runStatsStreamProvider = StreamProvider<RunStats>((ref) {
  final service = ref.watch(runTrackingServiceProvider);
  return service.statsStream;
});

/// Current Run Status Provider
final currentRunStatusProvider = Provider<RunStatus>((ref) {
  final asyncStatus = ref.watch(runStatusStreamProvider);
  return asyncStatus.when(
    data: (status) => status,
    loading: () => RunStatus.idle,
    error: (error, stack) => RunStatus.idle,
  );
});

/// Current Run Stats Provider
final currentRunStatsProvider = Provider<RunStats?>((ref) {
  final asyncStats = ref.watch(runStatsStreamProvider);
  return asyncStats.when(
    data: (stats) => stats,
    loading: () => null,
    error: (error, stack) => null,
  );
});
