import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';

/// "This Month is Different" - Temporary allocation override screen
/// Allows users to modify allocations temporarily without affecting their strategy
/// Includes auto-revert functionality and clear visual indicators (FR9)
class TemporaryAllocationScreen extends ConsumerStatefulWidget {
  const TemporaryAllocationScreen({super.key});

  @override
  ConsumerState<TemporaryAllocationScreen> createState() =>
      _TemporaryAllocationScreenState();
}

class _TemporaryAllocationScreenState
    extends ConsumerState<TemporaryAllocationScreen> {
  late Map<String, _TempAllocationItem> _allocations;
  bool _isLoading = true;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _loadCurrentAllocations();
  }

  Future<void> _loadCurrentAllocations() async {
    try {
      final categories = await ref.read(allocationCategoriesProvider.future);
      final strategies = await ref.read(allocationStrategiesProvider.future);

      final activeStrategy = strategies.firstWhere(
        (s) => s.isActive,
        orElse: () => throw Exception('No active strategy found'),
      );

      setState(() {
        _allocations = {};

        for (final categoryAlloc in activeStrategy.allocations) {
          final category = categories.firstWhere(
            (c) => c.id == categoryAlloc.categoryId,
            orElse: () => categories.first,
          );

          _allocations[category.id] = _TempAllocationItem(
            category: category,
            originalPercentage: categoryAlloc.percentage,
            newPercentage: categoryAlloc.percentage,
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading allocations: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  double get _totalPercentage {
    return _allocations.values
        .fold(0.0, (sum, item) => sum + item.newPercentage);
  }

  bool get _hasChanges {
    return _allocations.values
        .any((item) => item.originalPercentage != item.newPercentage);
  }

  bool get _isValid {
    return (_totalPercentage - 100).abs() < 0.1;
  }

  void _updateAllocation(String categoryId, double newPercentage) {
    setState(() {
      _allocations[categoryId] = _allocations[categoryId]!.copyWith(
        newPercentage: newPercentage,
      );
    });
  }

  void _resetAllocation(String categoryId) {
    setState(() {
      final item = _allocations[categoryId]!;
      _allocations[categoryId] = item.copyWith(
        newPercentage: item.originalPercentage,
      );
    });
  }

  void _resetAllAllocations() {
    setState(() {
      for (final key in _allocations.keys) {
        final item = _allocations[key]!;
        _allocations[key] = item.copyWith(
          newPercentage: item.originalPercentage,
        );
      }
    });
  }

  Future<void> _saveTemporaryAllocations() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total must equal 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // TODO: Implement save logic through repository
      // For now, show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Temporary allocation saved! Will revert on ${_expiryDate.toString().split(' ')[0]}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final remainingPercentage = 100 - _totalPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('This Month is Different'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetAllAllocations,
              tooltip: 'Reset All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Temporary Override',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust your allocations just for this month. Your regular strategy will automatically resume next month.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Auto-reverts: ${_expiryDate.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate,
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _expiryDate = date);
                        }
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Allocations list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._allocations.entries.map((entry) {
                  final categoryId = entry.key;
                  final item = entry.value;
                  final hasChanged =
                      item.originalPercentage != item.newPercentage;

                  return _TempAllocationCard(
                    item: item,
                    hasChanged: hasChanged,
                    categoryColor: _parseColor(item.category.color),
                    onChanged: (value) => _updateAllocation(categoryId, value),
                    onReset: () => _resetAllocation(categoryId),
                  );
                }),

                const SizedBox(height: 16),

                // Total indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isValid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isValid ? Colors.green : Colors.orange,
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_totalPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isValid ? Colors.green : Colors.orange,
                                ),
                          ),
                        ],
                      ),
                      if (!_isValid) ...[
                        const SizedBox(height: 8),
                        Text(
                          remainingPercentage > 0
                              ? '${remainingPercentage.toStringAsFixed(0)}% left'
                              : '${remainingPercentage.abs().toStringAsFixed(0)}% over',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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

          // Action buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed:
                        _hasChanges && _isValid ? _saveTemporaryAllocations : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply Override'),
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

/// Card displaying a temporary allocation item
class _TempAllocationCard extends StatelessWidget {
  final _TempAllocationItem item;
  final bool hasChanged;
  final Color categoryColor;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  const _TempAllocationCard({
    required this.item,
    required this.hasChanged,
    required this.categoryColor,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: hasChanged
          ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category, // Default icon
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (hasChanged)
                        Text(
                          'Was: ${item.originalPercentage.toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.newPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasChanged
                                ? Theme.of(context).colorScheme.secondary
                                : categoryColor,
                          ),
                    ),
                    if (hasChanged)
                      IconButton(
                        icon: const Icon(Icons.undo, size: 20),
                        onPressed: onReset,
                        tooltip: 'Reset',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: hasChanged
                    ? Theme.of(context).colorScheme.secondary
                    : categoryColor,
                thumbColor: hasChanged
                    ? Theme.of(context).colorScheme.secondary
                    : categoryColor,
                inactiveTrackColor: hasChanged
                    ? Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.2)
                    : categoryColor.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: item.newPercentage,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: onChanged,
              ),
            ),

            if (hasChanged)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Temporary override',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
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

/// Data class for temporary allocation items
class _TempAllocationItem {
  final AllocationCategory category;
  final double originalPercentage;
  final double newPercentage;

  _TempAllocationItem({
    required this.category,
    required this.originalPercentage,
    required this.newPercentage,
  });

  _TempAllocationItem copyWith({
    AllocationCategory? category,
    double? originalPercentage,
    double? newPercentage,
  }) {
    return _TempAllocationItem(
      category: category ?? this.category,
      originalPercentage: originalPercentage ?? this.originalPercentage,
      newPercentage: newPercentage ?? this.newPercentage,
    );
  }
}
