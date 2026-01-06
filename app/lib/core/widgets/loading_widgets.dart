import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/widgets/animated_widgets.dart';

/// Shimmer loading card for skeleton screens
class LoadingCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const LoadingCard({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = 16,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: ShimmerLoading(
        baseColor: AppColors.cardDark.withValues(alpha: 0.3),
        highlightColor: AppColors.cardDark.withValues(alpha: 0.5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Loading skeleton for list items
class LoadingListItem extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const LoadingListItem({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: ShimmerLoading(
        baseColor: AppColors.cardDark.withValues(alpha: 0.3),
        highlightColor: AppColors.cardDark.withValues(alpha: 0.5),
        child: Row(
          children: [
            // Avatar/Icon placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(width: 16),
            // Text content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton for stat cards
class LoadingStatCard extends StatelessWidget {
  const LoadingStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      baseColor: AppColors.cardDark.withValues(alpha: 0.3),
      highlightColor: AppColors.cardDark.withValues(alpha: 0.5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 32,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered loading spinner with optional message
class LoadingSpinner extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingSpinner({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulsing loading dots
class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingDots({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5
                ? (value * 2)
                : (2 - value * 2);

            return Opacity(
              opacity: opacity.clamp(0.3, 1.0),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: widget.size / 2),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color ?? AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: LoadingSpinner(message: message),
          ),
      ],
    );
  }
}
