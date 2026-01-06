import 'package:run_to_canada/core/data/services/hive_service.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    final box = HiveService.getBox(HiveService.cacheBox);
    return box.get(_onboardingCompletedKey, defaultValue: false) as bool;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final box = HiveService.getBox(HiveService.cacheBox);
    await box.put(_onboardingCompletedKey, true);
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final box = HiveService.getBox(HiveService.cacheBox);
    await box.delete(_onboardingCompletedKey);
  }
}
