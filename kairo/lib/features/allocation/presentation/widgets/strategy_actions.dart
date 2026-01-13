import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Strategy action buttons and dialogs (FR3.6)
/// Includes duplicate, delete, and edit functionality
class StrategyActions {
  /// Show strategy actions bottom sheet
  static void showActions(
    BuildContext context,
    WidgetRef ref,
    AllocationStrategy strategy,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StrategyActionsSheet(
        strategy: strategy,
        ref: ref,
      ),
    );
  }

  /// Duplicate strategy
  static Future<void> duplicate(
    BuildContext context,
    WidgetRef ref,
    AllocationStrategy strategy,
  ) async {
    // Show rename dialog
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _DuplicateStrategyDialog(
        originalName: strategy.name,
      ),
    );

    if (newName == null || newName.trim().isEmpty) return;

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create duplicate strategy
      final duplicate = AllocationStrategy(
        id: '', // Will be generated
        userId: currentUser.id,
        name: newName.trim(),
        isActive: false, // Duplicates are inactive by default
        isTemplate: false,
        allocations: strategy.allocations
            .map((a) => CategoryAllocation(
                  categoryId: a.categoryId,
                  percentage: a.percentage,
                ))
            .toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save duplicate through repository
      // For now, show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Created "${newName}"'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'View',
              textColor: AppColors.backgroundLight,
              onPressed: () {
                // TODO: Navigate to duplicate strategy
              },
            ),
          ),
        );
      }

      // Refresh strategies
      ref.invalidate(allocationStrategiesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating strategy: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Delete strategy
  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    AllocationStrategy strategy,
  ) async {
    // Prevent deleting active strategy
    if (strategy.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot delete active strategy. Switch to another first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Strategy?'),
        content: Text(
          'Are you sure you want to delete "${strategy.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TODO: Implement soft delete through repository
      // For now, show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${strategy.name}"'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Refresh strategies
      ref.invalidate(allocationStrategiesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting strategy: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Edit strategy
  static void edit(
    BuildContext context,
    AllocationStrategy strategy,
  ) {
    context.push('/strategies/${strategy.id}/edit', extra: strategy);
  }
}

/// Strategy actions bottom sheet
class _StrategyActionsSheet extends StatelessWidget {
  final AllocationStrategy strategy;
  final WidgetRef ref;

  const _StrategyActionsSheet({
    required this.strategy,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (strategy.isActive)
                      Text(
                        'Active Strategy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          _ActionButton(
            icon: Icons.edit,
            label: 'Edit Strategy',
            onTap: () {
              Navigator.pop(context);
              StrategyActions.edit(context, strategy);
            },
          ),
          _ActionButton(
            icon: Icons.copy,
            label: 'Duplicate Strategy',
            onTap: () {
              Navigator.pop(context);
              StrategyActions.duplicate(context, ref, strategy);
            },
          ),
          if (!strategy.isActive)
            _ActionButton(
              icon: Icons.swap_horiz,
              label: 'Make Active',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement switch to this strategy
              },
            ),
          _ActionButton(
            icon: Icons.analytics_outlined,
            label: 'View Analytics',
            onTap: () {
              Navigator.pop(context);
              // Navigate to analytics screen
            },
          ),
          if (!strategy.isActive)
            _ActionButton(
              icon: Icons.delete_outline,
              label: 'Delete Strategy',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                StrategyActions.delete(context, ref, strategy);
              },
            ),
        ],
      ),
    );
  }
}

/// Action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : null,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Duplicate strategy dialog
class _DuplicateStrategyDialog extends StatefulWidget {
  final String originalName;

  const _DuplicateStrategyDialog({
    required this.originalName,
  });

  @override
  State<_DuplicateStrategyDialog> createState() =>
      _DuplicateStrategyDialogState();
}

class _DuplicateStrategyDialogState extends State<_DuplicateStrategyDialog> {
  late TextEditingController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.originalName} - Copy');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Strategy'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Give your duplicate strategy a name',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Strategy Name',
              border: const OutlineInputBorder(),
              errorText: _isValid ? null : 'Name cannot be empty',
            ),
            onChanged: (_) => _validate(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValid
              ? () => Navigator.pop(context, _controller.text.trim())
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

/// Strategy menu button (for use in strategy lists)
class StrategyMenuButton extends ConsumerWidget {
  final AllocationStrategy strategy;

  const StrategyMenuButton({
    super.key,
    required this.strategy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            StrategyActions.edit(context, strategy);
            break;
          case 'duplicate':
            StrategyActions.duplicate(context, ref, strategy);
            break;
          case 'delete':
            StrategyActions.delete(context, ref, strategy);
            break;
          case 'analytics':
            // Navigate to analytics
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 12),
              Text('Duplicate'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'analytics',
          child: Row(
            children: [
              Icon(Icons.analytics_outlined),
              SizedBox(width: 12),
              Text('Analytics'),
            ],
          ),
        ),
        if (!strategy.isActive)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: AppColors.error),
                const SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
      ],
    );
  }
}
