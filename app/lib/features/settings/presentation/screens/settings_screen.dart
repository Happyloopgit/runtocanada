import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/services/mapbox_service.dart';
import 'package:run_to_canada/features/auth/presentation/providers/auth_providers.dart';
import 'package:run_to_canada/features/settings/presentation/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
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
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
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
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
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
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Preferences Section
          _SectionHeader(title: 'Preferences'),

          // Unit Preference
          SwitchListTile(
            title: const Text('Use Metric Units'),
            subtitle: Text(
              settings.useMetric
                  ? 'Kilometers and meters'
                  : 'Miles and feet',
            ),
            value: settings.useMetric,
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier).setUseMetricUnits(value);
            },
            activeTrackColor: AppColors.primary,
          ),

          const Divider(height: 1),

          // Map Style Preference
          ListTile(
            title: const Text('Default Map Style'),
            subtitle: Text(_getMapStyleName(currentMapStyle)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMapStylePicker(context, ref, currentMapStyle),
          ),

          const Divider(height: 1),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),

          SwitchListTile(
            title: const Text('Milestone Notifications'),
            subtitle: const Text('Get notified when you reach milestones'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier).setNotificationsEnabled(value);
            },
            activeTrackColor: AppColors.primary,
          ),

          const Divider(height: 1),

          // Account Section
          _SectionHeader(title: 'Account'),

          ListTile(
            leading: Icon(Icons.logout, color: AppColors.primary),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context, ref),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          const Divider(height: 1),

          // App Info Section
          _SectionHeader(title: 'About'),

          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),

          const Divider(height: 1),

          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open privacy policy URL
            },
          ),

          const Divider(height: 1),

          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open terms of service URL
            },
          ),

          const SizedBox(height: 32),
        ],
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Default Map Style',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...MapStyle.values.map((style) => ListTile(
            title: Text(_getMapStyleName(style)),
            trailing: currentStyle == style
                ? Icon(Icons.check, color: AppColors.primary)
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
