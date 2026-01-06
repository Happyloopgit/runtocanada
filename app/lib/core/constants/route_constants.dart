/// Route names for navigation
class RouteConstants {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/home';
  static const String runTracking = '/run-tracking';
  static const String runSummary = '/run-summary';
  static const String runDetail = '/run-detail';
  static const String mapDemo = '/map-demo';

  // Journey Routes
  static const String journeyMap = '/journey-map';
  static const String goalCreation = '/goal-creation';
  static const String milestoneDetail = '/milestone-detail';

  // History Routes
  static const String runHistory = '/run-history';

  // Profile Routes
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Premium Routes
  static const String paywall = '/paywall';

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String initial = '/';

  // Default initial route (checks onboarding status)
  static const String initialRoute = initial;
}
