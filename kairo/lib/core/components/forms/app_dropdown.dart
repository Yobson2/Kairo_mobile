import 'package:flutter/material.dart';
import 'package:kairo/core/theme/theme.dart';

/// A standardized dropdown field component with consistent styling
/// Simplifies dropdown creation with type safety and common patterns
///
/// Example:
/// ```dart
/// AppDropdown<String>(
///   value: _selectedGender,
///   label: 'Gender',
///   hint: 'Select your gender',
///   prefixIcon: Icons.wc_outlined,
///   items: ['Male', 'Female', 'Other', 'Prefer not to say'],
///   itemBuilder: (value) => Text(value),
///   onChanged: (value) => setState(() => _selectedGender = value),
/// )
/// ```
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.value,
    this.label,
    this.hint,
    this.prefixIcon,
    required this.items,
    required this.itemBuilder,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.neutral100,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: itemBuilder(item),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
    );
  }
}

/// Dropdown with simple string items
class AppSimpleDropdown extends StatelessWidget {
  final String? value;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final List<String> items;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;

  const AppSimpleDropdown({
    super.key,
    this.value,
    this.label,
    this.hint,
    this.prefixIcon,
    required this.items,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      value: value,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      items: items,
      itemBuilder: (item) => Text(item),
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      enabled: enabled,
    );
  }
}

/// Dropdown with label-value pairs
class AppLabeledDropdown<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Map<T, String> items; // value -> display label
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final bool enabled;

  const AppLabeledDropdown({
    super.key,
    this.value,
    this.label,
    this.hint,
    this.prefixIcon,
    required this.items,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdown<T>(
      value: value,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      items: items.keys.toList(),
      itemBuilder: (item) => Text(items[item] ?? ''),
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      enabled: enabled,
    );
  }
}
