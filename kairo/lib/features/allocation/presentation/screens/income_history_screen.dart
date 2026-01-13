import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/allocation/presentation/screens/income_entry_screen.dart';
import 'package:intl/intl.dart';

/// Income history screen showing all income entries
/// Implements Story 4.1: Income History View
class IncomeHistoryScreen extends ConsumerStatefulWidget {
  const IncomeHistoryScreen({super.key});

  @override
  ConsumerState<IncomeHistoryScreen> createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends ConsumerState<IncomeHistoryScreen> {
  IncomeType? _filterType;
  IncomeSource? _filterSource;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final incomeEntriesAsync = ref.watch(incomeEntriesProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: incomeEntriesAsync.when(
        data: (entries) {
          // Apply filters
          final filteredEntries = _applyFilters(entries);

          if (filteredEntries.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate total
          final totalIncome = filteredEntries.fold<double>(
            0.0,
            (sum, entry) => sum + entry.amount,
          );

          return Column(
            children: [
              // Summary card
              _buildSummaryCard(filteredEntries.length, totalIncome),

              // Income list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(incomeEntriesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      return _buildIncomeCard(filteredEntries[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading income history'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(incomeEntriesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/dashboard/income/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
    );
  }

  List<IncomeEntry> _applyFilters(List<IncomeEntry> entries) {
    var filtered = entries;

    // Filter by type
    if (_filterType != null) {
      filtered = filtered.where((e) => e.incomeType == _filterType).toList();
    }

    // Filter by source
    if (_filterSource != null) {
      filtered = filtered.where((e) => e.incomeSource == _filterSource).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((e) => e.incomeDate.isAfter(_startDate!) || e.incomeDate.isAtSameMomentAs(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((e) => e.incomeDate.isBefore(_endDate!) || e.incomeDate.isAtSameMomentAs(_endDate!)).toList();
    }

    // Sort by date descending (newest first)
    filtered.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));

    return filtered;
  }

  Widget _buildSummaryCard(int count, double total) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 1 ? 'Entry' : 'Entries',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.neutral300,
            ),
            Column(
              children: [
                Text(
                  'KSh ${NumberFormat('#,##0.00').format(total)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Income',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(IncomeEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getIncomeTypeColor(entry.incomeType).withValues(alpha: 0.2),
          child: Icon(
            _getIncomeSourceIcon(entry.incomeSource),
            color: _getIncomeTypeColor(entry.incomeType),
          ),
        ),
        title: Text(
          '${_getCurrencySymbol(entry.currency)}${NumberFormat('#,##0.00').format(entry.amount)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat('MMMM dd, yyyy').format(entry.incomeDate)),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip(
                  _getIncomeTypeLabel(entry.incomeType),
                  _getIncomeTypeColor(entry.incomeType),
                ),
                const SizedBox(width: 8),
                if (entry.incomeSource != null)
                  _buildChip(
                    entry.incomeSource!.label,
                    AppColors.neutral500,
                  ),
              ],
            ),
            if (entry.description != null && entry.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.description!,
                style: TextStyle(
                  color: AppColors.neutral600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editIncome(entry);
            } else if (value == 'delete') {
              _deleteIncome(entry);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No income entries yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your income to see your allocation insights',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.go('/dashboard/income/new');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Income'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Income'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income Type filter
                  const Text('Income Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterType == null,
                        onSelected: (selected) {
                          setDialogState(() => _filterType = null);
                        },
                      ),
                      ...IncomeType.values.map((type) => FilterChip(
                            label: Text(_getIncomeTypeLabel(type)),
                            selected: _filterType == type,
                            onSelected: (selected) {
                              setDialogState(() => _filterType = selected ? type : null);
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Income Source filter
                  const Text('Income Source', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterSource == null,
                        onSelected: (selected) {
                          setDialogState(() => _filterSource = null);
                        },
                      ),
                      ...IncomeSource.values.map((source) => FilterChip(
                            label: Text(source.label),
                            selected: _filterSource == source,
                            onSelected: (selected) {
                              setDialogState(() => _filterSource = selected ? source : null);
                            },
                          )),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterType = null;
                _filterSource = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {}); // Apply filters
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _editIncome(IncomeEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomeEntryScreen(existingEntry: entry),
      ),
    );
  }

  Future<void> _deleteIncome(IncomeEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income Entry'),
        content: Text(
          'Are you sure you want to delete this income entry of ${_getCurrencySymbol(entry.currency)}${NumberFormat('#,##0.00').format(entry.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteIncomeEntryProvider.notifier).execute(entry.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income entry deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  // Helper methods
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

  Color _getIncomeTypeColor(IncomeType type) {
    switch (type) {
      case IncomeType.fixed:
        return AppColors.info;
      case IncomeType.variable:
        return AppColors.warning;
      case IncomeType.mixed:
        return AppColors.neutral500;
    }
  }

  IconData _getIncomeSourceIcon(IncomeSource? source) {
    if (source == null) return Icons.attach_money;
    switch (source) {
      case IncomeSource.cash:
        return Icons.money;
      case IncomeSource.mobileMoney:
        return Icons.phone_android;
      case IncomeSource.formalSalary:
        return Icons.account_balance;
      case IncomeSource.gigIncome:
        return Icons.work_outline;
      case IncomeSource.other:
        return Icons.more_horiz;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KSh ';
      case 'NGN':
        return '₦';
      case 'GHS':
        return 'GH₵ ';
      case 'ZAR':
        return 'R ';
      case 'USD':
        return '\$ ';
      default:
        return '';
    }
  }
}
