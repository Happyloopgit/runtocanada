import 'package:flutter/material.dart';

/// App color palette based on designer mockups
/// Design System: Bright blue primary, dark mode first
class AppColors {
  AppColors._();

  // ===== PRIMARY COLORS =====
  // Bright blue - main brand color
  static const Color primary = Color(0xFF0D7FF2);
  static const Color primaryDark = Color(0xFF0A66C2); // Hover/pressed state
  static const Color primaryLight = Color(0xFF3D99FF); // Accents

  // ===== BACKGROUND COLORS =====

  // Light Mode
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Dark Mode (Primary)
  static const Color backgroundDark = Color(0xFF101922);
  static const Color surfaceDark = Color(0xFF1C2A38);
  static const Color surfaceCard = Color(0xFF182430); // Alias for cardDark
  static const Color cardDark = Color(0xFF182430);
  static const Color surfaceInput = Color(0xFF223649);

  // ===== TEXT COLORS =====

  // Light Mode
  static const Color textPrimary = Color(0xFF111418);
  static const Color textSecondary = Color(0xFF637588);
  static const Color textHint = Color(0xFF90ADCB);

  // Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF90ADCB);
  static const Color textHintDark = Color(0xFF637588);

  // ===== STATUS & ACCENT COLORS =====

  // Milestones
  static const Color milestone = Color(0xFFFFA500); // Warm orange
  static const Color milestoneGradientStart = Color(0xFFFF6B35);
  static const Color milestoneGradientEnd = Color(0xFFFFA500);

  // Standard status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ===== GRADIENTS =====

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, milestone],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient milestoneGradient = LinearGradient(
    colors: [milestoneGradientStart, milestoneGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient userLevelGradient = LinearGradient(
    colors: [Color(0xFFFACC15), Color(0xFFEA580C)], // Yellow to orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient achievementPurple = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF4F46E5)], // Purple to indigo
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient achievementOrange = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFEF4444)], // Orange to red
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== SHADOWS & GLOWS =====

  // Primary glow (for buttons, cards)
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  // Milestone glow
  static List<BoxShadow> get milestoneGlow => [
    BoxShadow(
      color: milestone.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: -5,
    ),
  ];

  // Button shadow
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  // Extra large shadow
  static List<BoxShadow> get shadowXL => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 25,
      spreadRadius: -5,
      offset: const Offset(0, 20),
    ),
  ];

  // ===== MAP COLORS =====

  static const Color mapRoute = primary; // Blue for route
  static const Color mapStartMarker = Color(0xFF4CAF50); // Green for start
  static const Color mapEndMarker = Color(0xFFF44336); // Red for end
  static const Color mapCurrentPosition = primary; // Blue for current location
  static const Color mapMilestoneReached = Color(0xFFFFA500); // Orange for reached
  static const Color mapMilestoneUnreached = Color(0xFF637588); // Gray for unreached

  // ===== ADDITIONAL UI COLORS =====

  static const Color divider = Color(0xFF2A3F54);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color border = Color(0xFF2A3F54);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Glassmorphic overlay
  static Color get glassOverlay => Colors.white.withValues(alpha: 0.1);
  static Color get glassOverlayHover => Colors.white.withValues(alpha: 0.2);

  // Dark overlay for modals/sheets
  static Color get overlay => Colors.black.withValues(alpha: 0.5);

  // ===== PREMIUM COLORS =====

  static const Color premium = Color(0xFFFFD700); // Gold
  static const Color premiumGold = Color(0xFFFFD700); // Alias for premium
  static const Color premiumLight = Color(0xFFFFE082);

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== LEGACY COMPATIBILITY ALIASES =====
  // These maintain compatibility with existing code during design system migration

  static const Color textOnPrimary = Colors.white; // Text on primary color
  static const Color background = backgroundDark; // Default background (dark mode)
  static const Color surface = surfaceDark; // Default surface (dark mode)
  static const Color secondary = milestone; // Secondary accent color
}
