import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/widgets/strategy_template_selector.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Screen for creating a new named allocation strategy (Story 4.1)
class CreateStrategyScreen extends ConsumerStatefulWidget {
  const CreateStrategyScreen({super.key});

  @override
  ConsumerState<CreateStrategyScreen> createState() => _CreateStrategyScreenState();
}

class _CreateStrategyScreenState extends ConsumerState<CreateStrategyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _strategyNameController = TextEditingController();
  final _incomeController = TextEditingController();
  double _incomeAmount = 0.0;
  IncomeType _selectedIncomeType = IncomeType.variable;
  IncomeSource _selectedIncomeSource = IncomeSource.cash; // FR13
  StrategyTemplate? _selectedTemplate;
  bool _isLoading = false;

  // Allocation percentages
  final Map<String, double> _allocations = {
    'Family Support': 30.0,
    'Emergencies': 15.0,
    'Savings': 20.0,
    'Daily Needs': 25.0,
    'Community Contributions': 10.0,
  };

  @override
  void dispose() {
    _strategyNameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  double get _totalPercentage {
    return _allocations.values.fold(0.0, (sum, item) => sum + item);
  }

  void _updateAllocation(String name, double newPercentage) {
    setState(() {
      _allocations[name] = newPercentage;
    });
  }

  void _applyTemplate(StrategyTemplate? template) {
    if (template == null) return;

    setState(() {
      _selectedTemplate = template;
      // Apply template allocations
      for (final entry in template.allocations.entries) {
        if (_allocations.containsKey(entry.key)) {
          _allocations[entry.key] = entry.value;
        }
      }
    });
  }

  Future<void> _saveStrategy() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch categories to get their IDs
      final categories = await ref.read(allocationCategoriesProvider.future);

      // Create category allocations
      final categoryAllocations = <CategoryAllocation>[];
      for (final entry in _allocations.entries) {
        // Find matching category by name
        final category = categories.firstWhere(
          (c) => c.name == entry.key,
          orElse: () => categories.first,
        );

        categoryAllocations.add(
          CategoryAllocation(
            categoryId: category.id,
            percentage: entry.value,
          ),
        );
      }

      // Create income entry
      final income = IncomeEntry(
        id: '',
        userId: currentUser.id,
        amount: _incomeAmount,
        currency: 'KES', // Default currency
        incomeDate: DateTime.now(),
        incomeType: _selectedIncomeType,
        incomeSource: _selectedIncomeSource,
        description: 'Income for ${_strategyNameController.text.trim()}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Check if this is the first strategy
      final existingStrategies = await ref.read(allocationStrategiesProvider.future);
      final isFirstStrategy = existingStrategies.isEmpty;

      // Create allocation strategy
      final strategy = AllocationStrategy(
        id: '',
        userId: currentUser.id,
        name: _strategyNameController.text.trim(),
        isActive: isFirstStrategy, // Mark as active if it's the first one
        isTemplate: false,
        allocations: categoryAllocations,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save allocation
      await ref.read(saveAllocationProvider.notifier).execute(
            income: income,
            strategy: strategy,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFirstStrategy
                ? '✅ Strategy "${strategy.name}" created and activated!'
                : '✅ Strategy "${strategy.name}" created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to dashboard or strategies screen
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
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
    final isValid = remainingPercentage.abs() < 0.1 && _incomeAmount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Strategy'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (categories) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                // Income Entry
                Text(
                  'Expected Income',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter income amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
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
                              color: Colors.grey[600],
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

                // Strategy Templates
                Text(
                  'Quick Start Template (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                StrategyTemplateSelector(
                  selectedTemplate: _selectedTemplate,
                  onTemplateSelected: (template) {
                    if (!_isLoading) _applyTemplate(template);
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
                  final percentage = _allocations[category.name] ?? 0.0;
                  final amount = _incomeAmount * (percentage / 100);
                  final color = Color(
                    int.parse(category.color.replaceFirst('#', '0xFF')),
                  );

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
                              '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
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
                              : (value) => _updateAllocation(category.name, value),
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
                    color: isValid ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isValid ? Colors.green : Colors.orange,
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
                              color: isValid ? Colors.green : Colors.orange,
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
                          color: Colors.orange.shade700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),

                // Save Button
                FilledButton(
                  onPressed: isValid && !_isLoading ? _saveStrategy : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Strategy',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading categories: $error'),
        ),
      ),
    );
  }
}
