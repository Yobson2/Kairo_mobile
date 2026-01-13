import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';
import 'constants.dart';

/// Helper class for showing consistent snackbars throughout the app
/// Provides predefined styles for success, error, info, and warning messages
class SnackBarHelper {
  /// Shows a success snackbar (green)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error snackbar (red)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info snackbar (blue)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning snackbar (amber)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Shows a custom snackbar with specified colors
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      duration: duration,
      action: action,
    );
  }

  /// Internal method to show the snackbar
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: AppSizes.iconMedium),
            const SizedBox(width: AppSizes.paddingMedium),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: AppTextSizes.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? AppDurations.snackBarMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      action: action,
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a loading snackbar (returns ScaffoldFeatureController to dismiss later)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context,
    String message,
  ) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTextSizes.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(days: 1), // Won't auto-dismiss
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Dismisses any currently showing snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Extension on BuildContext for easier snackbar usage
extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message) {
    SnackBarHelper.showSuccess(this, message);
  }

  void showErrorSnackBar(String message) {
    SnackBarHelper.showError(this, message);
  }

  void showInfoSnackBar(String message) {
    SnackBarHelper.showInfo(this, message);
  }

  void showWarningSnackBar(String message) {
    SnackBarHelper.showWarning(this, message);
  }
}
