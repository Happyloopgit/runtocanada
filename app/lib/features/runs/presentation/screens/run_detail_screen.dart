import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/run_model.dart';
import '../../data/datasources/run_local_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';

class RunDetailScreen extends ConsumerStatefulWidget {
  final RunModel run;

  const RunDetailScreen({
    super.key,
    required this.run,
  });

  @override
  ConsumerState<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends ConsumerState<RunDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isEditingNotes = false;
  bool _isSaving = false;
  late RunModel _currentRun;

  @override
  void initState() {
    super.initState();
    _currentRun = widget.run;
    _notesController.text = _currentRun.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    setState(() => _isSaving = true);

    try {
      final updatedRun = _currentRun.copyWith(
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final dataSource = RunLocalDataSource();
      await dataSource.saveRun(updatedRun);

      if (mounted) {
        setState(() {
          _currentRun = updatedRun;
          _isEditingNotes = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving notes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteRun() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Run?'),
        content: const Text(
          'Are you sure you want to delete this run? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final dataSource = RunLocalDataSource();
        await dataSource.deleteRun(_currentRun.id);

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Run deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting run: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(_currentRun.startTime);
    final formattedStartTime = DateFormat('h:mm a').format(_currentRun.startTime);
    final formattedEndTime = DateFormat('h:mm a').format(_currentRun.endTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRun,
            tooltip: 'Delete Run',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date and time card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formattedDate,
                          style: AppTextStyles.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeInfo('Start', formattedStartTime),
                        Container(
                          height: 40,
                          width: 1,
                          color: AppColors.divider,
                        ),
                        _buildTimeInfo('End', formattedEndTime),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Main distance display
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
                    'Total Distance',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentRun.distanceInKm.toStringAsFixed(2)} km',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_currentRun.distanceInMiles.toStringAsFixed(2)} mi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats grid
            Text(
              'Performance Metrics',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Duration',
                    value: _currentRun.formattedDuration,
                    icon: Icons.timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Avg Pace',
                    value: _currentRun.formattedAveragePace,
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
                    value: '${(_currentRun.maxSpeed * 3.6).toStringAsFixed(1)} km/h',
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Calories',
                    value: '${_currentRun.calories.toStringAsFixed(0)} kcal',
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
                    value: '${_currentRun.elevationGain.toStringAsFixed(0)} m',
                    icon: Icons.terrain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Route Points',
                    value: _currentRun.routePoints.length.toString(),
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notes section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: AppTextStyles.headlineSmall,
                ),
                if (!_isEditingNotes)
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditingNotes = true),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(_currentRun.notes == null ? 'Add' : 'Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isEditingNotes) ...[
              CustomTextField(
                controller: _notesController,
                label: 'How did you feel during this run?',
                maxLines: 4,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _isEditingNotes = false;
                              _notesController.text = _currentRun.notes ?? '';
                            });
                          },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveNotes,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _currentRun.notes == null || _currentRun.notes!.isEmpty
                    ? Text(
                        'No notes for this run',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        _currentRun.notes!,
                        style: AppTextStyles.bodyLarge,
                      ),
              ),
            ],

            const SizedBox(height: 24),

            // Sync status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentRun.isSynced
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentRun.isSynced ? AppColors.success : AppColors.warning,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentRun.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: _currentRun.isSynced ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentRun.isSynced ? 'Synced to cloud' : 'Not synced yet',
                    style: AppTextStyles.caption.copyWith(
                      color: _currentRun.isSynced ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
              color: AppColors.textSecondary,
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
