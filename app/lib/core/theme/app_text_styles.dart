import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';

/// App text styles using Lexend font family
/// Based on designer mockups with comprehensive typography scale
class AppTextStyles {
  AppTextStyles._();

  // Base Lexend text style (used as foundation)
  static TextStyle get _baseLexend => GoogleFonts.lexend();

  // ===== DISPLAY STYLES (Extra Large Headings) =====

  static TextStyle get displayXL => _baseLexend.copyWith(
    fontSize: 84,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.04 * 84, // -0.04em tracking
    color: AppColors.textPrimaryDark,
    height: 1.0,
  );

  static TextStyle get displayLarge => _baseLexend.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 48, // -0.02em tracking
    color: AppColors.textPrimaryDark,
    height: 1.1,
  );

  static TextStyle get displayMedium => _baseLexend.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.015 * 32, // -0.015em tracking
    color: AppColors.textPrimaryDark,
    height: 1.2,
  );

  static TextStyle get displaySmall => _baseLexend.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.015 * 26,
    color: AppColors.textPrimaryDark,
    height: 1.2,
  );

  // ===== HEADING STYLES =====

  static TextStyle get h1 => _baseLexend.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
    height: 1.3,
  );

  static TextStyle get h2 => _baseLexend.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.3,
  );

  static TextStyle get h3 => _baseLexend.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.4,
  );

  static TextStyle get h4 => _baseLexend.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    height: 1.4,
  );

  // ===== BODY TEXT =====

  static TextStyle get bodyLarge => _baseLexend.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseLexend.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
    height: 1.5,
  );

  // ===== LABEL STYLES (UI Components) =====

  static TextStyle get labelLarge => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryDark,
    height: 1.4,
  );

  static TextStyle get labelMedium => _baseLexend.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryDark,
    height: 1.4,
  );

  static TextStyle get labelSmall => _baseLexend.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryDark,
    height: 1.4,
  );

  static TextStyle get caption => _baseLexend.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
    height: 1.4,
  );

  static TextStyle get overline => _baseLexend.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryDark,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // ===== BUTTON TEXT =====

  static TextStyle get buttonLarge => _baseLexend.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get buttonMedium => _baseLexend.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get buttonSmall => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ===== STATS/NUMBERS (Tabular Figures) =====

  // Hero number (during run tracking)
  static TextStyle get statsXL => _baseLexend.copyWith(
    fontSize: 84,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
    height: 1.0,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle get statsLarge => _baseLexend.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.1,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle get statsMedium => _baseLexend.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle get statsSmall => _baseLexend.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
    height: 1.3,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  // ===== SPECIALIZED STYLES =====

  // Error messages
  static TextStyle get error => _baseLexend.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.4,
  );

  // Success messages
  static TextStyle get success => _baseLexend.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    height: 1.4,
  );

  // Links
  static TextStyle get link => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: 1.4,
  );

  // Placeholder text
  static TextStyle get hint => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHintDark,
    height: 1.5,
  );

  // ===== MATERIAL 3 COMPATIBILITY =====
  // These match Material 3 naming for theme integration

  static TextStyle get headlineLarge => h1;
  static TextStyle get headlineMedium => h2;
  static TextStyle get headlineSmall => h3;

  static TextStyle get titleLarge => h4;
  static TextStyle get titleMedium => _baseLexend.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );
  static TextStyle get titleSmall => _baseLexend.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );
}
