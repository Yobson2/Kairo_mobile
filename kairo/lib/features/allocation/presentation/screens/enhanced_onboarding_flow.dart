import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';

/// Enhanced multi-step onboarding flow with progress indicators
/// Targets 60-second completion time (FR1)
///
/// Steps:
/// 1. Welcome + Quick intro (10s)
/// 2. Income entry (15s)
/// 3. Allocation sliders (30s)
/// 4. Preview & confirm (5s)
class EnhancedOnboardingFlow extends ConsumerStatefulWidget {
  const EnhancedOnboardingFlow({super.key});

  @override
  ConsumerState<EnhancedOnboardingFlow> createState() =>
      _EnhancedOnboardingFlowState();
}

class _EnhancedOnboardingFlowState
    extends ConsumerState<EnhancedOnboardingFlow> {
  int _currentStep = 0;
  final _pageController = PageController();

  // Step 2: Income data
  final _incomeController = TextEditingController();
  double _incomeAmount = 0.0;
  IncomeType _selectedIncomeType = IncomeType.variable;
  String _selectedCurrency = 'KES';

  // Step 3: Allocation data
  final Map<String, AllocationItem> _allocations = {
    'family': AllocationItem(
      name: 'Family Support',
      percentage: 30.0,
      color: const Color(0xFFEF4444),
      icon: Icons.family_restroom,
      tooltip: 'Money for supporting family members',
    ),
    'emergency': AllocationItem(
      name: 'Emergencies',
      percentage: 15.0,
      color: const Color(0xFFF97316),
      icon: Icons.warning_amber,
      tooltip: 'Buffer for unexpected expenses',
    ),
    'savings': AllocationItem(
      name: 'Savings',
      percentage: 20.0,
      color: const Color(0xFF10B981),
      icon: Icons.savings,
      tooltip: 'Long-term savings and investments',
    ),
    'daily': AllocationItem(
      name: 'Daily Needs',
      percentage: 25.0,
      color: const Color(0xFFF59E0B),
      icon: Icons.shopping_cart,
      tooltip: 'Food, transport, utilities',
    ),
    'community': AllocationItem(
      name: 'Community',
      percentage: 10.0,
      color: const Color(0xFF8B5CF6),
      icon: Icons.people,
      tooltip: 'Church, events, social obligations',
    ),
  };

  // Available currencies
  final List<String> _currencies = ['KES', 'NGN', 'GHS', 'ZAR', 'USD', 'EUR'];

  @override
  void dispose() {
    _incomeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double get _totalPercentage {
    return _allocations.values.fold(0.0, (sum, item) => sum + item.percentage);
  }

  bool get _canProceedFromIncome {
    return _incomeAmount > 0;
  }

  bool get _canProceedFromAllocation {
    return (_totalPercentage - 100).abs() < 0.1;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Setup?'),
        content: const Text(
          'You can always set up your allocation later from the dashboard. '
          'However, we recommend completing it now - it only takes 60 seconds!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Setup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
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

    // Fetch categories to get their IDs
    final categories = await ref.read(allocationCategoriesProvider.future);

    // Create category allocations
    final categoryAllocations = <CategoryAllocation>[];
    for (final entry in _allocations.entries) {
      final category = categories.firstWhere(
        (c) => c.name == entry.value.name,
        orElse: () => categories.first,
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
      id: '',
      userId: currentUser.id,
      amount: _incomeAmount,
      currency: _selectedCurrency,
      incomeDate: DateTime.now(),
      incomeType: _selectedIncomeType,
      incomeSource: IncomeSource.other,
      description: 'Initial allocation',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create allocation strategy
    final strategy = AllocationStrategy(
      id: '',
      userId: currentUser.id,
      name: 'My First Strategy',
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
    final saveState = ref.watch(saveAllocationProvider);

    // Listen for save completion
    ref.listen<AsyncValue<void>>(saveAllocationProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Welcome to Kairo! Your money has a plan.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          context.go('/dashboard');
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
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
            // Progress indicator
            _OnboardingProgressBar(
              currentStep: _currentStep,
              totalSteps: 4,
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomeStep(
                    onNext: _nextStep,
                    onSkip: _skipOnboarding,
                  ),
                  _IncomeStep(
                    incomeController: _incomeController,
                    incomeAmount: _incomeAmount,
                    selectedIncomeType: _selectedIncomeType,
                    selectedCurrency: _selectedCurrency,
                    currencies: _currencies,
                    onIncomeChanged: (value) {
                      setState(() => _incomeAmount = double.tryParse(value) ?? 0.0);
                    },
                    onIncomeTypeChanged: (type) {
                      setState(() => _selectedIncomeType = type);
                    },
                    onCurrencyChanged: (currency) {
                      setState(() => _selectedCurrency = currency);
                    },
                    onNext: _canProceedFromIncome ? _nextStep : null,
                    onBack: _previousStep,
                  ),
                  _AllocationStep(
                    allocations: _allocations,
                    incomeAmount: _incomeAmount,
                    currency: _selectedCurrency,
                    totalPercentage: _totalPercentage,
                    onAllocationChanged: (key, value) {
                      setState(() {
                        _allocations[key] =
                            _allocations[key]!.copyWith(percentage: value);
                      });
                    },
                    onNext: _canProceedFromAllocation ? _nextStep : null,
                    onBack: _previousStep,
                  ),
                  _PreviewStep(
                    incomeAmount: _incomeAmount,
                    currency: _selectedCurrency,
                    incomeType: _selectedIncomeType,
                    allocations: _allocations,
                    onBack: _previousStep,
                    onComplete: saveState.isLoading ? null : _completeOnboarding,
                    isLoading: saveState.isLoading,
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

/// Progress bar showing current step
class _OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _OnboardingProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '~${_estimatedTime(currentStep)}s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  int _estimatedTime(int step) {
    switch (step) {
      case 0:
        return 10;
      case 1:
        return 15;
      case 2:
        return 30;
      case 3:
        return 5;
      default:
        return 0;
    }
  }
}

/// Step 1: Welcome screen
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _WelcomeStep({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Kairo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s design where your money should go.\nNo tracking. No guilt. Just your plan.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _InfoCard(
            icon: Icons.timer,
            title: '60 seconds',
            subtitle: 'That\'s all it takes',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.auto_awesome,
            title: 'Auto-saves',
            subtitle: 'No save buttons needed',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.favorite,
            title: 'Made for you',
            subtitle: 'African financial realities first',
          ),
          const Spacer(),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
            ),
            child: const Text('Let\'s Start', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }
}

/// Info card for welcome step
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 2: Income entry
class _IncomeStep extends StatelessWidget {
  final TextEditingController incomeController;
  final double incomeAmount;
  final IncomeType selectedIncomeType;
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String> onIncomeChanged;
  final ValueChanged<IncomeType> onIncomeTypeChanged;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  const _IncomeStep({
    required this.incomeController,
    required this.incomeAmount,
    required this.selectedIncomeType,
    required this.selectedCurrency,
    required this.currencies,
    required this.onIncomeChanged,
    required this.onIncomeTypeChanged,
    required this.onCurrencyChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Income',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'How much money do you have this month?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Currency selector
          Row(
            children: [
              Text(
                'Currency',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: selectedCurrency,
                items: currencies
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCurrencyChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Income amount input
          TextField(
            controller: incomeController,
            keyboardType: TextInputType.number,
            onChanged: onIncomeChanged,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: _getCurrencySymbol(selectedCurrency),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              helperText: 'Enter the total you have to allocate',
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Income type selector
          Text(
            'Income Type',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us give you better advice',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          _IncomeTypeCard(
            type: IncomeType.fixed,
            title: 'Fixed',
            subtitle: 'Regular monthly salary',
            icon: Icons.calendar_today,
            isSelected: selectedIncomeType == IncomeType.fixed,
            onTap: () => onIncomeTypeChanged(IncomeType.fixed),
          ),
          const SizedBox(height: 8),
          _IncomeTypeCard(
            type: IncomeType.variable,
            title: 'Variable',
            subtitle: 'Irregular income from gigs or seasonal work',
            icon: Icons.trending_up,
            isSelected: selectedIncomeType == IncomeType.variable,
            onTap: () => onIncomeTypeChanged(IncomeType.variable),
          ),
          const SizedBox(height: 8),
          _IncomeTypeCard(
            type: IncomeType.mixed,
            title: 'Mixed',
            subtitle: 'Fixed salary + variable side income',
            icon: Icons.shuffle,
            isSelected: selectedIncomeType == IncomeType.mixed,
            onTap: () => onIncomeTypeChanged(IncomeType.mixed),
          ),

          const Spacer(),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next: Allocate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KSh ';
      case 'NGN':
        return '₦ ';
      case 'GHS':
        return 'GH₵ ';
      case 'ZAR':
        return 'R ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      default:
        return '';
    }
  }
}

/// Income type selection card
class _IncomeTypeCard extends StatelessWidget {
  final IncomeType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IncomeTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Step 3: Allocation sliders
class _AllocationStep extends StatelessWidget {
  final Map<String, AllocationItem> allocations;
  final double incomeAmount;
  final String currency;
  final double totalPercentage;
  final Function(String, double) onAllocationChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  const _AllocationStep({
    required this.allocations,
    required this.incomeAmount,
    required this.currency,
    required this.totalPercentage,
    required this.onAllocationChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final remainingPercentage = 100 - totalPercentage;
    final isValid = remainingPercentage.abs() < 0.1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design Your Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adjust the sliders to allocate your money',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...allocations.entries.map((entry) {
                final key = entry.key;
                final item = entry.value;
                final allocatedAmount = incomeAmount * (item.percentage / 100);

                return _AllocationSliderCard(
                  item: item,
                  allocatedAmount: allocatedAmount,
                  currency: currency,
                  onChanged: (value) => onAllocationChanged(key, value),
                );
              }),

              const SizedBox(height: 16),

              // Total indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isValid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isValid ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
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
                          '${totalPercentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isValid ? Colors.green : Colors.orange,
                              ),
                        ),
                      ],
                    ),
                    if (!isValid) ...[
                      const SizedBox(height: 8),
                      Text(
                        remainingPercentage > 0
                            ? '${remainingPercentage.toStringAsFixed(0)}% left to allocate'
                            : '${remainingPercentage.abs().toStringAsFixed(0)}% over - adjust sliders',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next: Preview'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Allocation slider card with tooltip
class _AllocationSliderCard extends StatefulWidget {
  final AllocationItem item;
  final double allocatedAmount;
  final String currency;
  final ValueChanged<double> onChanged;

  const _AllocationSliderCard({
    required this.item,
    required this.allocatedAmount,
    required this.currency,
    required this.onChanged,
  });

  @override
  State<_AllocationSliderCard> createState() => _AllocationSliderCardState();
}

class _AllocationSliderCardState extends State<_AllocationSliderCard> {
  bool _showTooltip = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.item.icon, color: widget.item.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showTooltip
                                  ? Icons.info
                                  : Icons.info_outline,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _showTooltip = !_showTooltip);
                            },
                          ),
                        ],
                      ),
                      if (widget.allocatedAmount > 0)
                        Text(
                          '${_getCurrencySymbol(widget.currency)}${widget.allocatedAmount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${widget.item.percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.item.color,
                      ),
                ),
              ],
            ),

            // Tooltip
            if (_showTooltip) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.tooltip,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: widget.item.color,
                thumbColor: widget.item.color,
                inactiveTrackColor: widget.item.color.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: widget.item.percentage,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KSh ';
      case 'NGN':
        return '₦ ';
      case 'GHS':
        return 'GH₵ ';
      case 'ZAR':
        return 'R ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      default:
        return '';
    }
  }
}

/// Step 4: Preview and confirm
class _PreviewStep extends StatelessWidget {
  final double incomeAmount;
  final String currency;
  final IncomeType incomeType;
  final Map<String, AllocationItem> allocations;
  final VoidCallback onBack;
  final VoidCallback? onComplete;
  final bool isLoading;

  const _PreviewStep({
    required this.incomeAmount,
    required this.currency,
    required this.incomeType,
    required this.allocations,
    required this.onBack,
    required this.onComplete,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s how your money will be allocated',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Income summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${_getIncomeTypeLabel(incomeType)} income',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Text(
                  '${_getCurrencySymbol(currency)}${incomeAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Allocation breakdown
          Text(
            'Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: allocations.entries.map((entry) {
                final item = entry.value;
                final amount = incomeAmount * (item.percentage / 100);

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.percentage.toStringAsFixed(0)}%'),
                  trailing: Text(
                    '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Success message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perfect! Your money has a clear plan.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onComplete,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KSh ';
      case 'NGN':
        return '₦ ';
      case 'GHS':
        return 'GH₵ ';
      case 'ZAR':
        return 'R ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      default:
        return '';
    }
  }

  String _getIncomeTypeLabel(IncomeType type) {
    switch (type) {
      case IncomeType.fixed:
        return 'Fixed';
      case IncomeType.variable:
        return 'Variable';
      case IncomeType.mixed:
        return 'Mixed';
    }
  }
}

/// Allocation item data class
class AllocationItem {
  final String name;
  final double percentage;
  final Color color;
  final IconData icon;
  final String tooltip;

  AllocationItem({
    required this.name,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  AllocationItem copyWith({
    String? name,
    double? percentage,
    Color? color,
    IconData? icon,
    String? tooltip,
  }) {
    return AllocationItem(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}
