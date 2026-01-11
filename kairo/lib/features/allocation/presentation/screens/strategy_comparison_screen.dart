import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';

/// Strategy comparison screen
/// Allows users to compare multiple strategies side-by-side (FR3.4)
class StrategyComparisonScreen extends ConsumerStatefulWidget {
  final List<String> strategyIds;

  const StrategyComparisonScreen({
    super.key,
    required this.strategyIds,
  });

  @override
  ConsumerState<StrategyComparisonScreen> createState() =>
      _StrategyComparisonScreenState();
}

class _StrategyComparisonScreenState
    extends ConsumerState<StrategyComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final categoriesAsync = ref.watch(allocationCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Strategies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showComparisonHelp(context);
            },
            tooltip: 'How to compare',
          ),
        ],
      ),
      body: strategiesAsync.when(
        data: (allStrategies) {
          final strategies = allStrategies
              .where((s) => widget.strategyIds.contains(s.id))
              .toList();

          if (strategies.isEmpty) {
            return _EmptyState();
          }

          return categoriesAsync.when(
            data: (categories) {
              return _ComparisonView(
                strategies: strategies,
                categories: categories,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: e.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: e.toString()),
      ),
    );
  }

  void _showComparisonHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Compare'),
        content: const Text(
          'Compare strategies to see:\n\n'
          '• Different allocation percentages\n'
          '• Impact on your money with your current income\n'
          '• Which strategy gives you more in key areas\n\n'
          'Green highlights show the highest allocation for each category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Comparison view widget
class _ComparisonView extends StatelessWidget {
  final List<AllocationStrategy> strategies;
  final List<AllocationCategory> categories;

  const _ComparisonView({
    required this.strategies,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // Get all unique categories across all strategies
    final allCategoryIds = <String>{};
    for (final strategy in strategies) {
      allCategoryIds.addAll(strategy.allocations.map((a) => a.categoryId));
    }

    final comparisonCategories = categories
        .where((c) => allCategoryIds.contains(c.id))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Comparing ${strategies.length} Strategies',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'See how allocations differ across strategies',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Strategy headers
          _StrategyHeaders(strategies: strategies),

          const SizedBox(height: 16),

          // Category comparisons
          ...comparisonCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryComparisonRow(
                category: category,
                strategies: strategies,
              ),
            );
          }),

          const SizedBox(height: 24),

          // Total row
          _TotalRow(strategies: strategies),

          const SizedBox(height: 24),

          // Insights
          _ComparisonInsights(
            strategies: strategies,
            categories: comparisonCategories,
          ),
        ],
      ),
    );
  }
}

/// Strategy headers row
class _StrategyHeaders extends StatelessWidget {
  final List<AllocationStrategy> strategies;

  const _StrategyHeaders({required this.strategies});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 120), // Space for category names
        ...strategies.map((strategy) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: strategy.isActive
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    strategy.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (strategy.isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Category comparison row
class _CategoryComparisonRow extends StatelessWidget {
  final AllocationCategory category;
  final List<AllocationStrategy> strategies;

  const _CategoryComparisonRow({
    required this.category,
    required this.strategies,
  });

  @override
  Widget build(BuildContext context) {
    // Get percentages for this category across all strategies
    final percentages = strategies.map((strategy) {
      try {
        return strategy.allocations
            .firstWhere((a) => a.categoryId == category.id)
            .percentage;
      } catch (e) {
        return 0.0;
      }
    }).toList();

    final maxPercentage =
        percentages.isEmpty ? 0.0 : percentages.reduce((a, b) => a > b ? a : b);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Category name
            SizedBox(
              width: 120,
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            // Percentages
            ...percentages.asMap().entries.map((entry) {
              final index = entry.key;
              final percentage = entry.value;
              final isHighest = percentage == maxPercentage && percentage > 0;

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighest
                        ? Colors.green.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    border: isHighest
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isHighest ? Colors.green : null,
                                ),
                      ),
                      if (isHighest)
                        const Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Total row
class _TotalRow extends StatelessWidget {
  final List<AllocationStrategy> strategies;

  const _TotalRow({required this.strategies});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...strategies.map((strategy) {
              final total = strategy.totalPercentage;
              final isValid = (total - 100).abs() < 0.1;

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${total.toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isValid ? Colors.green : Colors.red,
                                ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isValid ? Icons.check_circle : Icons.warning,
                        size: 20,
                        color: isValid ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Comparison insights
class _ComparisonInsights extends StatelessWidget {
  final List<AllocationStrategy> strategies;
  final List<AllocationCategory> categories;

  const _ComparisonInsights({
    required this.strategies,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Differences',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> _generateInsights() {
    final insights = <String>[];

    if (strategies.length < 2) return insights;

    // Find biggest differences
    for (final category in categories) {
      final percentages = strategies.map((strategy) {
        try {
          return strategy.allocations
              .firstWhere((a) => a.categoryId == category.id)
              .percentage;
        } catch (e) {
          return 0.0;
        }
      }).toList();

      if (percentages.isEmpty) continue;

      final max = percentages.reduce((a, b) => a > b ? a : b);
      final min = percentages.reduce((a, b) => a < b ? a : b);
      final difference = max - min;

      if (difference >= 15) {
        final maxIndex = percentages.indexOf(max);
        final minIndex = percentages.indexOf(min);

        insights.add(
          '${strategies[maxIndex].name} allocates ${difference.toStringAsFixed(0)}% more to ${category.name} than ${strategies[minIndex].name}',
        );
      }
    }

    return insights.take(3).toList();
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Strategies to Compare',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create at least 2 strategies to compare them',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Error Loading Strategies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
