import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';

/// Strategy switcher widget for quick switching between strategies
/// Provides smooth animations and confirmation dialogs (FR3.4)
class StrategySwitcher extends ConsumerStatefulWidget {
  const StrategySwitcher({super.key});

  @override
  ConsumerState<StrategySwitcher> createState() => _StrategySwitcherState();
}

class _StrategySwitcherState extends ConsumerState<StrategySwitcher> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final categoriesAsync = ref.watch(allocationCategoriesProvider);

    return strategiesAsync.when(
      data: (strategies) {
        if (strategies.isEmpty) {
          return const SizedBox.shrink();
        }

        final activeStrategy =
            strategies.firstWhere((s) => s.isActive, orElse: () => strategies.first);
        final inactiveStrategies =
            strategies.where((s) => !s.isActive).toList();

        return Column(
          children: [
            // Active strategy display
            _ActiveStrategyCard(
              strategy: activeStrategy,
              isExpanded: _isExpanded,
              onTap: () {
                if (inactiveStrategies.isNotEmpty) {
                  setState(() => _isExpanded = !_isExpanded);
                }
              },
            ),

            // Expanded list of inactive strategies
            if (_isExpanded)
              categoriesAsync.when(
                data: (categories) {
                  return _StrategyList(
                    strategies: inactiveStrategies,
                    categories: categories,
                    onStrategySelected: (strategy) {
                      _confirmSwitch(context, strategy);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading strategies: $e'),
        ),
      ),
    );
  }

  Future<void> _confirmSwitch(
      BuildContext context, AllocationStrategy newStrategy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Strategy?'),
        content: Text(
          'Switch to "${newStrategy.name}"? This will become your active allocation strategy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _switchStrategy(newStrategy);
    }
  }

  Future<void> _switchStrategy(AllocationStrategy newStrategy) async {
    try {
      // TODO: Implement strategy switch through repository
      // For now, show success message
      setState(() => _isExpanded = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Switched to "${newStrategy.name}"'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.backgroundLight,
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      }

      // Refresh strategies
      ref.invalidate(allocationStrategiesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching strategy: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Active strategy card
class _ActiveStrategyCard extends StatelessWidget {
  final AllocationStrategy strategy;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ActiveStrategyCard({
    required this.strategy,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Strategy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strategy.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${strategy.allocations.length} categories allocated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Strategy list (inactive strategies)
class _StrategyList extends StatelessWidget {
  final List<AllocationStrategy> strategies;
  final List<AllocationCategory> categories;
  final Function(AllocationStrategy) onStrategySelected;

  const _StrategyList({
    required this.strategies,
    required this.categories,
    required this.onStrategySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: strategies.map((strategy) {
          return _StrategyListItem(
            strategy: strategy,
            categories: categories,
            onTap: () => onStrategySelected(strategy),
          );
        }).toList(),
      ),
    );
  }
}

/// Strategy list item
class _StrategyListItem extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<AllocationCategory> categories;
  final VoidCallback onTap;

  const _StrategyListItem({
    required this.strategy,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    _AllocationPreview(
                      strategy: strategy,
                      categories: categories,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

/// Allocation preview (mini bar chart)
class _AllocationPreview extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<AllocationCategory> categories;

  const _AllocationPreview({
    required this.strategy,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // Show top 3 allocations
    final sortedAllocations = [...strategy.allocations]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    final topAllocations = sortedAllocations.take(3).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: topAllocations.map((allocation) {
        final category = categories.firstWhere(
          (c) => c.id == allocation.categoryId,
          orElse: () => categories.first,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _parseColor(category.color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _parseColor(category.color).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${category.name}: ${allocation.percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return AppColors.fromHex(colorHex);
    } catch (e) {
      return AppColors.neutral500;
    }
  }
}

/// Bottom sheet strategy switcher (alternative compact view)
class StrategyBottomSheet extends ConsumerWidget {
  const StrategyBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final categoriesAsync = ref.watch(allocationCategoriesProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Text(
            'Switch Strategy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which allocation strategy to use',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
          const SizedBox(height: 24),

          // Strategy list
          strategiesAsync.when(
            data: (strategies) {
              return categoriesAsync.when(
                data: (categories) {
                  return Column(
                    children: strategies.map((strategy) {
                      return _BottomSheetStrategyItem(
                        strategy: strategy,
                        categories: categories,
                        onTap: () {
                          Navigator.pop(context);
                          // Switch strategy
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet strategy item
class _BottomSheetStrategyItem extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<AllocationCategory> categories;
  final VoidCallback onTap;

  const _BottomSheetStrategyItem({
    required this.strategy,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        strategy.isActive ? Icons.check_circle : Icons.circle_outlined,
        color: strategy.isActive
            ? Theme.of(context).colorScheme.primary
            : AppColors.neutral500,
      ),
      title: Text(
        strategy.name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight:
                  strategy.isActive ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      subtitle: Text(
        '${strategy.allocations.length} categories',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: strategy.isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )
          : null,
      onTap: strategy.isActive ? null : onTap,
    );
  }
}

/// Show strategy switcher bottom sheet
void showStrategySwitcher(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.overlayHeavy,
    builder: (context) => const StrategyBottomSheet(),
  );
}
