import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';

/// A customizable social sign-in button component
/// Supports icons, text logos, loading states, and custom branding
///
/// Example:
/// ```dart
/// SocialSignInButton(
///   onPressed: _handleGoogleSignIn,
///   isLoading: _isGoogleLoading,
///   logo: 'G',
///   label: 'Continue with Google',
///   backgroundColor: Colors.white,
///   foregroundColor: Color(0xFF1F1F1F),
///   borderColor: Color(0xFFDADCE0),
/// )
/// ```
class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String? logo; // For text-based logos like "G" for Google
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const SocialSignInButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.logo,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.padding,
    this.borderRadius,
  }) : assert(icon != null || logo != null,
            'Either icon or logo must be provided');

  /// Google Sign-In button variant
  factory SocialSignInButton.google({
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SocialSignInButton(
      onPressed: onPressed,
      isLoading: isLoading,
      logo: 'G',
      label: 'Continue with Google',
      backgroundColor: AppColors.googleBackground,
      foregroundColor: AppColors.googleForeground,
      borderColor: AppColors.googleBorder,
    );
  }

  /// Apple Sign-In button variant
  factory SocialSignInButton.apple({
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SocialSignInButton(
      onPressed: onPressed,
      isLoading: isLoading,
      icon: Icons.apple,
      label: 'Continue with Apple',
      backgroundColor: AppColors.appleBackground,
      foregroundColor: AppColors.appleForeground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: elevation ?? (borderColor != null ? 0 : 1),
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show either icon or text logo
                if (icon != null)
                  Icon(icon, size: 22)
                else if (logo != null)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: foregroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      logo!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
    );
  }
}
