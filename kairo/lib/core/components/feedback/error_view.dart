import 'package:flutter/material.dart';
import 'package:kairo/core/utils/constants.dart';

/// A standardized error view component for displaying error states
/// Shows an icon, message, and optional retry button
///
/// Example:
/// ```dart
/// ErrorView(
///   message: 'Failed to load data',
///   onRetry: () => ref.invalidate(dataProvider),
/// )
/// ```
class ErrorView extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonLabel;
  final Widget? customAction;

  const ErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.retryButtonLabel,
    this.customAction,
  });

  /// Network error variant
  factory ErrorView.network({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: 'Connection Error',
      message: message ?? 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }

  /// Not found error variant
  factory ErrorView.notFound({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: 'Not Found',
      message: message ?? 'The requested resource could not be found.',
      icon: Icons.search_off,
      onRetry: onRetry,
    );
  }

  /// Permission denied variant
  factory ErrorView.permissionDenied({
    String? message,
  }) {
    return ErrorView(
      title: 'Access Denied',
      message: message ?? 'You don\'t have permission to access this resource.',
      icon: Icons.lock_outline,
    );
  }

  /// Generic error variant
  factory ErrorView.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: 'Something Went Wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Title (optional)
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
            ],

            // Error Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Retry Button or Custom Action
            if (customAction != null)
              customAction!
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(retryButtonLabel ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                    vertical: AppSizes.paddingMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact error view for inline usage (e.g., in cards)
class CompactErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSizes.paddingSmall),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}
