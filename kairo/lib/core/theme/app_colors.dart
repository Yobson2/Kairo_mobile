import 'package:flutter/material.dart';

/// Centralized color system for the Kairo app
/// Follows Material Design 3 principles with semantic color naming
///
/// Usage:
/// ```dart
/// // In widgets - prefer using theme colors
/// color: Theme.of(context).colorScheme.primary
///
/// // For semantic colors
/// color: AppColors.success
///
/// // For category/allocation colors
/// color: AppColors.categoryColors[index]
/// ```
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  /// Primary brand color - Indigo
  /// Used for: Primary buttons, app bar, key UI elements
  static const Color primaryIndigo = Color(0xFF6366F1);

  /// Secondary brand color - Purple
  /// Used for: Accent elements, highlights
  static const Color secondaryPurple = Color(0xFF8B5CF6);

  // ============================================================================
  // SEMANTIC COLORS (Status & Feedback)
  // ============================================================================

  /// Success color - Green
  /// Used for: Success messages, positive actions, income
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF059669);

  /// Error color - Red
  /// Used for: Error messages, destructive actions, validation errors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning color - Amber
  /// Used for: Warning messages, caution indicators
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  /// Info color - Blue
  /// Used for: Info messages, helpful hints, informational UI
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================================================
  // NEUTRAL COLORS (Grays)
  // ============================================================================

  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============================================================================
  // CATEGORY/ALLOCATION COLORS
  // Used for: Budget categories, allocation charts, strategy colors
  // ============================================================================

  static const Color categoryRed = Color(0xFFEF4444);
  static const Color categoryOrange = Color(0xFFF97316);
  static const Color categoryAmber = Color(0xFFF59E0B);
  static const Color categoryGreen = Color(0xFF10B981);
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryPink = Color(0xFFEC4899);
  static const Color categoryGray = Color(0xFF6B7280);
  static const Color categoryCyan = Color(0xFF06B6D4);
  static const Color categoryTeal = Color(0xFF14B8A6);

  /// List of all category colors for iteration
  static const List<Color> categoryColors = [
    categoryRed,
    categoryOrange,
    categoryAmber,
    categoryGreen,
    categoryBlue,
    categoryPurple,
    categoryPink,
    categoryGray,
    categoryCyan,
    categoryTeal,
  ];

  /// Hex strings for category colors (for database storage)
  static const List<String> categoryColorHexes = [
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#10B981', // Green
    '#3B82F6', // Blue
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#6B7280', // Gray
    '#06B6D4', // Cyan
    '#14B8A6', // Teal
  ];

  // ============================================================================
  // SURFACE COLORS (Backgrounds, Cards, Containers)
  // ============================================================================

  /// Background colors for light mode
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  /// Background colors for dark mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // ============================================================================
  // OVERLAY & SHADOW COLORS
  // ============================================================================

  /// Black overlay with various alpha values
  static Color overlayLight = Colors.black.withValues(alpha: 0.05);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.1);
  static Color overlayHeavy = Colors.black.withValues(alpha: 0.5);

  /// Shadow colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.1);
  static Color shadowHeavy = Colors.black.withValues(alpha: 0.15);

  // ============================================================================
  // SOCIAL AUTH COLORS
  // ============================================================================

  /// Google sign-in colors
  static const Color googleBackground = Color(0xFFFFFFFF);
  static const Color googleForeground = Color(0xFF1F1F1F);
  static const Color googleBorder = Color(0xFFDADCE0);

  /// Apple sign-in colors
  static const Color appleBackground = Color(0xFF000000);
  static const Color appleForeground = Color(0xFFFFFFFF);

  // ============================================================================
  // SPECIAL PURPOSE COLORS
  // ============================================================================

  /// Disabled state colors
  static Color disabledBackground = neutral100;
  static Color disabledForeground = neutral400;

  /// Focus/Hover state colors
  static Color focusColor = primaryIndigo.withValues(alpha: 0.12);
  static Color hoverColor = primaryIndigo.withValues(alpha: 0.08);

  /// Divider color
  static Color divider = neutral200;
  static Color dividerDark = neutral700;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get a category color by index (cycles through available colors)
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// Get a category color hex by index (cycles through available hex values)
  static String getCategoryColorHex(int index) {
    return categoryColorHexes[index % categoryColorHexes.length];
  }

  /// Parse hex color string to Color object
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String toHex(Color color) {
    final r = color.r.toInt().toRadixString(16).padLeft(2, '0');
    final g = color.g.toInt().toRadixString(16).padLeft(2, '0');
    final b = color.b.toInt().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// Get a lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get a darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get color with alpha/opacity
  static Color withAlpha(Color color, double alpha) {
    assert(alpha >= 0 && alpha <= 1);
    return color.withValues(alpha: alpha);
  }
}

/// Extension methods for Color manipulation
extension ColorExtensions on Color {
  /// Get a lighter shade of this color
  Color lighten([double amount = 0.1]) => AppColors.lighten(this, amount);

  /// Get a darker shade of this color
  Color darken([double amount = 0.1]) => AppColors.darken(this, amount);

  /// Convert to hex string
  String toHex() => AppColors.toHex(this);

  /// Create color with specific alpha value (0.0 - 1.0)
  Color withAlpha(double alpha) => AppColors.withAlpha(this, alpha);
}
