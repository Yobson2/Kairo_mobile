import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/domain/entities/strategy_template.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Strategy template selection screen
/// Allows users to choose from predefined templates or create custom (FR3.2)
class StrategyTemplateSelectionScreen extends ConsumerStatefulWidget {
  final IncomeType? incomeType;
  final double? incomeAmount;
  final String? currency;

  const StrategyTemplateSelectionScreen({
    super.key,
    this.incomeType,
    this.incomeAmount,
    this.currency,
  });

  @override
  ConsumerState<StrategyTemplateSelectionScreen> createState() =>
      _StrategyTemplateSelectionScreenState();
}

class _StrategyTemplateSelectionScreenState
    extends ConsumerState<StrategyTemplateSelectionScreen> {
  StrategyTemplate? _selectedTemplate;
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    final recommendations = widget.incomeType != null
        ? StrategyTemplates.getRecommendations(widget.incomeType!.name)
        : StrategyTemplates.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Strategy'),
      ),
      body: _showPreview && _selectedTemplate != null
          ? _TemplatePreview(
              template: _selectedTemplate!,
              incomeAmount: widget.incomeAmount,
              currency: widget.currency,
              onBack: () {
                setState(() => _showPreview = false);
              },
              onApply: _applyTemplate,
            )
          : _TemplateSelection(
              recommendations: recommendations,
              selectedTemplate: _selectedTemplate,
              incomeType: widget.incomeType,
              onTemplateSelected: (template) {
                setState(() {
                  _selectedTemplate = template;
                  _showPreview = true;
                });
              },
              onCreateCustom: () {
                context.push('/strategies/new');
              },
            ),
    );
  }

  Future<void> _applyTemplate() async {
    if (_selectedTemplate == null) return;

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get categories to map template allocations
      final categories = await ref.read(allocationCategoriesProvider.future);

      // Create category allocations from template
      final categoryAllocations = <CategoryAllocation>[];
      for (final entry in _selectedTemplate!.allocations.entries) {
        final category = categories.firstWhere(
          (c) => c.name == entry.key,
          orElse: () => throw Exception('Category ${entry.key} not found'),
        );

        categoryAllocations.add(
          CategoryAllocation(
            categoryId: category.id,
            percentage: entry.value,
          ),
        );
      }

      // Create strategy from template
      final strategy = AllocationStrategy(
        id: '',
        userId: currentUser.id,
        name: _selectedTemplate!.name,
        isActive: true,
        isTemplate: false,
        allocations: categoryAllocations,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save strategy (this will also create income entry if needed)
      // TODO: Implement proper save flow
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ ${_selectedTemplate!.name} strategy applied!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying template: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Template selection grid
class _TemplateSelection extends StatelessWidget {
  final List<StrategyTemplate> recommendations;
  final StrategyTemplate? selectedTemplate;
  final IncomeType? incomeType;
  final Function(StrategyTemplate) onTemplateSelected;
  final VoidCallback onCreateCustom;

  const _TemplateSelection({
    required this.recommendations,
    required this.selectedTemplate,
    required this.incomeType,
    required this.onTemplateSelected,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Choose Your Strategy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            incomeType != null
                ? 'Recommended for ${_getIncomeTypeLabel(incomeType!)} income'
                : 'Select a strategy that matches your goals',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
          const SizedBox(height: 24),

          // Template cards
          ...recommendations.map((template) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TemplateCard(
                template: template,
                isSelected: selectedTemplate?.id == template.id,
                onTap: () => onTemplateSelected(template),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Custom strategy option
          Card(
            child: InkWell(
              onTap: onCreateCustom,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Custom Strategy',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Design your own allocation from scratch',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.neutral600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIncomeTypeLabel(IncomeType type) {
    switch (type) {
      case IncomeType.fixed:
        return 'fixed';
      case IncomeType.variable:
        return 'variable';
      case IncomeType.mixed:
        return 'mixed';
    }
  }
}

/// Template card widget
class _TemplateCard extends StatelessWidget {
  final StrategyTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: template.color,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: template.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      template.icon,
                      color: template.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? template.color : null,
                                  ),
                        ),
                        Text(
                          template.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.neutral600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: template.color,
                      size: 32,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Benefits
              Text(
                'Benefits:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...template.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: template.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Recommended for
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.recommend,
                      size: 16,
                      color: AppColors.neutral700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        template.recommendedFor,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral700,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template preview screen
class _TemplatePreview extends StatelessWidget {
  final StrategyTemplate template;
  final double? incomeAmount;
  final String? currency;
  final VoidCallback onBack;
  final VoidCallback onApply;

  const _TemplatePreview({
    required this.template,
    required this.incomeAmount,
    required this.currency,
    required this.onBack,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: template.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        template.icon,
                        color: template.color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            template.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.neutral600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Allocation breakdown
                Text(
                  'Allocation Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                ...template.allocations.entries.map((entry) {
                  final amount = incomeAmount != null
                      ? incomeAmount! * (entry.value / 100)
                      : null;

                  return _AllocationBar(
                    categoryName: entry.key,
                    percentage: entry.value,
                    amount: amount,
                    currency: currency,
                    color: template.color,
                  );
                }),

                const SizedBox(height: 24),

                // Benefits section
                Text(
                  'Why This Strategy?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...template.benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: template.color,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            benefit,
                            style: Theme.of(context).textTheme.bodyLarge,
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

        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
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
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: template.color,
                  ),
                  child: const Text('Apply This Strategy'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Allocation bar widget
class _AllocationBar extends StatelessWidget {
  final String categoryName;
  final double percentage;
  final double? amount;
  final String? currency;
  final Color color;

  const _AllocationBar({
    required this.categoryName,
    required this.percentage,
    required this.amount,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                '${percentage.toStringAsFixed(0)}%${amount != null ? ' · ${_formatAmount(amount!, currency!)}' : ''}',
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
            backgroundColor: AppColors.neutral300,
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(0)}';
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
}
