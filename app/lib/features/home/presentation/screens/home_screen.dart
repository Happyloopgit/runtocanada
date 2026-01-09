import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/core/widgets/banner_ad_widget.dart';
import 'package:run_to_canada/core/widgets/user_avatar.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/premium/presentation/providers/premium_providers.dart';
import 'package:run_to_canada/features/home/presentation/widgets/journey_map_card.dart';
import 'package:run_to_canada/features/home/presentation/widgets/journey_stats_grid.dart';
import 'package:run_to_canada/features/home/presentation/widgets/next_milestone_card.dart';
import 'package:run_to_canada/features/home/presentation/widgets/empty_goal_state.dart';
import 'package:run_to_canada/features/home/presentation/widgets/home_journey_map_widget.dart';
import 'package:run_to_canada/features/home/presentation/providers/home_providers.dart';

/// Home screen - main dashboard
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: userAsync.maybeWhen(
            data: (user) => user != null
                ? UserAvatar(
                    initials: user.fullName.isNotEmpty
                      ? user.fullName.substring(0, 1)
                      : 'U',
                    level: null, // TODO: Implement user level system
                    size: 40,
                    onTap: () {
                      AppRouter.navigateTo(context, RouteConstants.profile);
                    },
                  )
                : null,
            orElse: () => null,
          ),
        ),
        title: userAsync.maybeWhen(
          data: (user) => user != null
              ? Text(
                  _getGreeting(user.fullName),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              : null,
          orElse: () => null,
        ),
        actions: [
          // Premium button for non-premium users
          Consumer(
            builder: (context, ref, child) {
              final isPremiumAsync = ref.watch(isPremiumProvider);
              return isPremiumAsync.maybeWhen(
                data: (isPremium) => !isPremium
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.premium.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                AppRouter.navigateTo(context, RouteConstants.paywall);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Hero(
                                      tag: 'premium_icon',
                                      child: const Icon(
                                        Icons.workspace_premium,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Upgrade',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              // TODO: Implement notifications
            },
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

          return _buildModernDashboard(context, ref, user);
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

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    // Removed first name to prevent text truncation in header
    return timeGreeting;
  }

  Widget _buildModernDashboard(BuildContext context, WidgetRef ref, dynamic user) {
    final homeDataAsync = ref.watch(homeScreenDataProvider);

    return homeDataAsync.when(
      data: (homeData) {
        // Show empty state if no active goal
        if (!homeData.hasActiveGoal) {
          return const Column(
            children: [
              Expanded(child: EmptyGoalState()),
              // Banner Ad removed from empty state to prevent duplicate ad widget error
              // Ad is shown in the main dashboard instead (see line ~246)
            ],
          );
        }

        // Show dashboard with real goal data + sticky bottom button
        return Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journey Title - Real goal name
              if (homeData.goalTitle != null)
                Text(
                  homeData.goalTitle!,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),

              // Journey Map Card
              if (homeData.activeGoal != null)
                JourneyMapCard(
                  key: ValueKey('map_${homeData.activeGoal!.id}'), // Force rebuild when goal changes
                  currentCity: _calculateCurrentCity(homeData.nextMilestone),
                  dayNumber: _calculateDayNumber(homeData.activeGoal?.createdAt),
                  mapWidget: HomeJourneyMapWidget(
                    key: ValueKey('journey_map_${homeData.activeGoal!.id}'), // Force widget rebuild
                    goal: homeData.activeGoal!,
                    nextMilestone: homeData.nextMilestone,
                  ),
                  onTap: () {
                    AppRouter.navigateTo(context, RouteConstants.journeyMap);
                  },
                ),
              const SizedBox(height: 20),

              // Stats Grid - Real data from goal progress
              JourneyStatsGrid(
                coveredDistance: homeData.coveredDistanceKm,
                remainingDistance: homeData.remainingDistanceKm,
                unit: 'km', // TODO: Get from user settings
                weeklyTrend: null, // No trend data yet
                estimatedArrival: null, // TODO: Calculate based on average pace
              ),
              const SizedBox(height: 24),

              // Next Milestone - Real next milestone data
              if (homeData.nextMilestone != null)
                NextMilestoneCard(
                  milestoneName: homeData.nextMilestone!.cityName,
                  distanceRemaining: _calculateDistanceToMilestone(
                    homeData.nextMilestone!.distanceFromStart,
                    homeData.progressStats?['currentProgress'] as double? ?? 0.0,
                  ),
                  unit: 'km',
                  estimatedRunsLeft: _estimateRunsToMilestone(
                    homeData.nextMilestone!.distanceFromStart,
                    homeData.progressStats?['currentProgress'] as double? ?? 0.0,
                  ),
                  photoUrl: homeData.nextMilestone!.photoUrl,
                ),
              if (homeData.nextMilestone != null) const SizedBox(height: 32),

              // Bottom padding for content (sticky button + ad will be below)
              SizedBox(height: user.hasActivePremium ? 100 : 160), // Extra space for ad if free user
                ],
              ),
            ),

            // Banner Ad - positioned outside scroll view to prevent Impeller opacity errors
            // Platform views (AdWidget) cannot accept opacity from ScrollView or gradient overlays
            if (!user.hasActivePremium)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80, // Above sticky button (button height + padding)
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor, // Solid background to isolate from gradient
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const BannerAdWidget(),
                ),
              ),

            // Sticky bottom button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16), // Less rounded than default
                    boxShadow: AppColors.buttonShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final canStart = await ref.read(canStartRunProvider.future);
                        if (!canStart && context.mounted) {
                          AppRouter.navigateTo(context, RouteConstants.paywall);
                        } else if (context.mounted) {
                          AppRouter.navigateTo(context, RouteConstants.runTracking);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Start Run',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error loading dashboard', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate day number since goal creation
  int _calculateDayNumber(DateTime? createdAt) {
    if (createdAt == null) return 1;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation + 1; // Day 1 on creation day
  }

  /// Get current city from next milestone or return generic text
  String? _calculateCurrentCity(dynamic nextMilestone) {
    if (nextMilestone == null) return null;
    // Use milestone city name if available
    if (nextMilestone.cityName != null && nextMilestone.cityName!.isNotEmpty) {
      return nextMilestone.cityName;
    }
    return 'Journey';
  }

  /// Calculate distance to next milestone in km
  double _calculateDistanceToMilestone(double milestoneDistance, double currentProgress) {
    final distanceRemaining = (milestoneDistance - currentProgress).clamp(0.0, double.infinity);
    return distanceRemaining / 1000; // Convert meters to km
  }

  /// Estimate number of runs needed to reach milestone (assuming 5km per run)
  int _estimateRunsToMilestone(double milestoneDistance, double currentProgress) {
    const averageRunDistance = 5000.0; // 5km in meters
    final distanceRemaining = (milestoneDistance - currentProgress).clamp(0.0, double.infinity);
    return (distanceRemaining / averageRunDistance).ceil().clamp(1, 999);
  }
}
