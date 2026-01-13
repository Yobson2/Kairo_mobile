import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/constants.dart';

/// A standardized empty state component for displaying "no data" states
/// Shows an icon, message, and optional action button
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No Categories',
///   message: 'You haven\'t created any categories yet',
///   actionLabel: 'Add Category',
///   onAction: () => _showAddCategoryDialog(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.iconColor,
  });

  /// No items variant - generic empty list
  factory EmptyState.noItems({
    required String itemName,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No $itemName',
      message: 'You haven\'t added any $itemName yet.',
      actionLabel: actionLabel ?? 'Add $itemName',
      onAction: onAction,
    );
  }

  /// No results variant - for search/filter
  factory EmptyState.noResults({
    String? query,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: query != null
          ? 'No results found for "$query".\nTry different search terms.'
          : 'No results match your filters.\nTry adjusting your criteria.',
      actionLabel: onClear != null ? 'Clear Filters' : null,
      onAction: onClear,
    );
  }

  /// No data variant - for empty data sets
  factory EmptyState.noData({
    required String dataType,
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      icon: Icons.folder_outlined,
      title: 'No $dataType',
      message: message ?? 'No $dataType available at the moment.',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }

  /// Coming soon variant
  factory EmptyState.comingSoon({
    required String featureName,
  }) {
    return EmptyState(
      icon: Icons.construction_outlined,
      title: 'Coming Soon',
      message: '$featureName will be available in a future update.',
      iconColor: AppColors.warning,
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
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.neutral400).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSmall),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Action Button or Custom Action
            if (customAction != null)
              customAction!
            else if (onAction != null && actionLabel != null)
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
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

/// Compact empty state for inline usage (e.g., in list sections)
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.neutral400,
            ),
            const SizedBox(width: AppSizes.paddingSmall),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
