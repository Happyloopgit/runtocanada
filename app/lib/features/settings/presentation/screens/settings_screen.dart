import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/core/widgets/glass_card.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/settings/presentation/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          CustomTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          CustomTextButton(
            text: 'Logout',
            textColor: AppColors.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.login,
          (route) => false,
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Account',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          CustomTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          CustomTextButton(
            text: 'Delete Account',
            textColor: AppColors.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );

      try {
        final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
        await settingsNotifier.deleteAccount();

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.login,
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  MapStyle _stringToMapStyle(String style) {
    switch (style) {
      case 'streets':
        return MapStyle.streets;
      case 'outdoors':
        return MapStyle.outdoors;
      case 'light':
        return MapStyle.light;
      case 'dark':
        return MapStyle.dark;
      case 'satellite':
        return MapStyle.satellite;
      case 'satelliteStreets':
        return MapStyle.satelliteStreets;
      default:
        return MapStyle.streets;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final currentMapStyle = _stringToMapStyle(settings.mapStyle);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: CustomIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimaryDark,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 12),

              // Unit Preference Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.straighten,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Metric Units',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.useMetric
                                ? 'Kilometers and meters'
                                : 'Miles and feet',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    Switch(
                      value: settings.useMetric,
                      onChanged: (value) {
                        ref.read(settingsNotifierProvider.notifier).setUseMetricUnits(value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              // Dark Mode Toggle Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        settings.darkModeEnabled
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.darkModeEnabled
                                ? 'Enabled'
                                : 'Disabled',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    Switch(
                      value: settings.darkModeEnabled,
                      onChanged: (value) {
                        ref.read(settingsNotifierProvider.notifier).setDarkModeEnabled(value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              // Map Style Preference Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => _showMapStylePicker(context, ref, currentMapStyle),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default Map Style',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getMapStyleName(currentMapStyle),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondaryDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notifications Section
              _SectionHeader(title: 'Notifications'),
              const SizedBox(height: 12),

              // Notifications Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.milestoneGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Milestone Notifications',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get notified when you reach milestones',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                        ref.read(settingsNotifierProvider.notifier).setNotificationsEnabled(value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Section
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 12),

              // Logout Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => _showLogoutDialog(context, ref),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Text(
                        'Logout',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondaryDark,
                    ),
                  ],
                ),
              ),

              // Delete Account Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => _showDeleteAccountDialog(context, ref),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),

              // App Version Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.purple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Version',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1.0.0',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Privacy Policy Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () {
                  // TODO: Open privacy policy URL
                },
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.privacy_tip,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Icon
                    Icon(
                      Icons.open_in_new,
                      color: AppColors.textSecondaryDark,
                      size: 20,
                    ),
                  ],
                ),
              ),

              // Terms of Service Card
              SolidCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () {
                  // TODO: Open terms of service URL
                },
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Text(
                        'Terms of Service',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Icon
                    Icon(
                      Icons.open_in_new,
                      color: AppColors.textSecondaryDark,
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getMapStyleName(MapStyle style) {
    switch (style) {
      case MapStyle.streets:
        return 'Streets';
      case MapStyle.outdoors:
        return 'Outdoors';
      case MapStyle.light:
        return 'Light';
      case MapStyle.dark:
        return 'Dark';
      case MapStyle.satellite:
        return 'Satellite';
      case MapStyle.satelliteStreets:
        return 'Satellite Streets';
    }
  }

  void _showMapStylePicker(BuildContext context, WidgetRef ref, MapStyle currentStyle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Default Map Style',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),

          const Divider(height: 1),

          // Map style options
          ...MapStyle.values.map((style) => ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: currentStyle == style
                    ? AppColors.primaryGradient
                    : null,
                color: currentStyle == style
                    ? null
                    : AppColors.surfaceInput,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map,
                color: currentStyle == style
                    ? Colors.white
                    : AppColors.textSecondaryDark,
                size: 16,
              ),
            ),
            title: Text(
              _getMapStyleName(style),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: currentStyle == style
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            trailing: currentStyle == style
                ? Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).setDefaultMapStyle(style);
              Navigator.pop(context);
            },
          )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
