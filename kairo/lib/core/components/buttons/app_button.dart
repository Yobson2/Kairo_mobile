import 'package:flutter/material.dart';

/// A unified button component with multiple variants
/// Supports loading states, icons, and consistent styling
///
/// Variants:
/// - `AppButton.primary()` - FilledButton style (main actions)
/// - `AppButton.secondary()` - FilledButton.tonal style (secondary actions)
/// - `AppButton.outlined()` - OutlinedButton style (tertiary actions)
/// - `AppButton.text()` - TextButton style (subtle actions)
///
/// Example:
/// ```dart
/// AppButton.primary(
///   onPressed: _handleSubmit,
///   label: 'Submit',
///   isLoading: _isLoading,
///   icon: Icons.check,
/// )
/// ```
class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final _ButtonVariant _variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isFullWidth;

  const AppButton._({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    required _ButtonVariant variant,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.isFullWidth = false,
  }) : _variant = variant;

  /// Primary button - FilledButton style
  const AppButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool isFullWidth = false,
  }) : this._(
          key: key,
          onPressed: onPressed,
          label: label,
          isLoading: isLoading,
          icon: icon,
          variant: _ButtonVariant.primary,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          borderRadius: borderRadius,
          isFullWidth: isFullWidth,
        );

  /// Secondary button - FilledButton.tonal style
  const AppButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool isFullWidth = false,
  }) : this._(
          key: key,
          onPressed: onPressed,
          label: label,
          isLoading: isLoading,
          icon: icon,
          variant: _ButtonVariant.secondary,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          borderRadius: borderRadius,
          isFullWidth: isFullWidth,
        );

  /// Outlined button - OutlinedButton style
  const AppButton.outlined({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
    IconData? icon,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool isFullWidth = false,
  }) : this._(
          key: key,
          onPressed: onPressed,
          label: label,
          isLoading: isLoading,
          icon: icon,
          variant: _ButtonVariant.outlined,
          foregroundColor: foregroundColor,
          padding: padding,
          borderRadius: borderRadius,
          isFullWidth: isFullWidth,
        );

  /// Text button - TextButton style
  const AppButton.text({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
    IconData? icon,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    bool isFullWidth = false,
  }) : this._(
          key: key,
          onPressed: onPressed,
          label: label,
          isLoading: isLoading,
          icon: icon,
          variant: _ButtonVariant.text,
          foregroundColor: foregroundColor,
          padding: padding,
          isFullWidth: isFullWidth,
        );

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getLoadingColor(context),
            ),
          )
        : _buildButtonContent();

    final button = switch (_variant) {
      _ButtonVariant.primary => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: buttonChild,
        ),
      _ButtonVariant.secondary => FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: buttonChild,
        ),
      _ButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: buttonChild,
        ),
      _ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(context),
          child: buttonChild,
        ),
    };

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final baseStyle = switch (_variant) {
      _ButtonVariant.primary => FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      _ButtonVariant.secondary => FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      _ButtonVariant.outlined => OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
        ),
      _ButtonVariant.text => TextButton.styleFrom(
          foregroundColor: foregroundColor,
        ),
    };

    return baseStyle.copyWith(
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
    );
  }

  Color _getLoadingColor(BuildContext context) {
    return switch (_variant) {
      _ButtonVariant.primary => foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      _ButtonVariant.secondary => foregroundColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
      _ButtonVariant.outlined => foregroundColor ?? Theme.of(context).colorScheme.primary,
      _ButtonVariant.text => foregroundColor ?? Theme.of(context).colorScheme.primary,
    };
  }
}

enum _ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}
