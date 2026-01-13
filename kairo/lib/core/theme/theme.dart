/// Centralized theme system exports
///
/// This barrel file exports all theme-related components for easy importing
/// throughout the application.
///
/// Usage:
/// ```dart
/// import 'package:kairo/core/theme/theme.dart';
///
/// // Access colors
/// final color = AppColors.primaryIndigo;
///
/// // Use in MaterialApp
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// );
/// ```
library;

export 'app_colors.dart';
export 'app_theme.dart';
