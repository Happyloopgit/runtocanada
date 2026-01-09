import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/run_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/route_map_widget.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../goals/presentation/providers/goal_service_provider.dart';
import '../../../goals/presentation/screens/milestone_reached_screen.dart';
import '../../../goals/data/services/goal_service.dart';
import '../../data/datasources/run_local_datasource.dart';
import '../../../../core/data/providers/sync_providers.dart';
import '../../../../core/services/ad_service_provider.dart';
import '../../../premium/presentation/providers/premium_providers.dart';

class RunSummaryScreen extends ConsumerStatefulWidget {
  final RunModel run;

  const RunSummaryScreen({
    super.key,
    required this.run,
  });

  @override
  ConsumerState<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends ConsumerState<RunSummaryScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.run.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Show interstitial ad for free users
  Future<void> _maybeShowInterstitialAd() async {
    // Only show ads to non-premium users
    final isPremium = await ref.read(isPremiumProvider.future);
    if (isPremium) {
      return;
    }

    // Check if we should show ad (based on frequency)
    final adService = ref.read(adServiceProvider);
    if (adService.shouldShowInterstitialAd()) {
      // Show ad if ready (doesn't block if not ready)
      await adService.showInterstitialAd();
    }
  }

  Future<void> _saveRun() async {
    setState(() => _isSaving = true);

    try {
      // Update run with notes if provided
      final updatedRun = widget.run.copyWith(
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Save to Hive with updated notes
      final runLocalDataSource = RunLocalDataSource();
      await runLocalDataSource.saveRun(updatedRun);

      // Queue run for cloud sync
      final syncService = ref.read(syncServiceProvider);
      await syncService.queueRunForSync(updatedRun);

      // Update goal progress if user has an active goal
      GoalProgressResult? progressResult;
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final goalService = ref.read(goalServiceProvider);
        progressResult = await goalService.updateGoalProgress(
          userId: user.uid,
          runDistance: widget.run.totalDistance,
        );
      }

      if (!mounted) return;

      // Check if any new milestones were reached
      if (progressResult != null && progressResult.hasNewMilestones) {
        // Show milestone celebration screen for the first newly reached milestone
        final firstMilestone = progressResult.newlyReachedMilestones.first;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MilestoneReachedScreen(
              milestone: firstMilestone,
              goal: progressResult!.updatedGoal,
              onContinue: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteConstants.home,
                  (route) => false,
                );
              },
              onViewJourney: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteConstants.journeyMap,
                  (route) => false,
                );
              },
            ),
          ),
        );
      } else if (progressResult != null && progressResult.goalCompleted) {
        // Goal completed - show special message
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! You completed your goal!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        // No milestone reached - show interstitial ad then navigate to home
        await _maybeShowInterstitialAd();

        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);

        String message = 'Run saved successfully!';
        if (progressResult != null) {
          final kmAdded = progressResult.progressAdded / 1000;
          message = 'Run saved! +${kmAdded.toStringAsFixed(2)} km to your journey.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving run: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _discardRun() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Run?'),
        content: const Text(
          'Are you sure you want to discard this run? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Delete run from Hive in Sprint 13
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Run discarded'),
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(widget.run.startTime);
    final formattedTime = DateFormat('h:mm a').format(widget.run.startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Summary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Run Completed!',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedDate at $formattedTime',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Route map visualization
            if (widget.run.routePoints.isNotEmpty) ...[
              Text(
                'Route Map',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              RouteMapWidget(
                routePoints: widget.run.routePoints,
                height: 300,
              ),
              const SizedBox(height: 24),
            ],

            // Main statistics - Distance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Distance',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.run.distanceInKm.toStringAsFixed(2)} km',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.run.distanceInMiles.toStringAsFixed(2)} mi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Secondary statistics grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Duration',
                    value: widget.run.formattedDuration,
                    icon: Icons.timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Avg Pace',
                    value: widget.run.formattedAveragePace,
                    icon: Icons.speed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Max Speed',
                    value: '${(widget.run.maxSpeed * 3.6).toStringAsFixed(1)} km/h',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Calories',
                    value: '${widget.run.calories.toStringAsFixed(0)} kcal',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Elevation Gain',
                    value: '${widget.run.elevationGain.toStringAsFixed(0)} m',
                    icon: Icons.terrain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Route Points',
                    value: widget.run.routePoints.length.toString(),
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notes section
            Text(
              'Add Notes (Optional)',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _notesController,
              label: 'How did you feel during this run?',
              maxLines: 4,
              enabled: !_isSaving,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _discardRun,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Save Run',
                    onPressed: _saveRun,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View history button
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteConstants.home,
                        (route) => false,
                      );
                      // TODO: Navigate to history tab when implemented
                    },
              child: const Text('View Run History'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
