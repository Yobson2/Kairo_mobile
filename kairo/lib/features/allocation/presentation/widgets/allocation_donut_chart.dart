import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';

/// Donut chart visualization for allocation breakdown (FR8)
/// Shows visual representation of money allocation across categories
class AllocationDonutChart extends StatelessWidget {
  final List<AllocationCategoryData> allocations;
  final double totalAmount;
  final String currency;
  final double size;

  const AllocationDonutChart({
    super.key,
    required this.allocations,
    required this.totalAmount,
    required this.currency,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Donut chart
        SizedBox(
          width: size,
          height: size,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DonutChartPainter(
                allocations: allocations,
                strokeWidth: size * 0.15,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getCurrencySymbol(currency),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                    Text(
                      totalAmount.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Allocated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: allocations.map((allocation) {
            return _LegendItem(
              color: allocation.color,
              label: allocation.category.name,
              percentage: allocation.percentage,
              amount: allocation.amount,
              currency: currency,
            );
          }).toList(),
        ),
      ],
    );
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

/// Custom painter for donut chart
class _DonutChartPainter extends CustomPainter {
  final List<AllocationCategoryData> allocations;
  final double strokeWidth;

  _DonutChartPainter({
    required this.allocations,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -math.pi / 2; // Start at top

    for (final allocation in allocations) {
      final sweepAngle = (allocation.percentage / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = allocation.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.allocations != allocations ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Legend item for chart
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percentage;
  final double amount;
  final String currency;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}% · ${_getCurrencySymbol(currency)}${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
            ),
          ],
        ),
      ],
    );
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

/// Data class for allocation category visualization
class AllocationCategoryData {
  final AllocationCategory category;
  final double percentage;
  final double amount;
  final Color color;

  AllocationCategoryData({
    required this.category,
    required this.percentage,
    required this.amount,
    required this.color,
  });
}
