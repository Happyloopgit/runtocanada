import 'package:flutter/material.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:run_to_canada/features/auth/presentation/screens/login_screen.dart';
import 'package:run_to_canada/features/auth/presentation/screens/signup_screen.dart';
import 'package:run_to_canada/features/home/presentation/screens/home_screen.dart';
import 'package:run_to_canada/features/runs/presentation/screens/run_tracking_screen.dart';
import 'package:run_to_canada/features/maps/presentation/screens/map_demo_screen.dart';
import 'package:run_to_canada/features/goals/presentation/screens/goal_creation_screen.dart';
import 'package:run_to_canada/features/goals/presentation/screens/journey_map_screen.dart';

/// App router configuration
class AppRouter {
  /// Generate routes for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteConstants.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case RouteConstants.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case RouteConstants.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case RouteConstants.runTracking:
        return MaterialPageRoute(
          builder: (_) => const RunTrackingScreen(),
          settings: settings,
        );

      case RouteConstants.mapDemo:
        return MaterialPageRoute(
          builder: (_) => const MapDemoScreen(),
          settings: settings,
        );

      case RouteConstants.goalCreation:
        return MaterialPageRoute(
          builder: (_) => const GoalCreationScreen(),
          settings: settings,
        );

      case RouteConstants.journeyMap:
        return MaterialPageRoute(
          builder: (_) => const JourneyMapScreen(),
          settings: settings,
        );

      // TODO: Add more routes as we implement features

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
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
