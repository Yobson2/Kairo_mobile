/// Application-wide constants
/// Centralizes magic numbers and reusable values
library;

/// Spacing and sizing constants
class AppSizes {
  // Padding & Margins
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusCircular = 999.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Card Elevation
  static const double elevationLow = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationHigh = 4.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;
}

/// Duration constants for animations and delays
class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // UI Feedback
  static const Duration snackBarShort = Duration(seconds: 2);
  static const Duration snackBarMedium = Duration(seconds: 3);
  static const Duration snackBarLong = Duration(seconds: 4);

  // Screen Delays
  static const Duration splashScreen = Duration(seconds: 3);
  static const Duration autoSaveDebounce = Duration(milliseconds: 500);
}

/// Color constants - DEPRECATED
/// Use AppColors from 'package:kairo/core/theme/theme.dart' instead
@Deprecated('Use AppColors from core/theme/theme.dart')
class LegacyAppColors {
  // Status Colors - Use AppColors.success, AppColors.error, etc.
  static const int successHex = 0xFF10B981;
  static const int errorHex = 0xFFEF4444;
  static const int warningHex = 0xFFF59E0B;
  static const int infoHex = 0xFF3B82F6;

  // Category Colors - Use AppColors.categoryColors instead
  static const List<String> categoryColors = [
    '#EF4444', '#F97316', '#F59E0B', '#10B981',
    '#3B82F6', '#8B5CF6', '#EC4899', '#6B7280',
  ];
}

/// Text size constants
class AppTextSizes {
  static const double tiny = 10.0;
  static const double small = 12.0;
  static const double body = 14.0;
  static const double bodyLarge = 16.0;
  static const double title = 18.0;
  static const double titleLarge = 20.0;
  static const double headline = 24.0;
  static const double headlineLarge = 32.0;
}

/// Form validation constants
class AppValidation {
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int minAge = 13;
  static const int maxAge = 120;
}

/// API and data constants
class AppDefaults {
  static const String defaultCurrency = 'KES';
  static const String defaultLanguage = 'en';

  static const List<String> supportedCurrencies = [
    'KES', // Kenyan Shilling
    'NGN', // Nigerian Naira
    'GHS', // Ghanaian Cedi
    'ZAR', // South African Rand
    'USD', // US Dollar
    'EUR', // Euro
  ];

  static const Map<String, String> currencySymbols = {
    'KES': 'KSh ',
    'NGN': '₦',
    'GHS': 'GH₵ ',
    'ZAR': 'R ',
    'USD': '\$ ',
    'EUR': '€ ',
  };
}

/// Asset paths
class AppAssets {
  // Add your asset paths here when needed
  // static const String logo = 'assets/images/logo.png';
  // static const String placeholder = 'assets/images/placeholder.png';
}

/// Route names (if using named routes)
class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String createStrategy = '/allocation/create-strategy';
  static const String incomeEntry = '/allocation/income-entry';
  static const String categories = '/allocation/categories';
}
