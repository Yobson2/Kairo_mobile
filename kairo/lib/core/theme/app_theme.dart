import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kairo/core/theme/app_colors.dart';

/// Centralized theme configuration for the Kairo app
/// Implements Material Design 3 principles
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  AppTheme._(); // Private constructor

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      // Primary colors
      primary: AppColors.primaryIndigo,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryIndigo.lighten(0.3),
      onPrimaryContainer: AppColors.primaryIndigo.darken(0.3),

      // Secondary colors
      secondary: AppColors.secondaryPurple,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryPurple.lighten(0.3),
      onSecondaryContainer: AppColors.secondaryPurple.darken(0.3),

      // Tertiary colors
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.infoLight,
      onTertiaryContainer: AppColors.infoDark,

      // Error colors
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,

      // Background colors
      surface: AppColors.backgroundLight,
      onSurface: AppColors.neutral900,
      surfaceContainerHighest: AppColors.surfaceLight,
      onSurfaceVariant: AppColors.neutral600,

      // Outline colors
      outline: AppColors.neutral300,
      outlineVariant: AppColors.neutral200,

      // Other colors
      shadow: AppColors.shadowMedium,
      scrim: AppColors.overlayHeavy,
      inverseSurface: AppColors.neutral800,
      onInverseSurface: AppColors.neutral100,
      inversePrimary: AppColors.primaryIndigo.lighten(0.2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ========================================================================
      // TYPOGRAPHY
      // ========================================================================
      textTheme: _buildTextTheme(colorScheme),

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),

      // ========================================================================
      // CARD THEME
      // ========================================================================
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        margin: const EdgeInsets.all(8),
      ),

      // ========================================================================
      // ELEVATED BUTTON THEME
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================================
      // FILLED BUTTON THEME
      // ========================================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON THEME
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================================
      // TEXT BUTTON THEME
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle: TextStyle(color: colorScheme.error),
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON THEME
      // ========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ========================================================================
      // SNACKBAR THEME
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      // ========================================================================
      // DIALOG THEME
      // ========================================================================
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      // ========================================================================
      // CHIP THEME
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        deleteIconColor: colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ========================================================================
      // DIVIDER THEME
      // ========================================================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // ICON THEME
      // ========================================================================
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // ========================================================================
      // LIST TILE THEME
      // ========================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),

      // ========================================================================
      // BOTTOM SHEET THEME
      // ========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        elevation: 3,
      ),

      // ========================================================================
      // PROGRESS INDICATOR THEME
      // ========================================================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      // Primary colors
      primary: AppColors.primaryIndigo.lighten(0.1),
      onPrimary: AppColors.neutral900,
      primaryContainer: AppColors.primaryIndigo.darken(0.2),
      onPrimaryContainer: AppColors.primaryIndigo.lighten(0.4),

      // Secondary colors
      secondary: AppColors.secondaryPurple.lighten(0.1),
      onSecondary: AppColors.neutral900,
      secondaryContainer: AppColors.secondaryPurple.darken(0.2),
      onSecondaryContainer: AppColors.secondaryPurple.lighten(0.4),

      // Tertiary colors
      tertiary: AppColors.infoLight,
      onTertiary: AppColors.neutral900,
      tertiaryContainer: AppColors.infoDark,
      onTertiaryContainer: AppColors.infoLight,

      // Error colors
      error: AppColors.errorLight,
      onError: AppColors.neutral900,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,

      // Background colors
      surface: AppColors.backgroundDark,
      onSurface: AppColors.neutral100,
      surfaceContainerHighest: AppColors.surfaceDark,
      onSurfaceVariant: AppColors.neutral400,

      // Outline colors
      outline: AppColors.neutral700,
      outlineVariant: AppColors.neutral800,

      // Other colors
      shadow: AppColors.shadowHeavy,
      scrim: AppColors.overlayHeavy,
      inverseSurface: AppColors.neutral100,
      onInverseSurface: AppColors.neutral900,
      inversePrimary: AppColors.primaryIndigo.darken(0.2),
    );

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: lightTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      dialogTheme: lightTheme.dialogTheme.copyWith(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      bottomSheetTheme: lightTheme.bottomSheetTheme.copyWith(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),
    );
  }

  // ============================================================================
  // TEXT THEME BUILDER
  // ============================================================================

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }
}
