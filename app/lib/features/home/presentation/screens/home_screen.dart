import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/runs/presentation/screens/run_history_screen.dart';
import 'package:run_to_canada/features/premium/presentation/providers/premium_providers.dart';

/// Home screen - main dashboard
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run to Canada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              AppRouter.navigateTo(context, RouteConstants.profile);
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.fullName}!',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Email: ${user.email}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Premium: ${user.hasActivePremium ? "Yes" : "No"}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Free tier progress indicator (only for non-premium users)
                if (!user.hasActivePremium)
                  Consumer(
                    builder: (context, ref, child) {
                      final progressAsync = ref.watch(freeLimitProgressProvider);
                      final remainingAsync = ref.watch(remainingFreeDistanceProvider);

                      return progressAsync.when(
                        data: (progress) => remainingAsync.when(
                          data: (remaining) => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: progress >= 0.8
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: progress >= 0.8
                                    ? AppColors.error
                                    : AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Free Tier Journey',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${remaining.toStringAsFixed(1)} km left',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: progress >= 0.8
                                            ? AppColors.error
                                            : AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress >= 0.8
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  progress >= 1.0
                                      ? 'Limit reached! Upgrade to premium to continue.'
                                      : progress >= 0.8
                                          ? 'Almost there! Upgrade to premium for unlimited distance.'
                                          : 'Upgrade to premium for unlimited distance!',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      );
                    },
                  ),

                if (!user.hasActivePremium) const SizedBox(height: 24),

                // Start Run Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: CustomButton(
                      text: 'Start Run',
                      onPressed: () async {
                        // Check if user can start a run
                        final canStart = await ref.read(canStartRunProvider.future);
                        if (!canStart && context.mounted) {
                          // Show paywall if limit reached
                          AppRouter.navigateTo(context, RouteConstants.paywall);
                        } else if (context.mounted) {
                          AppRouter.navigateTo(context, RouteConstants.runTracking);
                        }
                      },
                      icon: Icons.play_arrow,
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // View History Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RunHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('View Run History'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Create Goal Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Check if user can create a goal
                        final canCreate = await ref.read(canCreateGoalProvider.future);
                        if (!canCreate && context.mounted) {
                          // Show paywall if limit reached
                          AppRouter.navigateTo(context, RouteConstants.paywall);
                        } else if (context.mounted) {
                          AppRouter.navigateTo(context, RouteConstants.goalCreation);
                        }
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text('Create New Goal'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // View Journey Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppRouter.navigateTo(context, RouteConstants.journeyMap);
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('View Journey Progress'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Map Demo Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppRouter.navigateTo(context, RouteConstants.mapDemo);
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('View Map Demo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Stats Placeholder
                Text(
                  'Recent Activity',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Your recent runs will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
