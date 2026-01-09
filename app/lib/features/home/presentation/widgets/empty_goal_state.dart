import 'package:flutter/material.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';

/// Empty state widget shown when user has no active goals
class EmptyGoalState extends StatelessWidget {
  const EmptyGoalState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'No Active Journey',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Create your first goal to start your virtual journey! Choose a destination and track your progress as you run.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Create Goal Button
            CustomButton(
              text: 'Create Your First Goal',
              onPressed: () {
                AppRouter.navigateTo(context, RouteConstants.goalCreation);
              },
              icon: Icons.add_location,
            ),
            const SizedBox(height: 16),

            // Or just start running
            Text(
              'Or',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Just Start Running',
              onPressed: () {
                AppRouter.navigateTo(context, RouteConstants.runTracking);
              },
              icon: Icons.directions_run,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
