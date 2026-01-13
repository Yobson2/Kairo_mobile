import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';

/// Income visualization chart for history tracking (FR4.1)
/// Shows income trends over time with line chart
class IncomeChart extends StatelessWidget {
  final List<IncomeEntry> incomeHistory;
  final String currency;
  final ChartType chartType;
  final int monthsToShow;

  const IncomeChart({
    super.key,
    required this.incomeHistory,
    required this.currency,
    this.chartType = ChartType.line,
    this.monthsToShow = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (incomeHistory.isEmpty) {
      return _EmptyChart();
    }

    final chartData = _prepareChartData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Income Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _ChartTypeToggle(
              currentType: chartType,
              onTypeChanged: (type) {
                // TODO: Implement chart type switching
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          height: 200,
          child: chartType == ChartType.line
              ? _LineChart(data: chartData, currency: currency)
              : _BarChart(data: chartData, currency: currency),
        ),

        const SizedBox(height: 16),

        // Statistics
        _ChartStatistics(
          incomeHistory: incomeHistory,
          currency: currency,
        ),
      ],
    );
  }

  List<ChartDataPoint> _prepareChartData() {
    // Group income by month
    final monthlyData = <DateTime, double>{};

    for (final entry in incomeHistory) {
      final month = DateTime(entry.incomeDate.year, entry.incomeDate.month);
      monthlyData[month] = (monthlyData[month] ?? 0) + entry.amount;
    }

    // Sort by date and take last N months
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final recentEntries = sortedEntries.take(monthsToShow).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return recentEntries
        .map((entry) => ChartDataPoint(
              date: entry.key,
              value: entry.value,
            ))
        .toList();
  }
}

/// Line chart widget
class _LineChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String currency;

  const _LineChart({
    required this.data,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce(math.max);
    final minValue = data.map((d) => d.value).reduce(math.min);

    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(
          data: data,
          maxValue: maxValue,
          minValue: minValue,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Max value
              Text(
                _formatAmount(maxValue, currency),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
              const Spacer(),
              // Min value
              Text(
                _formatAmount(minValue, currency),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(0)}';
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

/// Line chart painter
class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double maxValue;
  final double minValue;
  final Color color;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final range = maxValue - minValue;
    if (range == 0) return;

    // Paint setup
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate points
    final points = <Offset>[];
    final padding = 32.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height - padding - (normalizedValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw filled area
    final fillPath = Path();
    if (points.isNotEmpty) {
      fillPath.moveTo(points.first.dx, size.height - padding);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, size.height - padding);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    final linePath = Path();
    if (points.isNotEmpty) {
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(
          point, 6, Paint()..color = AppColors.backgroundLight..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => false;
}

/// Bar chart widget
class _BarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String currency;

  const _BarChart({
    required this.data,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((point) {
        final height = (point.value / maxValue) * 160;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMonthLabel(point.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMonthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[date.month - 1];
  }
}

/// Chart statistics
class _ChartStatistics extends StatelessWidget {
  final List<IncomeEntry> incomeHistory;
  final String currency;

  const _ChartStatistics({
    required this.incomeHistory,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Average',
            value: _formatAmount(stats.average, currency),
            icon: Icons.show_chart,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Highest',
            value: _formatAmount(stats.highest, currency),
            icon: Icons.trending_up,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Lowest',
            value: _formatAmount(stats.lowest, currency),
            icon: Icons.trending_down,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  IncomeStatistics _calculateStatistics() {
    if (incomeHistory.isEmpty) {
      return IncomeStatistics(average: 0, highest: 0, lowest: 0);
    }

    final amounts = incomeHistory.map((e) => e.amount).toList();
    final sum = amounts.reduce((a, b) => a + b);
    final average = sum / amounts.length;
    final highest = amounts.reduce(math.max);
    final lowest = amounts.reduce(math.min);

    return IncomeStatistics(
      average: average,
      highest: highest,
      lowest: lowest,
    );
  }

  String _formatAmount(double amount, String currency) {
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(0)}';
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

/// Stat card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

/// Chart type toggle
class _ChartTypeToggle extends StatelessWidget {
  final ChartType currentType;
  final ValueChanged<ChartType> onTypeChanged;

  const _ChartTypeToggle({
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ChartType>(
      segments: const [
        ButtonSegment(
          value: ChartType.line,
          icon: Icon(Icons.show_chart, size: 16),
        ),
        ButtonSegment(
          value: ChartType.bar,
          icon: Icon(Icons.bar_chart, size: 16),
        ),
      ],
      selected: {currentType},
      onSelectionChanged: (selected) => onTypeChanged(selected.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Empty chart state
class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined,
                size: 48, color: AppColors.neutral400),
            const SizedBox(height: 12),
            Text(
              'Add income entries to see trends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Data Models
// ============================================================================

enum ChartType { line, bar }

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}

class IncomeStatistics {
  final double average;
  final double highest;
  final double lowest;

  IncomeStatistics({
    required this.average,
    required this.highest,
    required this.lowest,
  });
}
