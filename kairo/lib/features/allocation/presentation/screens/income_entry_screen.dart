import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/utils.dart';
import 'package:kairo/core/providers/auto_save_provider.dart';
import 'package:kairo/core/services/auto_save_service.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/presentation/providers/allocation_providers.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

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


  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      if (!mounted) return;
      context.showErrorSnackBar('Please sign in first');
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
      context.showSuccessSnackBar(
        widget.existingEntry != null
            ? 'Income updated successfully'
            : 'Income added successfully',
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to save income: $e');
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
                padding: const EdgeInsets.only(right: AppSizes.paddingMedium),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (autoSaveStatus == SaveStatus.saving)
                      const SizedBox(
                        width: AppSizes.paddingMedium,
                        height: AppSizes.paddingMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    if (autoSaveStatus == SaveStatus.saved)
                      const Icon(Icons.check, color: AppColors.success),
                    if (autoSaveStatus == SaveStatus.error)
                      const Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: AppSizes.paddingSmall),
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
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
              const SizedBox(height: AppSizes.paddingLarge),

              // Amount input
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: AppValidators.positiveNumber,
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              // Currency selector
              AppSimpleDropdown(
                value: _selectedCurrency,
                label: 'Currency',
                prefixIcon: Icons.currency_exchange,
                items: AppDefaults.supportedCurrencies,
                onChanged: (value) => setState(() => _selectedCurrency = value!),
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              // Date picker
              DatePickerField(
                selectedDate: _selectedDate,
                label: 'Income Date',
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // Income type selector
              Text(
                'Income Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildIncomeTypeSelector(),
              const SizedBox(height: AppSizes.paddingLarge),

              // Income source selector
              Text(
                'Income Source',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildIncomeSourceSelector(),
              const SizedBox(height: AppSizes.paddingLarge),

              // Description (optional)
              AppTextField(
                initialValue: _description,
                label: 'Description (Optional)',
                hint: 'e.g., Freelance project, Monthly salary',
                prefixIcon: Icons.notes,
                maxLines: 2,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: AppSizes.paddingXLarge),

              // Save button
              AppButton.primary(
                onPressed: _saveIncome,
                label: widget.existingEntry != null ? 'Update Income' : 'Add Income',
                icon: Icons.save,
                isFullWidth: true,
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
      spacing: AppSizes.paddingSmall,
      runSpacing: AppSizes.paddingSmall,
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

}
