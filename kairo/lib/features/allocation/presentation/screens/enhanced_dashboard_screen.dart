import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/widgets/allocation_donut_chart.dart';
import 'package:kairo/features/allocation/presentation/widgets/variable_income_guidance.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Enhanced dashboard with visualizations and variable income guidance (Phase 2)
class EnhancedDashboardScreen extends ConsumerWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentUserProvider);
    final categoriesAsync = ref.watch(allocationCategoriesProvider);
    final strategiesAsync = ref.watch(allocationStrategiesProvider);
    final incomeHistoryAsync = ref.watch(incomeEntriesProvider(limit: 10));
    final latestIncomeAsync = ref.watch(latestIncomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/dashboard/income/history'),
            tooltip: 'Income History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allocationCategoriesProvider);
          ref.invalidate(allocationStrategiesProvider);
          ref.invalidate(incomeEntriesProvider);
          ref.invalidate(latestIncomeProvider);
        },
        child: authState.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Please sign in'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome header
                  _WelcomeHeader(userName: user.email?.split('@')[0] ?? 'User'),

                  const SizedBox(height: 24),

                  // Latest income summary card
                  latestIncomeAsync.when(
                    data: (latestIncome) {
                      if (latestIncome != null) {
                        return _LatestIncomeSummary(income: latestIncome);
                      }
                      return _EmptyStateCard(
                        icon: Icons.add_circle_outline,
                        title: 'Add Your First Income',
                        message: 'Track your income to see allocation breakdown',
                        actionLabel: 'Add Income',
                        onAction: () => context.push('/dashboard/income/new'),
                      );
                    },
                    loading: () => const _LoadingCard(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),

                  const SizedBox(height: 24),

                  // Variable income guidance
                  incomeHistoryAsync.when(
                    data: (incomeHistory) {
                      if (incomeHistory.isNotEmpty) {
                        final latestIncome = incomeHistory.first;
                        return VariableIncomeGuidance(
                          incomeHistory: incomeHistory,
                          currentIncomeType: latestIncome.incomeType,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Allocation visualization
                  categoriesAsync.when(
                    data: (categories) {
                      return strategiesAsync.when(
                        data: (strategies) {
                          final activeStrategy = strategies.where((s) => s.isActive).firstOrNull;

                          if (activeStrategy != null && categories.isNotEmpty) {
                            return latestIncomeAsync.when(
                              data: (latestIncome) {
                                if (latestIncome != null) {
                                  return _AllocationVisualization(
                                    strategy: activeStrategy,
                                    categories: categories,
                                    totalAmount: latestIncome.amount,
                                    currency: latestIncome.currency,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          }

                          return _EmptyStateCard(
                            icon: Icons.pie_chart_outline,
                            title: 'No Active Strategy',
                            message: 'Create your first allocation strategy',
                            actionLabel: 'Create Strategy',
                            onAction: () => context.push('/strategies/new'),
                          );
                        },
                        loading: () => const _LoadingCard(),
                        error: (e, _) => _ErrorCard(message: e.toString()),
                      );
                    },
                    loading: () => const _LoadingCard(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),

                  const SizedBox(height: 24),

                  // Quick actions
                  _QuickActionsGrid(),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/income/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
    );
  }
}

/// Welcome header widget
class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your money has a plan',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Latest income summary card
class _LatestIncomeSummary extends StatelessWidget {
  final IncomeEntry income;

  const _LatestIncomeSummary({required this.income});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Income',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getIncomeTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getIncomeTypeLabel(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getIncomeTypeColor(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  _getCurrencySymbol(income.currency),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  income.amount.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Received on ${_formatDate(income.incomeDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIncomeTypeColor() {
    switch (income.incomeType) {
      case IncomeType.fixed:
        return Colors.green;
      case IncomeType.variable:
        return Colors.orange;
      case IncomeType.mixed:
        return Colors.blue;
    }
  }

  String _getIncomeTypeLabel() {
    switch (income.incomeType) {
      case IncomeType.fixed:
        return 'Fixed';
      case IncomeType.variable:
        return 'Variable';
      case IncomeType.mixed:
        return 'Mixed';
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KSh';
      case 'NGN':
        return '₦';
      case 'GHS':
        return 'GH₵';
      case 'ZAR':
        return 'R';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Allocation visualization section
class _AllocationVisualization extends StatelessWidget {
  final dynamic strategy;
  final List<dynamic> categories;
  final double totalAmount;
  final String currency;

  const _AllocationVisualization({
    required this.strategy,
    required this.categories,
    required this.totalAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final allocations = strategy.allocations.map<AllocationCategoryData>((alloc) {
      final category = categories.firstWhere(
        (c) => c.id == alloc.categoryId,
        orElse: () => categories.first,
      );

      return AllocationCategoryData(
        category: category,
        percentage: alloc.percentage,
        amount: totalAmount * (alloc.percentage / 100),
        color: _parseColor(category.color),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Allocation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to temporary allocation screen
                  },
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('This Month is Different'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AllocationDonutChart(
              allocations: allocations,
              totalAmount: totalAmount,
              currency: currency,
              size: 180,
            ),
          ],
        ),
      ),
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

/// Quick actions grid
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _QuickActionCard(
              icon: Icons.category,
              label: 'Categories',
              color: Colors.purple,
              onTap: () => context.push('/categories'),
            ),
            _QuickActionCard(
              icon: Icons.layers,
              label: 'Strategies',
              color: Colors.blue,
              onTap: () => context.push('/strategies'),
            ),
            _QuickActionCard(
              icon: Icons.history,
              label: 'Income History',
              color: Colors.green,
              onTap: () => context.push('/dashboard/income/history'),
            ),
            _QuickActionCard(
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.grey,
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Quick action card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state card
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading card
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Error card
class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
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
