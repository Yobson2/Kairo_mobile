import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';

/// Screen for editing an existing allocation strategy (Story 4.4)
class EditStrategyScreen extends ConsumerStatefulWidget {
  final AllocationStrategy strategy;

  const EditStrategyScreen({
    super.key,
    required this.strategy,
  });

  @override
  ConsumerState<EditStrategyScreen> createState() => _EditStrategyScreenState();
}

class _EditStrategyScreenState extends ConsumerState<EditStrategyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _strategyNameController;
  late final TextEditingController _incomeController;
  late double _incomeAmount;
  late IncomeType _selectedIncomeType;
  late IncomeSource _selectedIncomeSource; // FR13
  late Map<String, double> _allocations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _strategyNameController = TextEditingController(text: widget.strategy.name);
    _incomeController = TextEditingController();
    _incomeAmount = 0.0;
    _selectedIncomeType = IncomeType.variable;
    _selectedIncomeSource = IncomeSource.cash; // FR13

    // Initialize allocations from strategy
    _allocations = {};
  }

  @override
  void dispose() {
    _strategyNameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  double get _totalPercentage {
    return _allocations.values.fold(0.0, (sum, item) => sum + item);
  }

  void _updateAllocation(String categoryId, double newPercentage) {
    setState(() {
      _allocations[categoryId] = newPercentage;
    });
  }

  Future<void> _updateStrategy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create updated category allocations
      final categoryAllocations = <CategoryAllocation>[];
      for (final entry in _allocations.entries) {
        categoryAllocations.add(
          CategoryAllocation(
            categoryId: entry.key,
            percentage: entry.value,
          ),
        );
      }

      // Create updated strategy
      final updatedStrategy = widget.strategy.copyWith(
        name: _strategyNameController.text.trim(),
        allocations: categoryAllocations,
        updatedAt: DateTime.now(),
      );

      // Update via repository
      final repository = ref.read(allocationRepositoryProvider);
      await repository.updateStrategy(updatedStrategy);

      // If income was entered, create a new income entry
      if (_incomeAmount > 0) {
        final income = IncomeEntry(
          id: '',
          userId: widget.strategy.userId,
          amount: _incomeAmount,
          currency: 'KES', // Default currency
          incomeDate: DateTime.now(),
          incomeType: _selectedIncomeType,
          incomeSource: _selectedIncomeSource,
          description: 'Income for ${updatedStrategy.name}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(saveAllocationProvider.notifier).execute(
              income: income,
              strategy: updatedStrategy,
            );
      }

      // Invalidate providers to refresh data
      ref.invalidate(allocationStrategiesProvider);
      ref.invalidate(activeStrategyProvider);
      ref.invalidate(allocationSummaryProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Strategy "${updatedStrategy.name}" updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allocationCategoriesProvider);
    final remainingPercentage = 100 - _totalPercentage;
    final isValid = remainingPercentage.abs() < 0.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Strategy'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          // Initialize allocations on first build
          if (_allocations.isEmpty) {
            for (final allocation in widget.strategy.allocations) {
              _allocations[allocation.categoryId] = allocation.percentage;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Strategy Info Card
                  Card(
                    color: widget.strategy.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.info.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            widget.strategy.isActive
                                ? Icons.check_circle
                                : Icons.edit,
                            color: widget.strategy.isActive
                                ? AppColors.success
                                : AppColors.info,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.strategy.isActive
                                  ? 'This is your active strategy'
                                  : 'Editing saved strategy',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Strategy Name
                  Text(
                    'Strategy Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _strategyNameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Regular Month, Tight Month, Bonus Month',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a strategy name';
                      }
                      if (value.trim().length > 50) {
                        return 'Name must be 50 characters or less';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Optional: New Income Entry
                  Text(
                    'New Income Entry (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter income to create a new allocation with this strategy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _incomeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Enter amount (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _incomeAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Income Type
                  Text(
                    'Income Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<IncomeType>(
                    segments: const [
                      ButtonSegment(
                        value: IncomeType.fixed,
                        label: Text('Fixed'),
                        icon: Icon(Icons.calendar_today, size: 16),
                      ),
                      ButtonSegment(
                        value: IncomeType.variable,
                        label: Text('Variable'),
                        icon: Icon(Icons.trending_up, size: 16),
                      ),
                      ButtonSegment(
                        value: IncomeType.mixed,
                        label: Text('Mixed'),
                        icon: Icon(Icons.shuffle, size: 16),
                      ),
                    ],
                    selected: {_selectedIncomeType},
                    onSelectionChanged: _isLoading
                        ? null
                        : (Set<IncomeType> selected) {
                            setState(() => _selectedIncomeType = selected.first);
                          },
                  ),
                  const SizedBox(height: 24),

                  // Income Source (FR13)
                  Text(
                    'Income Source',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<IncomeSource>(
                    value: _selectedIncomeSource,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: IncomeSource.values.map((source) {
                      return DropdownMenuItem(
                        value: source,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              source.label,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              source.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (IncomeSource? source) {
                            if (source != null) {
                              setState(() => _selectedIncomeSource = source);
                            }
                          },
                  ),
                  const SizedBox(height: 24),

                  // Allocation Sliders
                  Text(
                    'Allocation Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),

                  ...categories.map((category) {
                    final percentage = _allocations[category.id] ?? 0.0;
                    final amount = _incomeAmount * (percentage / 100);
                    final color = AppColors.fromHex(category.color);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                _incomeAmount > 0
                                    ? '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)'
                                    : '${percentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Slider(
                            value: percentage,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            activeColor: color,
                            onChanged: _isLoading
                                ? null
                                : (value) => _updateAllocation(category.id, value),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Total Indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isValid ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isValid ? AppColors.success : AppColors.warning,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Allocated',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${_totalPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isValid ? AppColors.success : AppColors.warning,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      remainingPercentage > 0
                          ? 'You have ${remainingPercentage.toStringAsFixed(1)}% remaining'
                          : 'You are over by ${(-remainingPercentage).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Update Button
                  FilledButton(
                    onPressed: isValid && !_isLoading ? _updateStrategy : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                            ),
                          )
                        : const Text(
                            'Update Strategy',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading categories: $error'),
        ),
      ),
    );
  }
}
