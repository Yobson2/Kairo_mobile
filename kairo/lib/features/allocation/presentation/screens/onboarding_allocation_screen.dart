import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/screens/dashboard_screen.dart';
import 'package:kairo/features/allocation/presentation/widgets/strategy_template_selector.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Action-based onboarding screen for first-time income allocation
/// Implements FR1: Complete first allocation within 60 seconds
class OnboardingAllocationScreen extends ConsumerStatefulWidget {
  const OnboardingAllocationScreen({super.key});

  @override
  ConsumerState<OnboardingAllocationScreen> createState() =>
      _OnboardingAllocationScreenState();
}

class _OnboardingAllocationScreenState
    extends ConsumerState<OnboardingAllocationScreen> {
  final _incomeController = TextEditingController();
  double _incomeAmount = 0.0;
  IncomeType _selectedIncomeType = IncomeType.variable; // FR6: Income type selection
  int _currentStep = 0; // 0 = template selection, 1 = allocation customization
  StrategyTemplate? _selectedTemplate;

  // Default allocation percentages (FR2: culturally-relevant defaults)
  final Map<String, AllocationItem> _allocations = {
    'family': AllocationItem(
      name: 'Family Support',
      percentage: 30.0,
      color: const Color(0xFFEF4444), // Red
      icon: Icons.family_restroom,
    ),
    'emergency': AllocationItem(
      name: 'Emergencies',
      percentage: 15.0,
      color: const Color(0xFFF97316), // Orange
      icon: Icons.warning_amber,
    ),
    'savings': AllocationItem(
      name: 'Savings',
      percentage: 20.0,
      color: const Color(0xFF10B981), // Green
      icon: Icons.savings,
    ),
    'daily': AllocationItem(
      name: 'Daily Needs',
      percentage: 25.0,
      color: const Color(0xFFF59E0B), // Amber
      icon: Icons.shopping_cart,
    ),
    'community': AllocationItem(
      name: 'Community Contributions',
      percentage: 10.0,
      color: const Color(0xFF8B5CF6), // Purple
      icon: Icons.people,
    ),
  };

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  double get _totalPercentage {
    return _allocations.values.fold(0.0, (sum, item) => sum + item.percentage);
  }

  void _updateAllocation(String key, double newPercentage) {
    setState(() {
      _allocations[key] = _allocations[key]!.copyWith(percentage: newPercentage);
    });
  }

  void _onIncomeChanged(String value) {
    setState(() {
      _incomeAmount = double.tryParse(value) ?? 0.0;
    });
  }

  String _getIncomeTypeDescription(IncomeType type) {
    switch (type) {
      case IncomeType.fixed:
        return 'Regular monthly salary or consistent income';
      case IncomeType.variable:
        return 'Irregular income from gigs, freelance, or seasonal work';
      case IncomeType.mixed:
        return 'Combination of fixed salary and variable side income';
    }
  }

  void _applyTemplate(StrategyTemplate? template) {
    if (template == null) return;

    setState(() {
      _selectedTemplate = template;
      // Apply template allocations to existing categories
      for (final entry in template.allocations.entries) {
        final categoryKey = _allocations.keys.firstWhere(
          (key) => _allocations[key]!.name == entry.key,
          orElse: () => '',
        );
        if (categoryKey.isNotEmpty) {
          _allocations[categoryKey] =
              _allocations[categoryKey]!.copyWith(percentage: entry.value);
        }
      }
    });
  }

  void _proceedToCustomization() {
    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _saveAllocation() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Fetch categories to get their IDs
    final categories = await ref.read(allocationCategoriesProvider.future);

    // Create category allocations mapping category names to IDs
    final categoryAllocations = <CategoryAllocation>[];
    for (final entry in _allocations.entries) {
      // Find matching category by name
      final category = categories.firstWhere(
        (c) => c.name == entry.value.name,
        orElse: () => categories.first, // Fallback
      );

      categoryAllocations.add(
        CategoryAllocation(
          categoryId: category.id,
          percentage: entry.value.percentage,
        ),
      );
    }

    // Create income entry
    final income = IncomeEntry(
      id: '', // Will be generated by database
      userId: currentUser.id,
      amount: _incomeAmount,
      currency: 'KES', // Default currency
      incomeDate: DateTime.now(),
      incomeType: _selectedIncomeType, // Use selected income type (FR6)
      incomeSource: IncomeSource.other,
      description: 'Initial allocation',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create allocation strategy
    final strategy = AllocationStrategy(
      id: '', // Will be generated by database
      userId: currentUser.id,
      name: 'My First Allocation',
      isActive: true,
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
  }

  @override
  Widget build(BuildContext context) {
    final remainingPercentage = 100 - _totalPercentage;
    final isValid = remainingPercentage.abs() < 0.1;
    final saveState = ref.watch(saveAllocationProvider);

    // Listen for save completion
    ref.listen<AsyncValue<void>>(saveAllocationProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Allocation saved! Welcome to Kairo.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save allocation: $error'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design Your Money',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s plan where your money should go this month',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Income input
                  TextField(
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    onChanged: _onIncomeChanged,
                    decoration: InputDecoration(
                      labelText: 'Your Income This Month',
                      prefixText: '\$ ',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      helperText: 'Enter the total amount you have to allocate',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Income type selector (FR6)
                  Text(
                    'Income Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                    onSelectionChanged: (Set<IncomeType> selected) {
                      setState(() {
                        _selectedIncomeType = selected.first;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getIncomeTypeDescription(_selectedIncomeType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                ],
              ),
            ),

            // Allocation sliders
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Category sliders
                  ..._allocations.entries.map((entry) {
                    final key = entry.key;
                    final item = entry.value;
                    final allocatedAmount = _incomeAmount * (item.percentage / 100);

                    return _AllocationSlider(
                      name: item.name,
                      icon: item.icon,
                      color: item.color,
                      percentage: item.percentage,
                      amount: allocatedAmount,
                      onChanged: (value) => _updateAllocation(key, value),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Total indicator
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isValid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${_totalPercentage.toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          ? '${remainingPercentage.toStringAsFixed(0)}% remaining to allocate'
                          : 'You\'ve allocated ${remainingPercentage.abs().toStringAsFixed(0)}% too much',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Save button
                  FilledButton(
                    onPressed: isValid && _incomeAmount > 0 && !saveState.isLoading
                        ? _saveAllocation
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: saveState.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Start Using Kairo',
                            style: TextStyle(fontSize: 16),
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

/// Individual allocation slider widget
class _AllocationSlider extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final double percentage;
  final double amount;
  final ValueChanged<double> onChanged;

  const _AllocationSlider({
    required this.name,
    required this.icon,
    required this.color,
    required this.percentage,
    required this.amount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (amount > 0)
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: percentage,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for allocation items
class AllocationItem {
  final String name;
  final double percentage;
  final Color color;
  final IconData icon;

  AllocationItem({
    required this.name,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  AllocationItem copyWith({
    String? name,
    double? percentage,
    Color? color,
    IconData? icon,
  }) {
    return AllocationItem(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
