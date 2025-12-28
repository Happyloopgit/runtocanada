import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary Colors - Journey theme (Canada-inspired reds and whites)
  static const Color primary = Color(0xFFD32F2F); // Canadian red
  static const Color primaryLight = Color(0xFFE57373);
  static const Color primaryDark = Color(0xFFB71C1C);

  // Secondary Colors - Nature/Map theme (greens for maps)
  static const Color secondary = Color(0xFF388E3C); // Forest green
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFF1B5E20);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Map Colors
  static const Color mapRoute = Color(0xFF2196F3); // Blue for route
  static const Color mapMarker = Color(0xFFD32F2F); // Red for markers
  static const Color mapProgress = Color(0xFF4CAF50); // Green for progress

  // Chart Colors
  static const Color chartPrimary = Color(0xFFD32F2F);
  static const Color chartSecondary = Color(0xFF388E3C);
  static const Color chartTertiary = Color(0xFF2196F3);

  // Additional UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x80000000);

  // Premium Feature Colors
  static const Color premium = Color(0xFFFFD700); // Gold
  static const Color premiumLight = Color(0xFFFFE082);

  // Dark Mode Colors (for future use)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
