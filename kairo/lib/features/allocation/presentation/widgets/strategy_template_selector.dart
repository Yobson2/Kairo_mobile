import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';

/// Strategy template data class
class StrategyTemplate {
  final String name;
  final String description;
  final Map<String, double> allocations; // category name -> percentage

  const StrategyTemplate({
    required this.name,
    required this.description,
    required this.allocations,
  });
}

/// Predefined strategy templates (FR8)
class StrategyTemplates {
  static const balanced = StrategyTemplate(
    name: '50/30/20 - Balanced',
    description: '50% Needs, 30% Wants, 20% Savings',
    allocations: {
      'Daily Needs': 50.0,
      'Community Contributions': 10.0,
      'Family Support': 20.0,
      'Savings': 15.0,
      'Emergencies': 5.0,
    },
  );

  static const savingsFirst = StrategyTemplate(
    name: '70/20/10 - Savings First',
    description: '70% Essentials, 20% Savings, 10% Flexible',
    allocations: {
      'Daily Needs': 40.0,
      'Family Support': 30.0,
      'Savings': 20.0,
      'Emergencies': 5.0,
      'Community Contributions': 5.0,
    },
  );

  static const familyFocused = StrategyTemplate(
    name: 'Family Focused',
    description: 'Prioritize family support and emergencies',
    allocations: {
      'Family Support': 40.0,
      'Daily Needs': 25.0,
      'Emergencies': 20.0,
      'Savings': 10.0,
      'Community Contributions': 5.0,
    },
  );

  static const communityBuilder = StrategyTemplate(
    name: 'Community Builder',
    description: 'Strong community and family support',
    allocations: {
      'Community Contributions': 25.0,
      'Family Support': 30.0,
      'Daily Needs': 25.0,
      'Savings': 15.0,
      'Emergencies': 5.0,
    },
  );

  static const List<StrategyTemplate> all = [
    balanced,
    savingsFirst,
    familyFocused,
    communityBuilder,
  ];
}

/// Widget for selecting a strategy template
class StrategyTemplateSelector extends StatelessWidget {
  final StrategyTemplate? selectedTemplate;
  final ValueChanged<StrategyTemplate?> onTemplateSelected;

  const StrategyTemplateSelector({
    super.key,
    this.selectedTemplate,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a Starting Point',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a template or customize your own',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
        const SizedBox(height: 16),

        // Custom/Manual option
        _TemplateCard(
          title: 'Custom Allocation',
          description: 'Start from scratch and design your own',
          icon: Icons.edit,
          isSelected: selectedTemplate == null,
          onTap: () => onTemplateSelected(null),
        ),
        const SizedBox(height: 12),

        // Predefined templates
        ...StrategyTemplates.all.map((template) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _TemplateCard(
              title: template.name,
              description: template.description,
              icon: Icons.account_balance_wallet,
              isSelected: selectedTemplate == template,
              onTap: () => onTemplateSelected(template),
              allocations: template.allocations,
            ),
          );
        }),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Map<String, double>? allocations;

  const _TemplateCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.allocations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : AppColors.divider,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.neutral600,
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
              if (allocations != null && isSelected) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                ...allocations!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
