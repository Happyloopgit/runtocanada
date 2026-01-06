import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';

/// Next milestone preview card
///
/// Features:
/// - Orange/yellow gradient background (milestone theme)
/// - Star icon with "Next Milestone" label
/// - Milestone city name
/// - Distance remaining to milestone
/// - Estimated runs remaining
/// - Optional city photo thumbnail
class NextMilestoneCard extends StatelessWidget {
  final String milestoneName;
  final double distanceRemaining;
  final String unit; // 'km' or 'mi'
  final int? estimatedRunsLeft;
  final String? photoUrl;
  final VoidCallback? onTap;

  const NextMilestoneCard({
    super.key,
    required this.milestoneName,
    required this.distanceRemaining,
    this.unit = 'km',
    this.estimatedRunsLeft,
    this.photoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.milestoneGradientStart, // #FF6B35
              AppColors.milestoneGradientEnd, // #FFA500
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.milestone.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side: Icon and content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Next Milestone" label with star
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NEXT MILESTONE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Milestone name
                  Text(
                    milestoneName,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Distance remaining
                  Text(
                    '${distanceRemaining.toStringAsFixed(1)} $unit away',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  // Estimated runs
                  if (estimatedRunsLeft != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '~$estimatedRunsLeft run${estimatedRunsLeft! == 1 ? "" : "s"} left',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right side: Photo thumbnail (if available)
            if (photoUrl != null && photoUrl!.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
