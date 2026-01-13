import 'package:flutter/material.dart';
import 'package:kairo/core/utils/constants.dart';

/// A reusable section header with icon and title
/// Used to visually separate sections in forms and screens
///
/// Example:
/// ```dart
/// SectionHeader(
///   icon: Icons.person_outline,
///   title: 'Personal Information',
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final double? iconSize;
  final TextStyle? textStyle;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          icon,
          size: iconSize ?? 20,
          color: effectiveColor,
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Text(
          title,
          style: textStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectiveColor,
                  ),
        ),
      ],
    );
  }
}
