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
import 'package:run_to_canada/features/home/presentation/widgets/achievements_carousel.dart';

/// Home screen - main dashboard
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
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
                    color: AppColors.textPrimaryDark,
                  ),
                )
              : null,
          orElse: () => null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimaryDark,
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      floatingActionButton: userAsync.maybeWhen(
        data: (user) => user != null
            ? GlowingFAB(
                icon: Icons.play_arrow,
                onPressed: () async {
                  final canStart = await ref.read(canStartRunProvider.future);
                  if (!canStart && context.mounted) {
                    AppRouter.navigateTo(context, RouteConstants.paywall);
                  } else if (context.mounted) {
                    AppRouter.navigateTo(context, RouteConstants.runTracking);
                  }
                },
                size: 64,
              )
            : null,
        orElse: () => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    final firstName = name.split(' ').first;
    return '$timeGreeting, $firstName';
  }

  Widget _buildModernDashboard(BuildContext context, WidgetRef ref, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journey Title
          Text(
            'Toronto to Vancouver',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Journey Map Card
          JourneyMapCard(
            currentCity: 'Journey',
            dayNumber: 14,
            mapWidget: Container(
              color: AppColors.surfaceDark,
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            onTap: () {
              AppRouter.navigateTo(context, RouteConstants.journeyMap);
            },
          ),
          const SizedBox(height: 20),

          // Stats Grid
          const JourneyStatsGrid(
            coveredDistance: 1200,
            remainingDistance: 3200,
            unit: 'km',
            weeklyTrend: 5.2,
            estimatedArrival: null,
          ),
          const SizedBox(height: 24),

          // Next Milestone
          const NextMilestoneCard(
            milestoneName: 'Lake Superior',
            distanceRemaining: 120,
            unit: 'km',
            estimatedRunsLeft: 2,
            photoUrl: null,
          ),
          const SizedBox(height: 24),

          // Recent Achievements
          AchievementsCarousel(
            achievements: const [
              Achievement(
                icon: Icons.speed,
                title: 'Fastest 5K',
                subtitle: 'Yesterday',
                gradient: Achievement.purpleGradient,
              ),
              Achievement(
                icon: Icons.local_fire_department,
                title: '3 Day Streak',
                subtitle: 'Active',
                gradient: Achievement.orangeGradient,
              ),
            ],
            onViewAll: () {
              // TODO: Navigate to achievements screen
            },
          ),
          const SizedBox(height: 24),

          // Quick Actions
          CustomButton(
            text: 'Start Run',
            onPressed: () async {
              final canStart = await ref.read(canStartRunProvider.future);
              if (!canStart && context.mounted) {
                AppRouter.navigateTo(context, RouteConstants.paywall);
              } else if (context.mounted) {
                AppRouter.navigateTo(context, RouteConstants.runTracking);
              }
            },
            icon: Icons.play_arrow,
          ),
          const SizedBox(height: 12),

          CustomButton(
            text: 'View Run History',
            onPressed: () {
              AppRouter.navigateTo(context, RouteConstants.runHistory);
            },
            icon: Icons.history,
            isOutlined: true,
          ),
          const SizedBox(height: 12),

          CustomButton(
            text: 'Create New Goal',
            onPressed: () async {
              final canCreate = await ref.read(canCreateGoalProvider.future);
              if (!canCreate && context.mounted) {
                AppRouter.navigateTo(context, RouteConstants.paywall);
              } else if (context.mounted) {
                AppRouter.navigateTo(context, RouteConstants.goalCreation);
              }
            },
            icon: Icons.flag,
            isOutlined: true,
          ),
          const SizedBox(height: 24),

          // Banner Ad (only shown to free users)
          if (!user.hasActivePremium) const BannerAdWidget(),
        ],
      ),
    );
  }
}
