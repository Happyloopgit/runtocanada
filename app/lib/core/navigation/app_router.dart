import 'package:flutter/material.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/page_transitions.dart';
import 'package:run_to_canada/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:run_to_canada/features/auth/presentation/screens/login_screen.dart';
import 'package:run_to_canada/features/auth/presentation/screens/signup_screen.dart';
import 'package:run_to_canada/features/home/presentation/screens/home_screen.dart';
import 'package:run_to_canada/features/runs/presentation/screens/run_tracking_screen.dart';
import 'package:run_to_canada/features/maps/presentation/screens/map_demo_screen.dart';
import 'package:run_to_canada/features/goals/presentation/screens/goal_creation_screen.dart';
import 'package:run_to_canada/features/goals/presentation/screens/journey_map_screen.dart';
import 'package:run_to_canada/features/profile/presentation/screens/profile_screen.dart';
import 'package:run_to_canada/features/settings/presentation/screens/settings_screen.dart';
import 'package:run_to_canada/features/premium/presentation/screens/paywall_screen.dart';
import 'package:run_to_canada/features/onboarding/presentation/screens/initial_screen.dart';
import 'package:run_to_canada/features/onboarding/presentation/screens/onboarding_screen.dart';

/// App router configuration
class AppRouter {
  /// Generate routes for the app with custom transitions
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Initial route - checks onboarding status and routes accordingly
      case RouteConstants.initial:
        return PageTransitions.instant(
          page: const InitialScreen(),
          settings: settings,
        );

      // Auth screens - fade transition for smooth auth flow
      case RouteConstants.login:
        return PageTransitions.fadeIn(
          page: const LoginScreen(),
          settings: settings,
          slideUp: true,
        );

      case RouteConstants.signup:
        return PageTransitions.fadeIn(
          page: const SignupScreen(),
          settings: settings,
          slideUp: true,
        );

      case RouteConstants.forgotPassword:
        return PageTransitions.fadeIn(
          page: const ForgotPasswordScreen(),
          settings: settings,
          slideUp: true,
        );

      // Home screen - fade in (usually first screen after auth)
      case RouteConstants.home:
        return PageTransitions.fadeIn(
          page: const HomeScreen(),
          settings: settings,
        );

      // Run tracking - slide from bottom (modal feel for starting a run)
      case RouteConstants.runTracking:
        return PageTransitions.slideFromBottom(
          page: const RunTrackingScreen(),
          settings: settings,
        );

      // Map demo - slide from right (exploration)
      case RouteConstants.mapDemo:
        return PageTransitions.slideFromRight(
          page: const MapDemoScreen(),
          settings: settings,
        );

      // Goal creation - slide from bottom (important action)
      case RouteConstants.goalCreation:
        return PageTransitions.slideFromBottom(
          page: const GoalCreationScreen(),
          settings: settings,
        );

      // Journey map - fade with slide (detail view)
      case RouteConstants.journeyMap:
        return PageTransitions.fadeIn(
          page: const JourneyMapScreen(),
          settings: settings,
          slideUp: true,
        );

      // Profile - slide from right (standard navigation)
      case RouteConstants.profile:
        return PageTransitions.slideFromRight(
          page: const ProfileScreen(),
          settings: settings,
        );

      // Settings - slide from right (standard navigation)
      case RouteConstants.settings:
        return PageTransitions.slideFromRight(
          page: const SettingsScreen(),
          settings: settings,
        );

      // Paywall - scale and fade (attention-grabbing modal)
      case RouteConstants.paywall:
        return PageTransitions.slideFromBottom(
          page: const PaywallScreen(),
          settings: settings,
          duration: const Duration(milliseconds: 400),
        );

      // Onboarding - fade in (first-time user experience)
      case RouteConstants.onboarding:
        return PageTransitions.fadeIn(
          page: const OnboardingScreen(),
          settings: settings,
        );

      // TODO: Add more routes as we implement features

      default:
        return PageTransitions.fadeIn(
          page: Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
