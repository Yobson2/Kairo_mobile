import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/utils.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/screens/category_management_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/strategies_screen.dart';

/// Dashboard screen showing allocation status and summary
/// Implements FR12: Unified dashboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(allocationSummaryProvider);
    final latestIncomeAsync = ref.watch(latestIncomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kairo Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allocationSummaryProvider);
          ref.invalidate(latestIncomeProvider);
        },
        child: summaryAsync.when(
          data: (summary) => _buildDashboard(context, summary, latestIncomeAsync),
          loading: () => const LoadingIndicator(),
          error: (error, stack) => ErrorView.generic(
            message: 'Failed to load dashboard: $error',
            onRetry: () => ref.invalidate(allocationSummaryProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to new allocation screen
        },
        icon: const Icon(Icons.add),
        label: const Text('New Allocation'),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    Map<String, dynamic> summary,
    AsyncValue latestIncomeAsync,
  ) {
    final latestIncome = summary['latest_income'];
    final activeStrategy = summary['active_strategy'];
    final categories = summary['categories'] as List<dynamic>?;
    final totalAllocated = summary['total_allocated_this_month'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Text(
            'Welcome to Kairo! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Here\'s your financial overview',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Latest Income Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: AppColors.success),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latest Income',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (latestIncome != null)
                              Text(
                                '\$${(latestIncome['amount'] as num).toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                              )
                            else
                              Text(
                                'No income recorded yet',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // Total Allocated This Month
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Row(
                children: [
                  const Icon(Icons.pie_chart, size: 32),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Allocated This Month',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${totalAllocated.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Active Strategy Section
          if (activeStrategy != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Active Strategy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StrategiesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeStrategy['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    // Display allocations
                    if (activeStrategy['allocations'] != null)
                      ...(activeStrategy['allocations'] as List).map((alloc) {
                        final percentage = alloc['percentage'] as num;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Category',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.paddingLarge),

          // Categories Section
          if (categories != null && categories.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ...categories.map((category) {
              final categoryColor = AppColors.fromHex(category['color'] as String);
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.category,
                      color: categoryColor,
                    ),
                  ),
                  title: Text(category['name'] as String),
                  subtitle: Text(
                    category['is_default'] as bool
                        ? 'Default category'
                        : 'Custom category',
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
