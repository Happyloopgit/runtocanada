import 'package:flutter/material.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/animated_widgets.dart';

/// Modern primary button with glow effect
/// Uses bright blue primary color with shadow/glow
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = isOutlined
        ? Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: backgroundColor ?? AppColors.primary,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: _buildChild(backgroundColor ?? AppColors.primary),
                ),
              ),
            ),
          )
        : Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              gradient: backgroundColor == null
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: backgroundColor,
              boxShadow: isLoading || onPressed == null
                  ? null
                  : backgroundColor == null
                      ? AppColors.buttonShadow
                      : [
                          BoxShadow(
                            color: backgroundColor!.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: _buildChild(textColor ?? AppColors.textOnPrimary),
                ),
              ),
            ),
          );

    // Wrap with AnimatedTapButton for scale effect
    if (!isLoading && onPressed != null) {
      return AnimatedTapButton(
        onTap: onPressed,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.buttonMedium.copyWith(color: color),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.buttonMedium.copyWith(color: color),
    );
  }
}

/// Modern text button with Lexend typography
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;
  final double? fontSize;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.icon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: textColor ?? AppColors.primary,
                    fontSize: fontSize,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: AppTextStyles.buttonMedium.copyWith(
                color: textColor ?? AppColors.primary,
                fontSize: fontSize,
              ),
            ),
    );
  }
}

/// Modern icon button with proper sizing and animation
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final Color? backgroundColor;
  final double? backgroundSize;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.backgroundColor,
    this.backgroundSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = backgroundColor != null
        ? Container(
            width: backgroundSize ?? 48,
            height: backgroundSize ?? 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: color ?? AppColors.textPrimaryDark,
                size: size,
              ),
            ),
          )
        : IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: color ?? AppColors.textPrimaryDark,
              size: size,
            ),
          );

    // Wrap with AnimatedTapButton for scale effect
    if (onPressed != null) {
      return AnimatedTapButton(
        onTap: onPressed,
        scaleAmount: 0.9,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}

/// Social sign-in button (Google, Apple, etc.)
class SocialSignInButton extends StatelessWidget {
  final String text;
  final String assetIcon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.text,
    required this.assetIcon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading) ...[
                  Image.asset(
                    assetIcon,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                if (isLoading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimaryDark,
                      ),
                    ),
                  )
                else
                  Text(
                    text,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating action button with glow and animation
class GlowingFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const GlowingFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;

    final fabContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withValues(alpha: 0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textOnPrimary,
            size: size * 0.5,
          ),
        ),
      ),
    );

    // Wrap with AnimatedTapButton for scale effect
    if (onPressed != null) {
      return AnimatedTapButton(
        onTap: onPressed,
        scaleAmount: 0.92,
        duration: const Duration(milliseconds: 150),
        child: fabContent,
      );
    }

    return fabContent;
  }
}
