import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';

/// Variable income guidance widget providing contextual tips
/// and variability indicators for users with irregular income (FR10, FR11)
class VariableIncomeGuidance extends ConsumerStatefulWidget {
  final List<IncomeEntry> incomeHistory;
  final IncomeType currentIncomeType;

  const VariableIncomeGuidance({
    super.key,
    required this.incomeHistory,
    required this.currentIncomeType,
  });

  @override
  ConsumerState<VariableIncomeGuidance> createState() =>
      _VariableIncomeGuidanceState();
}

class _VariableIncomeGuidanceState
    extends ConsumerState<VariableIncomeGuidance> {
  final Set<String> _dismissedTips = {};

  @override
  Widget build(BuildContext context) {
    // Only show for variable or mixed income
    if (widget.currentIncomeType == IncomeType.fixed) {
      return const SizedBox.shrink();
    }

    final variability = _calculateVariability();
    final tips = _getContextualTips(variability);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variability indicator
        _VariabilityIndicator(variability: variability),

        const SizedBox(height: 16),

        // Contextual tips
        ...tips
            .where((tip) => !_dismissedTips.contains(tip.id))
            .map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GuidanceTipCard(
                    tip: tip,
                    onDismiss: () {
                      setState(() => _dismissedTips.add(tip.id));
                    },
                  ),
                )),
      ],
    );
  }

  /// Calculate income variability percentage
  IncomeVariability _calculateVariability() {
    if (widget.incomeHistory.length < 2) {
      return IncomeVariability.unknown;
    }

    final amounts = widget.incomeHistory.map((e) => e.amount).toList();
    final average = amounts.reduce((a, b) => a + b) / amounts.length;

    // Calculate standard deviation
    final variance = amounts
        .map((amount) => (amount - average) * (amount - average))
        .reduce((a, b) => a + b) / amounts.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0.0;

    // Coefficient of variation (CV)
    final cv = average > 0 ? (stdDev / average) * 100 : 0.0;

    if (cv < 15) return IncomeVariability.low;
    if (cv < 30) return IncomeVariability.moderate;
    if (cv < 50) return IncomeVariability.high;
    return IncomeVariability.veryHigh;
  }

  /// Get contextual tips based on variability
  List<GuidanceTip> _getContextualTips(IncomeVariability variability) {
    final tips = <GuidanceTip>[];

    // Tip based on variability level
    switch (variability) {
      case IncomeVariability.low:
        tips.add(GuidanceTip(
          id: 'low_variability',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Your income is stable',
          message:
              'Great! Your income has been consistent. Consider increasing your savings allocation.',
          type: TipType.positive,
        ));
        break;
      case IncomeVariability.moderate:
        tips.add(GuidanceTip(
          id: 'moderate_variability',
          icon: Icons.trending_up,
          iconColor: AppColors.warning,
          title: 'Some variation detected',
          message:
              'Your income varies a bit. Keep at least 15-20% in emergencies for buffer months.',
          type: TipType.suggestion,
        ));
        break;
      case IncomeVariability.high:
      case IncomeVariability.veryHigh:
        tips.add(GuidanceTip(
          id: 'high_variability',
          icon: Icons.warning_amber,
          iconColor: AppColors.error,
          title: 'Income varies significantly',
          message:
              'Build a strong emergency buffer (20-30%) to handle low-income months comfortably.',
          type: TipType.important,
        ));
        break;
      case IncomeVariability.unknown:
        tips.add(GuidanceTip(
          id: 'not_enough_data',
          icon: Icons.info_outline,
          iconColor: AppColors.info,
          title: 'Still learning your pattern',
          message:
              'Add more income entries so we can give you personalized advice.',
          type: TipType.info,
        ));
        break;
    }

    // Additional contextual tips based on income history
    if (widget.incomeHistory.length >= 3) {
      final lastThree = widget.incomeHistory.take(3).toList();
      final isIncreasing = lastThree[0].amount > lastThree[1].amount &&
          lastThree[1].amount > lastThree[2].amount;
      final isDecreasing = lastThree[0].amount < lastThree[1].amount &&
          lastThree[1].amount < lastThree[2].amount;

      if (isIncreasing) {
        tips.add(GuidanceTip(
          id: 'increasing_trend',
          icon: Icons.trending_up,
          iconColor: AppColors.success,
          title: 'Income is growing!',
          message:
              'Your income has increased for 3 months. Consider allocating the extra to savings.',
          type: TipType.positive,
        ));
      } else if (isDecreasing) {
        tips.add(GuidanceTip(
          id: 'decreasing_trend',
          icon: Icons.trending_down,
          iconColor: AppColors.warning,
          title: 'Income has decreased',
          message:
              'Your income has dropped recently. Consider using "This month is different" to adjust.',
          type: TipType.suggestion,
          actionLabel: 'Adjust Allocation',
        ));
      }
    }

    // Tip for first-time variable income users
    if (widget.incomeHistory.length == 1 &&
        widget.currentIncomeType == IncomeType.variable) {
      tips.add(GuidanceTip(
        id: 'variable_income_intro',
        icon: Icons.lightbulb_outline,
        iconColor: AppColors.warningLight,
        title: 'Managing variable income',
        message:
            'Your income changes month to month. Allocate based on your lowest expected month, not your highest.',
        type: TipType.suggestion,
      ));
    }

    return tips;
  }
}

