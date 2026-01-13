import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/screens/edit_strategy_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/create_strategy_screen.dart';

/// Screen for managing multiple allocation strategies (FR9)
class StrategiesScreen extends ConsumerWidget {
  const StrategiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final activeStrategyAsync = ref.watch(activeStrategyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Strategies'),
        centerTitle: true,
      ),
      body: strategiesAsync.when(
        data: (strategies) {
          return activeStrategyAsync.when(
            data: (activeStrategy) => _buildStrategiesList(
              context,
              ref,
              strategies,
              activeStrategy,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context, error.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateStrategyScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Strategy'),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load strategies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategiesList(
    BuildContext context,
    WidgetRef ref,
    List<AllocationStrategy> strategies,
    AllocationStrategy? activeStrategy,
  ) {
    if (strategies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: 16),
              Text(
                'No strategies yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first allocation strategy to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        final strategy = strategies[index];
        final isActive = activeStrategy?.id == strategy.id;

        return _StrategyCard(
          strategy: strategy,
          isActive: isActive,
          onActivate: () async {
            await ref
                .read(allocationRepositoryProvider)
                .setActiveStrategy(strategy.id);
            ref.invalidate(activeStrategyProvider);
            ref.invalidate(allocationStrategiesProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Activated "${strategy.name}"'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditStrategyScreen(strategy: strategy),
              ),
            );
          },
          onDelete: () {
            _confirmDeleteStrategy(context, ref, strategy, isActive);
          },
        );
      },
    );
  }

  void _confirmDeleteStrategy(
    BuildContext context,
    WidgetRef ref,
    AllocationStrategy strategy,
    bool isActive,
  ) {
    if (isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the active strategy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Strategy'),
        content: Text(
          'Are you sure you want to delete "${strategy.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(allocationRepositoryProvider)
                  .deleteStrategy(strategy.id);
              ref.invalidate(allocationStrategiesProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${strategy.name} deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final AllocationStrategy strategy;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StrategyCard({
    required this.strategy,
    required this.isActive,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strategy.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strategy.isTemplate
                            ? 'Template strategy'
                            : 'Custom strategy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral600,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'activate':
                        onActivate();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text('Set as Active'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Allocation Breakdown',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...strategy.allocations.map((allocation) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category ${allocation.categoryId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${allocation.percentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${strategy.totalPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: strategy.isValid ? AppColors.success : AppColors.error,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
