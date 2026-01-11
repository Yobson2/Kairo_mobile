import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';

/// Strategy analytics screen
/// Shows insights, trends, and performance metrics for allocation strategies (FR3.7)
class StrategyAnalyticsScreen extends ConsumerWidget {
  final String? strategyId;

  const StrategyAnalyticsScreen({
    super.key,
    this.strategyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final categoriesAsync = ref.watch(allocationCategoriesProvider);
    final incomeHistoryAsync = ref.watch(incomeEntriesProvider(limit: 30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Analytics'),
      ),
      body: strategiesAsync.when(
        data: (strategies) {
          final strategy = strategyId != null
              ? strategies.firstWhere((s) => s.id == strategyId,
                  orElse: () => strategies.first)
              : strategies.firstWhere((s) => s.isActive,
                  orElse: () => strategies.first);

          return categoriesAsync.when(
            data: (categories) {
              return incomeHistoryAsync.when(
                data: (incomeHistory) {
                  return _AnalyticsView(
                    strategy: strategy,
                    categories: categories,
                    incomeHistory: incomeHistory,
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(message: e.toString()),
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
}

/// Analytics view
class _AnalyticsView extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<AllocationCategory> categories;
  final List<IncomeEntry> incomeHistory;

  const _AnalyticsView({
    required this.strategy,
    required this.categories,
    required this.incomeHistory,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();
    final trends = _calculateTrends();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            strategy.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (strategy.isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              Text(
                'Created ${_formatDate(strategy.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Key metrics
          _KeyMetrics(
            strategy: strategy,
            incomeHistory: incomeHistory,
            categories: categories,
          ),

          const SizedBox(height: 24),

          // Allocation breakdown
          _AllocationBreakdown(
            strategy: strategy,
            categories: categories,
          ),

          const SizedBox(height: 24),

          // Insights
          if (insights.isNotEmpty) ...[
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => _InsightCard(insight: insight)),
          ],

          const SizedBox(height: 24),

          // Trends (if income history available)
          if (incomeHistory.isNotEmpty) ...[
            Text(
              'Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...trends.map((trend) => _TrendCard(trend: trend)),
          ],
        ],
      ),
    );
  }

  List<StrategyInsight> _generateInsights() {
    final insights = <StrategyInsight>[];

    // Check for imbalanced allocations
    final maxAllocation = strategy.allocations
        .map((a) => a.percentage)
        .reduce((a, b) => a > b ? a : b);
    if (maxAllocation > 50) {
      final category = categories.firstWhere(
        (c) =>
            c.id ==
            strategy.allocations
                .firstWhere((a) => a.percentage == maxAllocation)
                .categoryId,
        orElse: () => categories.first,
      );

      insights.add(StrategyInsight(
        type: InsightType.warning,
        title: 'High Concentration',
        message:
            '${maxAllocation.toStringAsFixed(0)}% allocated to ${category.name}. Consider diversifying.',
        icon: Icons.warning_amber,
        color: Colors.orange,
      ));
    }

    // Check emergency fund allocation
    final emergencyCategory = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('emergency'),
      orElse: () => categories.first,
    );
    final emergencyAllocation = strategy.allocations
        .where((a) => a.categoryId == emergencyCategory.id)
        .firstOrNull
        ?.percentage ??
        0;

    if (emergencyAllocation < 10) {
      insights.add(StrategyInsight(
        type: InsightType.suggestion,
        title: 'Low Emergency Buffer',
        message:
            'Only ${emergencyAllocation.toStringAsFixed(0)}% for emergencies. Consider increasing to 15-20%.',
        icon: Icons.shield_outlined,
        color: Colors.blue,
      ));
    } else if (emergencyAllocation >= 20) {
      insights.add(StrategyInsight(
        type: InsightType.positive,
        title: 'Strong Emergency Fund',
        message:
            'Great! ${emergencyAllocation.toStringAsFixed(0)}% emergency buffer provides good protection.',
        icon: Icons.check_circle,
        color: Colors.green,
      ));
    }

    // Check savings allocation
    final savingsCategory = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('saving'),
      orElse: () => categories.first,
    );
    final savingsAllocation = strategy.allocations
        .where((a) => a.categoryId == savingsCategory.id)
        .firstOrNull
        ?.percentage ??
        0;

    if (savingsAllocation >= 25) {
      insights.add(StrategyInsight(
        type: InsightType.positive,
        title: 'Excellent Savings Rate',
        message:
            '${savingsAllocation.toStringAsFixed(0)}% to savings will build wealth quickly!',
        icon: Icons.trending_up,
        color: Colors.green,
      ));
    }

    // Check for variable income suitability
    if (incomeHistory.length >= 3) {
      final hasVariableIncome = incomeHistory
          .any((e) => e.incomeType == IncomeType.variable);

      if (hasVariableIncome && emergencyAllocation < 20) {
        insights.add(StrategyInsight(
          type: InsightType.important,
          title: 'Variable Income Detected',
          message:
              'With variable income, consider 20-30% emergency allocation for stability.',
          icon: Icons.trending_up,
          color: Colors.orange,
        ));
      }
    }

    return insights;
  }

  List<StrategyTrend> _calculateTrends() {
    final trends = <StrategyTrend>[];

    if (incomeHistory.length < 3) return trends;

    // Calculate average income
    final avgIncome = incomeHistory
        .map((e) => e.amount)
        .reduce((a, b) => a + b) / incomeHistory.length;

    // Income trend
    final recentIncome = incomeHistory.take(3).toList();
    final isIncreasing = recentIncome[0].amount > recentIncome[1].amount &&
        recentIncome[1].amount > recentIncome[2].amount;
    final isDecreasing = recentIncome[0].amount < recentIncome[1].amount &&
        recentIncome[1].amount < recentIncome[2].amount;

    if (isIncreasing) {
      trends.add(StrategyTrend(
        title: 'Income Growing',
        message:
            'Your income has increased for 3 months. Consider increasing savings allocation.',
        direction: TrendDirection.up,
        color: Colors.green,
      ));
    } else if (isDecreasing) {
      trends.add(StrategyTrend(
        title: 'Income Declining',
        message:
            'Income has dropped recently. Ensure your emergency fund is strong.',
        direction: TrendDirection.down,
        color: Colors.orange,
      ));
    }

    return trends;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Key metrics cards
class _KeyMetrics extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<IncomeEntry> incomeHistory;
  final List<AllocationCategory> categories;

  const _KeyMetrics({
    required this.strategy,
    required this.incomeHistory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final latestIncome =
        incomeHistory.isNotEmpty ? incomeHistory.first.amount : 0.0;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Categories',
            value: strategy.allocations.length.toString(),
            icon: Icons.category,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Total %',
            value: '${strategy.totalPercentage.toStringAsFixed(0)}%',
            icon: Icons.pie_chart,
            color: strategy.isValid ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Income Entries',
            value: incomeHistory.length.toString(),
            icon: Icons.attach_money,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

/// Metric card
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

/// Allocation breakdown
class _AllocationBreakdown extends StatelessWidget {
  final AllocationStrategy strategy;
  final List<AllocationCategory> categories;

  const _AllocationBreakdown({
    required this.strategy,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final sortedAllocations = [...strategy.allocations]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allocation Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...sortedAllocations.map((allocation) {
          final category = categories.firstWhere(
            (c) => c.id == allocation.categoryId,
            orElse: () => categories.first,
          );

          return _AllocationBar(
            categoryName: category.name,
            percentage: allocation.percentage,
            color: _parseColor(category.color),
          );
        }),
      ],
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// Allocation bar
class _AllocationBar extends StatelessWidget {
  final String categoryName;
  final double percentage;
  final Color color;

  const _AllocationBar({
    required this.categoryName,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }
}

/// Insight card
class _InsightCard extends StatelessWidget {
  final StrategyInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: insight.color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(insight.icon, color: insight.color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend card
class _TrendCard extends StatelessWidget {
  final StrategyTrend trend;

  const _TrendCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              trend.direction == TrendDirection.up
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: trend.color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trend.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trend.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
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
              'Error Loading Analytics',
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

// ============================================================================
// Data Models
// ============================================================================

enum InsightType { positive, suggestion, warning, important }

enum TrendDirection { up, down, stable }

class StrategyInsight {
  final InsightType type;
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  StrategyInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class StrategyTrend {
  final String title;
  final String message;
  final TrendDirection direction;
  final Color color;

  StrategyTrend({
    required this.title,
    required this.message,
    required this.direction,
    required this.color,
  });
}
