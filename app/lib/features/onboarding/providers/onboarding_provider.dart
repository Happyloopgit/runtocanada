import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/features/onboarding/data/onboarding_service.dart';

/// Provider to check if onboarding is completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return await OnboardingService.isOnboardingCompleted();
});
