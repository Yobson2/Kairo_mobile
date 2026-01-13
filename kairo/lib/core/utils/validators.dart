import 'constants.dart';

/// Common form validators
/// Provides reusable validation logic for forms across the app
class AppValidators {
  /// Validates required fields
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email addresses
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppValidation.minPasswordLength) {
      return 'Password must be at least ${AppValidation.minPasswordLength} characters';
    }

    if (value.length > AppValidation.maxPasswordLength) {
      return 'Password must be less than ${AppValidation.maxPasswordLength} characters';
    }

    // Optional: Add more password strength requirements
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase letter';
    // }

    return null;
  }

  /// Validates name fields
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < AppValidation.minNameLength) {
      return '$fieldName must be at least ${AppValidation.minNameLength} characters';
    }

    if (value.trim().length > AppValidation.maxNameLength) {
      return '$fieldName must be less than ${AppValidation.maxNameLength} characters';
    }

    return null;
  }

  /// Validates phone numbers (basic validation)
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates numeric input
  static String? number(
    String? value, {
    String fieldName = 'This field',
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }

    return null;
  }

  /// Validates positive numbers (for amounts, percentages, etc.)
  static String? positiveNumber(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  /// Validates percentage (0-100)
  static String? percentage(String? value) {
    final result = number(
      value,
      fieldName: 'Percentage',
      min: 0,
      max: 100,
    );
    return result;
  }

  /// Validates date of birth
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (age < AppValidation.minAge) {
      return 'You must be at least ${AppValidation.minAge} years old';
    }

    if (age > AppValidation.maxAge) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates that two fields match (e.g., password confirmation)
  static String? matchesField(String? value, String? otherValue, String fieldName) {
    if (value != otherValue) {
      return '$fieldName does not match';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int length, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < length) {
      return '$fieldName must be at least $length characters';
    }

    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int length, {String fieldName = 'This field'}) {
    if (value != null && value.length > length) {
      return '$fieldName must be less than $length characters';
    }

    return null;
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
