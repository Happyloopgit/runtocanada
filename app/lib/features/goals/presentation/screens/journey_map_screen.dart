import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/services/mapbox_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../domain/models/goal_model.dart';
import '../../domain/models/milestone_model.dart';

// Provider for active goal
final activeGoalProvider = FutureProvider<GoalModel?>((ref) async {
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) return null;

  final dataSource = GoalLocalDataSource();
  return dataSource.getActiveGoalSafe(userAsync.uid);
});

class JourneyMapScreen extends ConsumerStatefulWidget {
  const JourneyMapScreen({super.key});

  @override
  ConsumerState<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends ConsumerState<JourneyMapScreen> {
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final activeGoalAsync = ref.watch(activeGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Progress'),
        centerTitle: true,
      ),
      body: activeGoalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading goal: $error'),
            ],
          ),
        ),
        data: (goal) {
          if (goal == null) {
            return _buildNoActiveGoalState();
          }
          return _buildJourneyView(goal);
        },
      ),
    );
  }

  Widget _buildNoActiveGoalState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Goal',
              style: AppTextStyles.displayMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a goal to start your virtual journey!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to goal creation screen
                // (This will be handled by home screen button)
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyView(GoalModel goal) {
    return Column(
      children: [
        // Map view
        Expanded(
          flex: 2,
          child: _buildMap(goal),
        ),
        // Progress info
        Expanded(
          flex: 1,
          child: _buildProgressInfo(goal),
        ),
      ],
    );
  }

  Widget _buildMap(GoalModel goal) {
    return Stack(
      children: [
        MapWidget(
          styleUri: MapStyle.outdoors.styleUri,
          cameraOptions: _getInitialCameraOptions(goal),
          onMapCreated: (mapboxMap) => _onMapCreated(mapboxMap, goal),
        ),
        if (!_isMapReady)
          Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        // Legend overlay
        Positioned(
          top: 16,
          right: 16,
          child: _buildMapLegend(),
        ),
      ],
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            color: Colors.green,
            label: 'Start',
            icon: Icons.play_arrow,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: Colors.blue,
            label: 'Your Position',
            icon: Icons.person_pin_circle,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: AppColors.primary,
            label: 'Reached',
            icon: Icons.flag,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: Colors.grey,
            label: 'Not Reached',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: Colors.red,
            label: 'Destination',
            icon: Icons.sports_score,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  CameraOptions _getInitialCameraOptions(GoalModel goal) {
    // Convert flat polyline to list of Position objects
    final coordinates = <Position>[];
    for (int i = 0; i < goal.routePolyline.length; i += 2) {
      coordinates.add(Position(
        goal.routePolyline[i + 1], // lng
        goal.routePolyline[i],     // lat
      ));
    }

    return MapboxService().getRouteCameraOptions(coordinates: coordinates);
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap, GoalModel goal) async {

    try {
      // Create annotation managers
      _polylineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
      _circleManager = await mapboxMap.annotations.createCircleAnnotationManager();

      // Draw route polyline
      await _drawRoute(goal);

      // Add markers for milestones and current position
      await _addMilestoneMarkers(goal);
      await _addStartEndMarkers(goal);
      await _addCurrentPositionMarker(goal);

      setState(() {
        _isMapReady = true;
      });
    } catch (e) {
      // Map setup error
      setState(() {
        _isMapReady = true;
      });
    }
  }

  Future<void> _drawRoute(GoalModel goal) async {
    if (_polylineManager == null) return;

    // Convert flat polyline to list of Position for LineString
    final positions = <Position>[];
    for (int i = 0; i < goal.routePolyline.length; i += 2) {
      positions.add(Position(
        goal.routePolyline[i + 1], // lng
        goal.routePolyline[i],     // lat
      ));
    }

    // Create LineString from positions (LineString expects List<Position>)
    final lineString = LineString(coordinates: positions);

    await _polylineManager!.create(
      PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: AppColors.primary.toARGB32(),
        lineWidth: 4.0,
      ),
    );
  }

  Future<void> _addStartEndMarkers(GoalModel goal) async {
    if (_circleManager == null) return;

    // Start marker (green)
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            goal.startLocation.longitude,
            goal.startLocation.latitude,
          ),
        ),
        circleRadius: 12.0,
        circleColor: Colors.green.toARGB32(),
        circleStrokeWidth: 3.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );

    // End marker (red)
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            goal.destinationLocation.longitude,
            goal.destinationLocation.latitude,
          ),
        ),
        circleRadius: 12.0,
        circleColor: Colors.red.toARGB32(),
        circleStrokeWidth: 3.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );
  }

  Future<void> _addMilestoneMarkers(GoalModel goal) async {
    if (_circleManager == null) return;

    for (final milestone in goal.milestones) {
      final color = milestone.isReached ? AppColors.primary : Colors.grey;

      await _circleManager!.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              milestone.location.longitude,
              milestone.location.latitude,
            ),
          ),
          circleRadius: 8.0,
          circleColor: color.toARGB32(),
          circleStrokeWidth: 2.0,
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    }
  }

  Future<void> _addCurrentPositionMarker(GoalModel goal) async {
    if (_circleManager == null) return;

    final virtualLocation = goal.currentVirtualLocation;
    if (virtualLocation == null) return;

    // Current position marker (blue, pulsing effect)
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            virtualLocation.longitude,
            virtualLocation.latitude,
          ),
        ),
        circleRadius: 14.0,
        circleColor: Colors.blue.toARGB32(),
        circleStrokeWidth: 4.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );
  }

  Widget _buildProgressInfo(GoalModel goal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal name
          Text(
            goal.name,
            style: AppTextStyles.displaySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Progress bar
          _buildProgressBar(goal),
          const SizedBox(height: 16),

          // Statistics grid
          _buildStatisticsGrid(goal),
          const SizedBox(height: 16),

          // Next milestone card
          if (goal.nextMilestone != null)
            _buildNextMilestoneCard(goal.nextMilestone!),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GoalModel goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${goal.progressPercentage.toStringAsFixed(1)}% Complete',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${goal.currentProgressInKm.toStringAsFixed(2)} / ${goal.totalDistanceInKm.toStringAsFixed(2)} km',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            minHeight: 12,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(GoalModel goal) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag,
            label: 'Milestones',
            value: '${goal.milestonesReached}/${goal.totalMilestones}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.straighten,
            label: 'Remaining',
            value: '${goal.remainingDistanceInKm.toStringAsFixed(0)} km',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMilestoneCard(MilestoneModel milestone) {
    final distanceToMilestone = milestone.distanceFromStart -
        (ref.read(activeGoalProvider).value?.currentProgress ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Milestone',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.cityName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(distanceToMilestone / 1000).toStringAsFixed(2)} km to go',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _polylineManager = null;
    _circleManager = null;
    super.dispose();
  }
}
