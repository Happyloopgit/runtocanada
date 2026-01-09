import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';

/// Recent achievements horizontal carousel
///
/// Features:
/// - Horizontal scrolling list of achievement chips
/// - Gradient backgrounds (purple, orange, blue)
/// - Icon, title, and subtitle
/// - Compact size for dashboard display
class AchievementsCarousel extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback? onViewAll;

  const AchievementsCarousel({
    super.key,
    required this.achievements,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Achievements',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Horizontal scrolling list
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return AchievementChip(achievement: achievements[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual achievement chip
class AchievementChip extends StatelessWidget {
  final Achievement achievement;

  const AchievementChip({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        gradient: achievement.gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: achievement.gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            achievement.title,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            achievement.subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Achievement data model
class Achievement {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  const Achievement({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  // Predefined gradient styles
  static const purpleGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // purple-500
      Color(0xFF4F46E5), // indigo-600
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const orangeGradient = LinearGradient(
    colors: [
      Color(0xFFFB923C), // orange-400
      Color(0xFFEF4444), // red-500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blueGradient = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.primaryDark,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const greenGradient = LinearGradient(
    colors: [
      Color(0xFF10B981), // green-500
      Color(0xFF059669), // green-600
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
