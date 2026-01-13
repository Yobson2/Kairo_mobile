import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';

/// Predefined strategy templates for quick onboarding
/// Provides culturally-intelligent default allocations (FR3.2)
class StrategyTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, double> allocations; // category name -> percentage
  final List<String> benefits;
  final String recommendedFor;

  const StrategyTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.allocations,
    required this.benefits,
    required this.recommendedFor,
  });

  /// Total percentage (should equal 100)
  double get totalPercentage {
    return allocations.values.fold(0.0, (sum, value) => sum + value);
  }

  /// Validate template (all percentages must sum to 100)
  bool get isValid {
    return (totalPercentage - 100.0).abs() < 0.01;
  }
}

/// Predefined strategy templates
class StrategyTemplates {
  /// Balanced approach - equally distributes across all priorities
  static const balanced = StrategyTemplate(
    id: 'balanced',
    name: 'Balanced',
    description:
        'Equal focus on all areas - family, emergencies, savings, and daily needs',
    icon: Icons.balance,
    color: AppColors.info, // Blue
    allocations: {
      'Family Support': 25.0,
      'Emergencies': 20.0,
      'Savings': 20.0,
      'Daily Needs': 25.0,
      'Community Contributions': 10.0,
    },
    benefits: [
      'No single area is neglected',
      'Good for stable fixed income',
      'Flexible and adaptable',
    ],
    recommendedFor: 'People with fixed income who want balanced priorities',
  );

  /// Savings-first approach - prioritizes long-term wealth building
  static const savingsFirst = StrategyTemplate(
    id: 'savings_first',
    name: 'Savings First',
    description:
        'Build wealth faster by prioritizing savings and investments',
    icon: Icons.savings,
    color: AppColors.success, // Green
    allocations: {
      'Family Support': 20.0,
      'Emergencies': 15.0,
      'Savings': 40.0,
      'Daily Needs': 20.0,
      'Community Contributions': 5.0,
    },
    benefits: [
      'Accelerate wealth building',
      'Strong long-term security',
      'Compound growth over time',
    ],
    recommendedFor:
        'People with stable income who want to build wealth quickly',
  );

  /// Emergency-focus approach - strong buffer for unexpected expenses
  static const emergencyFocus = StrategyTemplate(
    id: 'emergency_focus',
    name: 'Emergency Focus',
    description:
        'Build a strong safety net for variable income and unexpected expenses',
    icon: Icons.shield,
    color: AppColors.warning, // Orange
    allocations: {
      'Family Support': 20.0,
      'Emergencies': 35.0,
      'Savings': 15.0,
      'Daily Needs': 25.0,
      'Community Contributions': 5.0,
    },
    benefits: [
      'Strong buffer for emergencies',
      'Peace of mind for variable income',
      'Handle unexpected expenses easily',
    ],
    recommendedFor:
        'People with variable income or frequent unexpected expenses',
  );

  /// Cultural priority - emphasizes family and community obligations
  static const culturalPriority = StrategyTemplate(
    id: 'cultural_priority',
    name: 'Cultural Priority',
    description:
        'Honor family and community obligations while maintaining personal stability',
    icon: Icons.people,
    color: AppColors.secondaryPurple, // Purple
    allocations: {
      'Family Support': 35.0,
      'Emergencies': 15.0,
      'Savings': 15.0,
      'Daily Needs': 20.0,
      'Community Contributions': 15.0,
    },
    benefits: [
      'Honor family obligations',
      'Maintain community connections',
      'Still build personal security',
    ],
    recommendedFor:
        'People with strong family support obligations or active community roles',
  );

  /// Debt payoff - prioritizes debt reduction while maintaining essentials
  static const debtPayoff = StrategyTemplate(
    id: 'debt_payoff',
    name: 'Debt Payoff',
    description:
        'Aggressive debt reduction while covering essential needs',
    icon: Icons.trending_down,
    color: AppColors.error, // Red
    allocations: {
      'Family Support': 15.0,
      'Emergencies': 10.0,
      'Savings': 10.0,
      'Daily Needs': 30.0,
      'Community Contributions': 5.0,
      // Note: In real implementation, we'd add a "Debt Payoff" category at 30%
    },
    benefits: [
      'Fast debt elimination',
      'Reduce interest payments',
      'Financial freedom sooner',
    ],
    recommendedFor:
        'People actively paying off loans or credit card debt',
  );

  /// Conservative approach - minimal risk, maximum security
  static const conservative = StrategyTemplate(
    id: 'conservative',
    name: 'Conservative',
    description:
        'Minimize risk with strong emergency fund and moderate savings',
    icon: Icons.security,
    color: AppColors.neutral600, // Gray
    allocations: {
      'Family Support': 20.0,
      'Emergencies': 30.0,
      'Savings': 25.0,
      'Daily Needs': 20.0,
      'Community Contributions': 5.0,
    },
    benefits: [
      'Maximum financial security',
      'Low risk approach',
      'Strong emergency buffer',
    ],
    recommendedFor:
        'People who prefer safety over aggressive growth',
  );

  /// All predefined templates
  static const List<StrategyTemplate> all = [
    balanced,
    savingsFirst,
    emergencyFocus,
    culturalPriority,
    debtPayoff,
    conservative,
  ];

  /// Get template by ID
  static StrategyTemplate? getById(String id) {
    try {
      return all.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get templates recommended for fixed income
  static List<StrategyTemplate> get forFixedIncome {
    return [balanced, savingsFirst, conservative, culturalPriority];
  }

  /// Get templates recommended for variable income
  static List<StrategyTemplate> get forVariableIncome {
    return [emergencyFocus, conservative, balanced];
  }

  /// Get templates recommended for mixed income
  static List<StrategyTemplate> get forMixedIncome {
    return [balanced, emergencyFocus, savingsFirst];
  }

  /// Get template recommendations based on income type
  static List<StrategyTemplate> getRecommendations(String incomeType) {
    switch (incomeType.toLowerCase()) {
      case 'fixed':
        return forFixedIncome;
      case 'variable':
        return forVariableIncome;
      case 'mixed':
        return forMixedIncome;
      default:
        return all;
    }
  }
}
