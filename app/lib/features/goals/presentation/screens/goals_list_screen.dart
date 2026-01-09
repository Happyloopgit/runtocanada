import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart' as home_providers;
import '../../domain/models/goal_model.dart';
import '../providers/goals_list_provider.dart';
import '../providers/goal_service_provider.dart';
import 'goal_creation_screen.dart';

/// Goals List Screen
/// Shows all goals: active, saved/inactive, and completed
class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view goals')),
      );
    }

    final goalsAsync = ref.watch(userGoalsProvider(userId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }

          // Categorize goals
          final activeGoal = goals.firstWhere(
            (g) => g.isActive && !g.isCompleted,
            orElse: () => goals.first, // Fallback
          );
          final hasActiveGoal = goals.any((g) => g.isActive && !g.isCompleted);

          final savedGoals = goals
              .where((g) => !g.isActive && !g.isCompleted)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final completedGoals = goals
              .where((g) => g.isCompleted)
              .toList()
            ..sort((a, b) => (b.completedAt ?? b.createdAt)
                .compareTo(a.completedAt ?? a.createdAt));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Page Title
              const SizedBox(height: 40),
              Text(
                'My Goals',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Active Goal Section
              if (hasActiveGoal) ...[
                _buildSectionHeader('Active Goal'),
                const SizedBox(height: 12),
                _buildActiveGoalCard(context, ref, activeGoal, userId),
                const SizedBox(height: 24),
              ],

              // Saved Goals Section
              if (savedGoals.isNotEmpty) ...[
                _buildSectionHeader('Saved Goals'),
                const SizedBox(height: 12),
                ...savedGoals.map((goal) =>
                    _buildSavedGoalCard(context, ref, goal, userId)),
                const SizedBox(height: 24),
              ],

              // Completed Goals Section
              if (completedGoals.isNotEmpty) ...[
                _buildSectionHeader('Completed Goals'),
                const SizedBox(height: 12),
                ...completedGoals.map((goal) =>
                    _buildCompletedGoalCard(context, ref, goal)),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading goals: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GoalCreationScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Goals Yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first running goal!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalCreationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Goal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActiveGoalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String userId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to goal details (journey map)
            // TODO: Navigate to journey map screen
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        _showGoalOptions(context, ref, goal, userId);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  goal.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${goal.startLocation.city ?? goal.startLocation.placeName} → ${goal.destinationLocation.city ?? goal.destinationLocation.placeName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progressPercentage / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(1)}% Complete',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${goal.currentProgressInKm.toStringAsFixed(1)} / ${goal.totalDistanceInKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Milestones: ${goal.milestonesReached} / ${goal.totalMilestones}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedGoalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String userId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to goal details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _showGoalOptions(context, ref, goal, userId);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.startLocation.city ?? goal.startLocation.placeName} → ${goal.destinationLocation.city ?? goal.destinationLocation.placeName}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.totalDistanceInKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.totalMilestones} milestones',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _activateGoal(context, ref, goal, userId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Activate Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedGoalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
  ) {
    final completedDate = goal.completedAt ?? goal.updatedAt;
    final formattedDate =
        '${completedDate.day}/${completedDate.month}/${completedDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to completed goal details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  goal.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.startLocation.city ?? goal.startLocation.placeName} → ${goal.destinationLocation.city ?? goal.destinationLocation.placeName}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed $formattedDate',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.totalDistanceInKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'All ${goal.totalMilestones} milestones reached!',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  void _showGoalOptions(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!goal.isActive && !goal.isCompleted)
              ListTile(
                leading: const Icon(Icons.play_arrow, color: AppColors.primary),
                title: Text(
                  'Activate Goal',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () async {
                  final ctx = context;
                  Navigator.pop(context);
                  await _activateGoal(ctx, ref, goal, userId);
                },
              ),
            if (goal.isActive)
              ListTile(
                leading: const Icon(Icons.pause, color: AppColors.warning),
                title: Text(
                  'Deactivate Goal',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _deactivateGoal(ref, goal);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Delete Goal',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _deleteGoal(context, ref, goal);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _activateGoal(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    String userId,
  ) async {
    // Get current active goal to check if there is one
    final dataSource = ref.read(goalLocalDataSourceProvider);
    final currentActiveGoal = dataSource.getActiveGoalSafe(userId);

    // If there's already an active goal, show confirmation
    if (currentActiveGoal != null && currentActiveGoal.id != goal.id) {
      final confirmed = await _showActivateConfirmation(
        context: context,
        goal: goal,
        currentGoal: currentActiveGoal,
      );

      if (confirmed != true) return;
    }

    // Activate the goal
    await dataSource.setGoalActive(goal.id);

    // Invalidate all relevant providers to trigger UI refresh
    ref.invalidate(userGoalsProvider(userId));

    // CRITICAL: Invalidate home screen providers so activated goal shows on home screen
    ref.invalidate(home_providers.homeScreenDataProvider);
    ref.invalidate(home_providers.activeGoalProvider);
    ref.invalidate(home_providers.hasActiveGoalProvider);
    ref.invalidate(home_providers.nextMilestoneProvider);
    ref.invalidate(home_providers.progressStatsProvider);
  }

  Future<bool?> _showActivateConfirmation({
    required BuildContext context,
    required GoalModel goal,
    required GoalModel currentGoal,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Activate Goal?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activating "${goal.name}" will replace your current active goal:',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentGoal.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Progress: ${currentGoal.progressPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your current progress will be saved, but this goal will no longer be active.',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Activate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateGoal(WidgetRef ref, GoalModel goal) async {
    final dataSource = ref.read(goalLocalDataSourceProvider);
    final updatedGoal = goal.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
    await dataSource.updateGoal(updatedGoal);
    ref.invalidate(userGoalsProvider(goal.userId));

    // Invalidate home screen providers so deactivation reflects on home screen
    ref.invalidate(home_providers.homeScreenDataProvider);
    ref.invalidate(home_providers.activeGoalProvider);
    ref.invalidate(home_providers.hasActiveGoalProvider);
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Goal?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataSource = ref.read(goalLocalDataSourceProvider);
      await dataSource.deleteGoal(goal.id);
      ref.invalidate(userGoalsProvider(goal.userId));
    }
  }
}
