import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/glass_card.dart';

/// Immersive map card for home dashboard
///
/// Features:
/// - 4:3 aspect ratio map display
/// - Gradient overlay for readability
/// - "Live Tracking" and day badge
/// - "Currently near [city]" badge
/// - Tap to view full journey
class JourneyMapCard extends StatelessWidget {
  final String? currentCity;
  final int dayNumber;
  final VoidCallback? onTap;
  final Widget mapWidget;

  const JourneyMapCard({
    super.key,
    this.currentCity,
    required this.dayNumber,
    this.onTap,
    required this.mapWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Map background
              mapWidget,

              // Gradient overlay (top to make badges readable)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Top badges row
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Live Tracking badge
                    _Badge(
                      icon: Icons.radio_button_checked,
                      label: 'Live Tracking',
                      color: AppColors.primary,
                      isPulsing: true,
                    ),
                    const Spacer(),
                    // Day badge
                    _Badge(
                      icon: Icons.calendar_today,
                      label: 'Day $dayNumber',
                      color: AppColors.surfaceDark,
                    ),
                  ],
                ),
              ),

              // Bottom "Currently near" badge
              if (currentCity != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    blurStrength: 10,
                    backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Currently near Journey',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge widget for map overlays
class _Badge extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isPulsing;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    this.isPulsing = false,
  });

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isPulsing) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat(reverse: true);

      _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.isPulsing) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      blurStrength: 10,
      backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: widget.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (widget.isPulsing) {
      return FadeTransition(
        opacity: _opacityAnimation,
        child: badge,
      );
    }

    return badge;
  }
}
