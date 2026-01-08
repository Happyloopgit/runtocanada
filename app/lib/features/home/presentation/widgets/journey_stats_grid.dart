import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';

/// Journey statistics grid (2-column layout)
///
/// Features:
/// - "Covered" distance stat with trend indicator
/// - Remaining distance with estimated arrival
/// - Decorative circle accent on "Covered" card
/// - Glassmorphic card styling
class JourneyStatsGrid extends StatelessWidget {
  final double coveredDistance;
  final double remainingDistance;
  final String? unit; // 'km' or 'mi'
  final double? weeklyTrend; // Percentage trend (+5.2 means +5.2%)
  final DateTime? estimatedArrival;

  const JourneyStatsGrid({
    super.key,
    required this.coveredDistance,
    required this.remainingDistance,
    this.unit = 'km',
    this.weeklyTrend,
    this.estimatedArrival,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Covered stat card
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'Covered',
            value: coveredDistance.toStringAsFixed(0),
            unit: unit!,
            trend: weeklyTrend,
            decorativeCircle: true,
          ),
        ),
        const SizedBox(width: 12),
        // Remaining stat card
        Expanded(
          child: _StatCard(
            icon: Icons.navigation,
            label: 'Remaining',
            value: remainingDistance.toStringAsFixed(0),
            unit: unit!,
            subtitle: estimatedArrival != null
                ? 'Est. arrival ${_formatDate(estimatedArrival!)}'
                : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String? subtitle;
  final double? trend; // Percentage
  final bool decorativeCircle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.subtitle,
    this.trend,
    this.decorativeCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    // Different gradient for each card - ENERGY!
    final gradient = decorativeCircle
        ? const LinearGradient(
            colors: [
              Color(0xFF0D7FF2), // Primary blue
              Color(0xFF0A66C2), // Primary dark
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF7C3AED), // Purple-600
              Color(0xFF5B21B6), // Purple-800
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (decorativeCircle ? AppColors.primary : const Color(0xFF7C3AED))
                .withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circle (top-right corner, partially cut off)
          if (decorativeCircle)
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and label
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Value and unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 38, // Bigger for more ENERGY!
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      unit,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Trend or subtitle
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      trend! >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trend! >= 0 ? "+" : ""}${trend!.toStringAsFixed(1)}% this week',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
