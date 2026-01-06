import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/loading_indicator.dart';
import 'package:run_to_canada/core/widgets/live_route_map_widget.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/runs/data/services/run_tracking_service.dart';
import 'package:run_to_canada/features/runs/presentation/providers/run_tracking_provider.dart';
import 'package:run_to_canada/features/runs/presentation/screens/run_summary_screen.dart';

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
          // Navigate to run summary screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RunSummaryScreen(run: run),
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
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _handleCancel,
          ),
          title: _buildPulsingHeader(status),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Faded map background (30% opacity)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: LiveRouteMapWidget(
                  routePoints: ref.read(runTrackingServiceProvider).routePoints,
                  height: double.infinity,
                  followCurrentPosition: true,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80), // Space below app bar

                  // Huge distance display (84px)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          useMetric
                              ? stats.distanceInKm.toStringAsFixed(2)
                              : stats.distanceInMiles.toStringAsFixed(2),
                          style: AppTextStyles.displayXL.copyWith(
                            fontSize: 84,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          useMetric ? 'KILOMETERS' : 'MILES',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3-column metric cards with glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGlassMetricCard(
                            label: 'TIME',
                            value: _formatDuration(stats.duration),
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassMetricCard(
                            label: 'PACE',
                            value: _formatPace(stats.pace, useMetric),
                            unit: useMetric ? 'min/km' : 'min/mi',
                            icon: Icons.speed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassMetricCard(
                            label: 'SPEED',
                            value: _formatSpeed(stats.speed, useMetric),
                            unit: useMetric ? 'km/h' : 'mph',
                            icon: Icons.flash_on,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom dock with pause button
                  _buildBottomDock(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingHeader(RunStatus status) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: status == RunStatus.running ? value : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == RunStatus.running)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              if (status == RunStatus.running) const SizedBox(width: 8),
              Text(
                status == RunStatus.running ? 'RUNNING...' : 'PAUSED',
                style: AppTextStyles.labelLarge.copyWith(
                  color: status == RunStatus.running
                      ? AppColors.success
                      : AppColors.warning,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      onEnd: () {
        if (status == RunStatus.running && mounted) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  Widget _buildGlassMetricCard({
    required String label,
    required String value,
    String? unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statsLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (unit != null)
            Text(
              unit,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock(RunStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Lock button (left)
          _buildCircularButton(
            icon: Icons.lock_outline,
            size: 56,
            onPressed: () {
              // TODO: Implement screen lock functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Screen lock feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // Large pause/resume button (center, 96px)
          _buildCircularButton(
            icon: status == RunStatus.running ? Icons.pause : Icons.play_arrow,
            size: 96,
            isPrimary: true,
            onPressed: _handlePauseResume,
          ),

          // Stop button (right) - changed from camera to stop
          _buildCircularButton(
            icon: Icons.stop,
            size: 56,
            color: AppColors.error,
            onPressed: _handleStop,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required double size,
    bool isPrimary = false,
    Color? color,
    required VoidCallback onPressed,
  }) {
    final buttonColor = color ?? (isPrimary ? AppColors.primary : AppColors.surface);
    final iconColor = isPrimary || color != null ? Colors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : buttonColor,
          border: Border.all(
            color: isPrimary ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.4,
        ),
      ),
    );
  }
}