/// Variability indicator showing income consistency
class _VariabilityIndicator extends StatelessWidget {
  final IncomeVariability variability;

  const _VariabilityIndicator({required this.variability});

  @override
  Widget build(BuildContext context) {
    if (variability == IncomeVariability.unknown) {
      return const SizedBox.shrink();
    }

    final config = _getVariabilityConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color.withValues(alpha: 0.1),
            config.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(config.icon, color: config.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income Variability',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: config.color,
                      ),
                ),
              ],
            ),
          ),
          // Visual indicator bars
          Column(
            children: List.generate(4, (index) {
              final isActive = index < config.barCount;
              return Container(
                width: 24,
                height: 6,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? config.color
                      : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  _VariabilityConfig _getVariabilityConfig() {
    switch (variability) {
      case IncomeVariability.low:
        return _VariabilityConfig(
          label: 'Low (Stable)',
          color: AppColors.success,
          icon: Icons.show_chart,
          barCount: 1,
        );
      case IncomeVariability.moderate:
        return _VariabilityConfig(
          label: 'Moderate',
          color: AppColors.warning,
          icon: Icons.trending_up,
          barCount: 2,
        );
      case IncomeVariability.high:
        return _VariabilityConfig(
          label: 'High',
          color: AppColors.categoryOrange,
          icon: Icons.waterfall_chart,
          barCount: 3,
        );
      case IncomeVariability.veryHigh:
        return _VariabilityConfig(
          label: 'Very High',
          color: AppColors.error,
          icon: Icons.ssid_chart,
          barCount: 4,
        );
      case IncomeVariability.unknown:
        return _VariabilityConfig(
          label: 'Unknown',
          color: AppColors.neutral500,
          icon: Icons.help_outline,
          barCount: 0,
        );
    }
  }
}

/// Guidance tip card with dismiss functionality
class _GuidanceTipCard extends StatelessWidget {
  final GuidanceTip tip;
  final VoidCallback onDismiss;

  const _GuidanceTipCard({
    required this.tip,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final borderColor = _getBorderColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tip.icon, color: tip.iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral700,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
              ),
            ],
          ),
          if (tip.actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement action navigation
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(tip.actionLabel!),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (tip.type) {
      case TipType.positive:
        return AppColors.success.withValues(alpha: 0.1);
      case TipType.suggestion:
        return AppColors.info.withValues(alpha: 0.1);
      case TipType.important:
        return AppColors.warning.withValues(alpha: 0.1);
      case TipType.info:
        return AppColors.neutral100;
    }
  }

  Color _getBorderColor() {
    switch (tip.type) {
      case TipType.positive:
        return AppColors.success.withValues(alpha: 0.3);
      case TipType.suggestion:
        return AppColors.info.withValues(alpha: 0.3);
      case TipType.important:
        return AppColors.warning.withValues(alpha: 0.3);
      case TipType.info:
        return AppColors.neutral300;
    }
  }
}

// ============================================================================
// Data Models
// ============================================================================

enum IncomeVariability {
  unknown,
  low, // CV < 15%
  moderate, // CV 15-30%
  high, // CV 30-50%
  veryHigh, // CV > 50%
}

enum TipType {
  positive,
  suggestion,
  important,
  info,
}

class GuidanceTip {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final TipType type;
  final String? actionLabel;

  GuidanceTip({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.type,
    this.actionLabel,
  });
}

class _VariabilityConfig {
  final String label;
  final Color color;
  final IconData icon;
  final int barCount;

  _VariabilityConfig({
    required this.label,
    required this.color,
    required this.icon,
    required this.barCount,
  });
}

// Extension for calculating square root
extension on double {
  double sqrt() {
    if (this < 0) return 0;
    double x = this;
    double y = 1;
    double e = 0.000001; // Precision
    while ((x - y).abs() > e) {
      x = (x + y) / 2;
      y = this / x;
    }
    return x;
  }
}
