import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/run_model.dart';
import '../../data/datasources/run_local_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import 'run_detail_screen.dart';

// Provider for run list
final runListProvider = FutureProvider<List<RunModel>>((ref) async {
  final dataSource = RunLocalDataSource();
  final runs = dataSource.getAllRuns();
  // Sort by start time descending (newest first)
  runs.sort((a, b) => b.startTime.compareTo(a.startTime));
  return runs;
});

class RunHistoryScreen extends ConsumerWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(runListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: runsAsync.when(
        data: (runs) {
          if (runs.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildRunList(context, runs, ref);
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading runs',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(runListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 120,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No Runs Yet',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first run to begin your journey!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Running'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunList(BuildContext context, List<RunModel> runs, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(runListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: runs.length + 1, // +1 for summary card
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(runs);
          }
          final run = runs[index - 1];
          return _RunListItem(run: run);
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<RunModel> runs) {
    final totalDistance = runs.fold<double>(
      0,
      (sum, run) => sum + run.totalDistance,
    );
    final totalDuration = runs.fold<int>(
      0,
      (sum, run) => sum + run.duration,
    );
    final totalRuns = runs.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Overall Statistics',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  label: 'Total Runs',
                  value: totalRuns.toString(),
                  icon: Icons.directions_run,
                ),
                _buildSummaryStat(
                  label: 'Total Distance',
                  value: '${(totalDistance / 1000).toStringAsFixed(1)} km',
                  icon: Icons.route,
                ),
                _buildSummaryStat(
                  label: 'Total Time',
                  value: _formatTotalDuration(totalDuration),
                  icon: Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
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
    );
  }

  String _formatTotalDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }
}

class _RunListItem extends StatelessWidget {
  final RunModel run;

  const _RunListItem({required this.run});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(run.startTime);
    final formattedTime = DateFormat('h:mm a').format(run.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RunDetailScreen(run: run),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedTime,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${run.distanceInKm.toStringAsFixed(2)} km',
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: AppColors.divider,
                  ),
                  _buildStat(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: run.formattedDuration,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: AppColors.divider,
                  ),
                  _buildStat(
                    icon: Icons.speed,
                    label: 'Pace',
                    value: run.formattedAveragePace,
                  ),
                ],
              ),

              // Notes preview if available
              if (run.notes != null && run.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          run.notes!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
