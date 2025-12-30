import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';

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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authController = ref.read(authControllerProvider.notifier);
              await authController.signOut();
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
                const SizedBox(height: 48),

                // Start Run Button
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: CustomButton(
                      text: 'Start Run',
                      onPressed: () {
                        AppRouter.navigateTo(context, RouteConstants.runTracking);
                      },
                      icon: Icons.play_arrow,
                      backgroundColor: AppColors.primary,
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
                      'Your recent runs will appear here\n(Sprint 6)',
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
