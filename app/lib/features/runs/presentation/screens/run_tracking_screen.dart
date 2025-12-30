import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/core/widgets/loading_indicator.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/runs/data/services/run_tracking_service.dart';
import 'package:run_to_canada/features/runs/presentation/providers/run_tracking_provider.dart';

class RunTrackingScreen extends ConsumerStatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  ConsumerState<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends ConsumerState<RunTrackingScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
      final trackingService = ref.read(runTrackingServiceProvider);
      final user = ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        throw Exception('User not logged in');
      }

      await trackingService.startRun(user.uid);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _handlePauseResume() async {
    final trackingService = ref.read(runTrackingServiceProvider);
    final status = trackingService.status;

    if (status == RunStatus.running) {
      trackingService.pauseRun();
    } else if (status == RunStatus.paused) {
      trackingService.resumeRun();
    }
  }

  Future<void> _handleStop() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Run?'),
        content: const Text(
          'Are you sure you want to stop this run? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (shouldStop == true && mounted) {
      try {
        final trackingService = ref.read(runTrackingServiceProvider);
        final run = await trackingService.stopRun();

        if (mounted && run != null) {
          // Navigate to run summary screen (to be created in Sprint 6)
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Run saved successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        _showError('Failed to save run: $e');
      }
    }
  }

  Future<void> _handleCancel() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Run?'),
        content: const Text(
          'Are you sure you want to cancel this run? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Run'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && mounted) {
      final trackingService = ref.read(runTrackingServiceProvider);
      trackingService.cancelRun();
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace(double? paceInMinPerKm, bool useMetric) {
    if (paceInMinPerKm == null || paceInMinPerKm == 0) {
      return '--:--';
    }

    double pace = useMetric ? paceInMinPerKm : paceInMinPerKm * 1.60934;
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSpeed(double? speedInMps, bool useMetric) {
    if (speedInMps == null || speedInMps == 0) {
      return '0.0';
    }

    if (useMetric) {
      final kmh = speedInMps * 3.6;
      return kmh.toStringAsFixed(1);
    } else {
      final mph = speedInMps * 2.23694;
      return mph.toStringAsFixed(1);
    }
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statsLarge,
          ),
          Text(
            unit,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Starting Run...'),
        ),
        body: const Center(
          child: LoadingIndicator(),
        ),
      );
    }

    final statusAsync = ref.watch(runStatusProvider);
    final statsAsync = ref.watch(runStatsProvider);

    return statusAsync.when(
      data: (status) => statsAsync.when(
        data: (stats) => _buildTrackingUI(context, status, stats, useMetric: true),
        loading: () => const Scaffold(
          body: Center(child: LoadingIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('Error loading stats: $error')),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading status: $error')),
      ),
    );
  }

  Widget _buildTrackingUI(
    BuildContext context,
    RunStatus status,
    RunStats stats, {
    required bool useMetric,
  }) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          await _handleCancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Run Tracking'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCancel,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == RunStatus.running
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status == RunStatus.running
                            ? Icons.play_circle_filled
                            : Icons.pause_circle_filled,
                        color: status == RunStatus.running
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status == RunStatus.running ? 'Running' : 'Paused',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: status == RunStatus.running
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Main Display - Duration
                Text(
                  'Duration',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(stats.duration),
                  style: AppTextStyles.statsLarge.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        label: 'Distance',
                        value: useMetric
                            ? stats.distanceInKm.toStringAsFixed(2)
                            : stats.distanceInMiles.toStringAsFixed(2),
                        unit: useMetric ? 'km' : 'mi',
                        icon: Icons.directions_run,
                      ),
                      _buildStatCard(
                        label: 'Pace',
                        value: _formatPace(stats.pace, useMetric),
                        unit: useMetric ? 'min/km' : 'min/mi',
                        icon: Icons.speed,
                      ),
                      _buildStatCard(
                        label: 'Speed',
                        value: _formatSpeed(stats.speed, useMetric),
                        unit: useMetric ? 'km/h' : 'mph',
                        icon: Icons.flash_on,
                      ),
                      _buildStatCard(
                        label: 'Max Speed',
                        value: _formatSpeed(stats.maxSpeed, useMetric),
                        unit: useMetric ? 'km/h' : 'mph',
                        icon: Icons.flash_on_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Route Points Count Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.route,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Route Points: ${stats.routePointsCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Control Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: status == RunStatus.running ? 'Pause' : 'Resume',
                        onPressed: _handlePauseResume,
                        icon: status == RunStatus.running
                            ? Icons.pause
                            : Icons.play_arrow,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Stop',
                        onPressed: _handleStop,
                        icon: Icons.stop,
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
