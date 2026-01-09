import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';

/// Individual onboarding page with icon, title, and description
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spacer to push content towards center
          const Spacer(),

          // Large circular gradient icon
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: iconGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconGradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.textOnPrimary,
            ),
          ),

          const SizedBox(height: 48),

          // Title with gradient text
          ShaderMask(
            shaderCallback: (bounds) => iconGradient.createShader(bounds),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textOnPrimary,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),

          // Spacer for bottom controls
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
