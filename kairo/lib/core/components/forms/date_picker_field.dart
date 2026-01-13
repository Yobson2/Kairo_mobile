import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kairo/core/theme/theme.dart';

/// A date picker field that shows a formatted date and opens a date picker on tap
/// Provides consistent styling with AppTextField
///
/// Example:
/// ```dart
/// DatePickerField(
///   selectedDate: _dateOfBirth,
///   label: 'Date of Birth',
///   hint: 'Select your birth date',
///   prefixIcon: Icons.cake_outlined,
///   onDateSelected: (date) => setState(() => _dateOfBirth = date),
///   firstDate: DateTime(1900),
///   lastDate: DateTime.now(),
/// )
/// ```
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? helpText;
  final DateFormat? dateFormat;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  const DatePickerField({
    super.key,
    this.selectedDate,
    this.label,
    this.hint,
    this.prefixIcon,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.helpText,
    this.dateFormat,
    this.validator,
    this.enabled = true,
  });

  /// Date of birth picker with sensible defaults
  factory DatePickerField.dateOfBirth({
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
    String? label,
    String? hint,
  }) {
    final now = DateTime.now();
    return DatePickerField(
      selectedDate: selectedDate,
      label: label ?? 'Date of Birth',
      hint: hint ?? 'Select your date of birth',
      prefixIcon: Icons.cake_outlined,
      onDateSelected: onDateSelected,
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - 13), // Minimum age 13
      initialDate: DateTime(now.year - 25, now.month, now.day),
      helpText: 'Select your date of birth',
      dateFormat: DateFormat('MMM d, yyyy'), // e.g., "Jan 15, 1990"
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.neutral300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
          filled: !enabled,
          fillColor: enabled ? null : AppColors.neutral100,
          errorText: validator != null ? validator!(selectedDate) : null,
        ),
        child: Text(
          selectedDate != null
              ? _formatDate(selectedDate!)
              : hint ?? 'Select a date',
          style: TextStyle(
            color: selectedDate != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : AppColors.neutral600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (dateFormat != null) {
      return dateFormat!.format(date);
    }
    // Default format: "Jan 15, 2024"
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
