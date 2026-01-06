import 'package:flutter/material.dart';

/// Custom page transitions for smooth navigation
class PageTransitions {
  /// Fade transition with optional slide up
  static PageRouteBuilder<T> fadeIn<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    bool slideUp = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        if (slideUp) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          final slideTween = Tween(begin: begin, end: end);
          final slideAnimation = curvedAnimation.drive(slideTween);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        }

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  /// Slide from right transition (Material standard)
  static PageRouteBuilder<T> slideFromRight<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return SlideTransition(
          position: curvedAnimation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition (modal style)
  static PageRouteBuilder<T> slideFromBottom<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: curvedAnimation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition (for dialogs/modals)
  static PageRouteBuilder<T> scaleAndFade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.9;
        const end = 1.0;
        final scaleTween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: curvedAnimation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }

  /// No transition (instant)
  static PageRouteBuilder<T> instant<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}

/// Extension on BuildContext for easy navigation with transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with fade transition
  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.fadeIn(page: page),
    );
  }

  /// Navigate with slide from right transition
  Future<T?> slideToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.slideFromRight(page: page),
    );
  }

  /// Navigate with slide from bottom transition (modal style)
  Future<T?> modalToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.slideFromBottom(page: page),
    );
  }

  /// Navigate with scale and fade (dialog style)
  Future<T?> dialogToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageTransitions.scaleAndFade(page: page),
    );
  }
}
