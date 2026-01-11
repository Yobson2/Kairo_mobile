import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/providers/auto_save_provider.dart';
import 'package:kairo/core/services/auto_save_service.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';
import 'package:intl/intl.dart';

/// Standalone income entry screen
/// Implements Story 2.3: Income Entry Screen
class IncomeEntryScreen extends ConsumerStatefulWidget {
  final IncomeEntry? existingEntry; // For editing

  const IncomeEntryScreen({
    super.key,
    this.existingEntry,
  });

  @override
  ConsumerState<IncomeEntryScreen> createState() => _IncomeEntryScreenState();
}

class _IncomeEntryScreenState extends ConsumerState<IncomeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late DateTime _selectedDate;
  late IncomeType _selectedIncomeType;
  late IncomeSource _selectedIncomeSource;
  late String _selectedCurrency;
  String _description = '';

  @override
  void initState() {
    super.initState();
    // Initialize with existing entry or defaults
    if (widget.existingEntry != null) {
      _amountController.text = widget.existingEntry!.amount.toStringAsFixed(2);
      _selectedDate = widget.existingEntry!.incomeDate;
      _selectedIncomeType = widget.existingEntry!.incomeType;
      _selectedIncomeSource = widget.existingEntry!.incomeSource ?? IncomeSource.other;
      _selectedCurrency = widget.existingEntry!.currency;
      _description = widget.existingEntry!.description ?? '';
    } else {
      _selectedDate = DateTime.now();
      _selectedIncomeType = IncomeType.variable;
      _selectedIncomeSource = IncomeSource.cash;
      _selectedCurrency = 'KES'; // Default to KES
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Income Date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

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

    final amount = double.parse(_amountController.text);

    // Use auto-save service
    final autoSave = ref.read(autoSaveServiceProvider);

    try {
      await autoSave.saveImmediately(() async {
        final incomeEntry = IncomeEntry(
          id: widget.existingEntry?.id ?? '',
          userId: currentUser.id,
          amount: amount,
          currency: _selectedCurrency,
          incomeDate: _selectedDate,
          incomeType: _selectedIncomeType,
          incomeSource: _selectedIncomeSource,
          description: _description.isEmpty ? null : _description,
          createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save via providers
        if (widget.existingEntry != null) {
          // Update existing entry
          await ref.read(updateIncomeEntryProvider.notifier).execute(incomeEntry);
        } else {
          // Create new entry
          await ref.read(createIncomeEntryProvider.notifier).execute(incomeEntry);
        }
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingEntry != null
                ? 'Income updated successfully'
                : 'Income added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save income: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoSaveStatus = ref.watch(autoSaveStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry != null ? 'Edit Income' : 'Add Income'),
        actions: [
          if (autoSaveStatus.showIndicator)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (autoSaveStatus == SaveStatus.saving)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    if (autoSaveStatus == SaveStatus.saved)
                      const Icon(Icons.check, color: Colors.green),
                    if (autoSaveStatus == SaveStatus.error)
                      const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      autoSaveStatus.message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Enter your income details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: _getCurrencySymbol(_selectedCurrency),
                  border: const OutlineInputBorder(),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Currency selector
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'KES', child: Text('KES - Kenyan Shilling')),
                  DropdownMenuItem(value: 'NGN', child: Text('NGN - Nigerian Naira')),
                  DropdownMenuItem(value: 'GHS', child: Text('GHS - Ghanaian Cedi')),
                  DropdownMenuItem(value: 'ZAR', child: Text('ZAR - South African Rand')),
                  DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Income Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Income type selector
              Text(
                'Income Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildIncomeTypeSelector(),
              const SizedBox(height: 24),

              // Income source selector
              Text(
                'Income Source',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildIncomeSourceSelector(),
              const SizedBox(height: 24),

              // Description (optional)
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Freelance project, Monthly salary',
                ),
                maxLines: 2,
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              const SizedBox(height: 32),

              // Save button
              FilledButton.icon(
                onPressed: _saveIncome,
                icon: const Icon(Icons.save),
                label: Text(widget.existingEntry != null ? 'Update Income' : 'Add Income'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeTypeSelector() {
    return SegmentedButton<IncomeType>(
      segments: const [
        ButtonSegment(
          value: IncomeType.fixed,
          label: Text('Fixed'),
          icon: Icon(Icons.attach_money),
        ),
        ButtonSegment(
          value: IncomeType.variable,
          label: Text('Variable'),
          icon: Icon(Icons.trending_up),
        ),
        ButtonSegment(
          value: IncomeType.mixed,
          label: Text('Mixed'),
          icon: Icon(Icons.compare_arrows),
        ),
      ],
      selected: {_selectedIncomeType},
      onSelectionChanged: (Set<IncomeType> newSelection) {
        setState(() {
          _selectedIncomeType = newSelection.first;
        });
      },
    );
  }

  Widget _buildIncomeSourceSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: IncomeSource.values.map((source) {
        final isSelected = _selectedIncomeSource == source;
        return FilterChip(
          label: Text(_getIncomeSourceLabel(source)),
          avatar: Icon(_getIncomeSourceIcon(source), size: 18),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedIncomeSource = source;
            });
          },
        );
      }).toList(),
    );
  }

  String _getIncomeSourceLabel(IncomeSource source) {
    switch (source) {
      case IncomeSource.cash:
        return 'Cash';
      case IncomeSource.mobileMoney:
        return 'Mobile Money';
      case IncomeSource.formalSalary:
        return 'Formal Salary';
      case IncomeSource.gigIncome:
        return 'Gig Income';
      case IncomeSource.other:
        return 'Other';
    }
  }

  IconData _getIncomeSourceIcon(IncomeSource source) {
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
