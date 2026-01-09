import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/widgets/loading_widgets.dart';
import 'package:run_to_canada/features/onboarding/providers/onboarding_provider.dart';

/// Initial screen that checks onboarding status and routes accordingly
/// Shows onboarding on first launch, otherwise goes to login
class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return onboardingCompleted.when(
      data: (completed) {
        // Navigate to appropriate screen based on onboarding status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (completed) {
            // Onboarding completed, go to login
            AppRouter.navigateAndRemoveUntil(
              context,
              RouteConstants.login,
            );
          } else {
            // First time user, show onboarding
            AppRouter.navigateAndRemoveUntil(
              context,
              RouteConstants.onboarding,
            );
          }
        });

        // Show loading while routing
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(
            child: LoadingSpinner(),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: LoadingSpinner(),
        ),
      ),
      error: (error, stack) {
        // On error, default to login screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.navigateAndRemoveUntil(
            context,
            RouteConstants.login,
          );
        });

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(
            child: LoadingSpinner(),
          ),
        );
      },
    );
  }
}
