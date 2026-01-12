import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Global error handler for the Kairo app
/// Handles both Flutter errors and async errors
class ErrorHandler {
  static bool _isInitialized = false;

  /// Initialize the global error handler
  static Future<void> initialize({
    required String sentryDsn,
    required String environment,
    bool enableInDevMode = false,
  }) async {
    if (_isInitialized) return;

    // Only enable Sentry in production or if explicitly enabled in dev
    final shouldEnableSentry =
        (kReleaseMode || enableInDevMode) && sentryDsn.isNotEmpty;

    if (shouldEnableSentry) {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.environment = environment;
          options.tracesSampleRate = environment == 'production' ? 0.2 : 1.0;
          options.enableAutoSessionTracking = true;
          options.attachStacktrace = true;
          options.attachScreenshot = true;
          options.sendDefaultPii = false; // Don't send PII for privacy

          // Filter out sensitive data
          options.beforeSend = (event, hint) {
            // Remove any potentially sensitive data from breadcrumbs
            if (event.breadcrumbs != null) {
              event = event.copyWith(
                breadcrumbs: event.breadcrumbs!
                    .where((crumb) => !_isSensitiveBreadcrumb(crumb))
                    .toList(),
              );
            }
            return event;
          };
        },
      );
    }

    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      // Report to Sentry
      if (shouldEnableSentry) {
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
          hint: Hint.withMap({
            'context': details.context?.toString() ?? 'Unknown',
          }),
        );
      }
    };

    // Set up async error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('Async error: $error\n$stack');
      }

      if (shouldEnableSentry) {
        Sentry.captureException(error, stackTrace: stack);
      }

      return true;
    };

    _isInitialized = true;
  }

  /// Check if a breadcrumb contains sensitive information
  static bool _isSensitiveBreadcrumb(Breadcrumb crumb) {
    final message = crumb.message?.toLowerCase() ?? '';
    final category = crumb.category?.toLowerCase() ?? '';

    // Filter out authentication, password, token, etc.
    final sensitiveKeywords = [
      'password',
      'token',
      'auth',
      'secret',
      'api_key',
      'credential',
      'email',
      'phone',
    ];

    return sensitiveKeywords.any(
      (keyword) => message.contains(keyword) || category.contains(keyword),
    );
  }

  /// Manually report an error
  static Future<void> reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    if (kDebugMode) {
      debugPrint('Error reported: $error\n$stackTrace');
      if (context != null) debugPrint('Context: $context');
      if (extras != null) debugPrint('Extras: $extras');
    }

    if (_isInitialized && !kDebugMode) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          if (context != null) 'context': context,
          if (extras != null) ...extras,
        }),
      );
    }
  }

  /// Report a message (non-error)
  static Future<void> reportMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) async {
    if (kDebugMode) {
      debugPrint('[$level] $message');
      if (extras != null) debugPrint('Extras: $extras');
    }

    if (_isInitialized && !kDebugMode) {
      await Sentry.captureMessage(
        message,
        level: level,
        hint: Hint.withMap(extras ?? {}),
      );
    }
  }

  /// Set user context for error reporting
  static Future<void> setUser({
    required String id,
    String? email,
    Map<String, dynamic>? extras,
  }) async {
    if (_isInitialized) {
      await Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: id,
            email: email,
            data: extras,
          ),
        );
      });
    }
  }

  /// Clear user context
  static Future<void> clearUser() async {
    if (_isInitialized) {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    }
  }

  /// Add breadcrumb for debugging
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    if (_isInitialized) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data,
          level: level,
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}

/// Extension on common exceptions for user-friendly messages
extension ErrorExtension on Object {
  /// Get a user-friendly error message
  String get userFriendlyMessage {
    if (this is Exception) {
      final exception = this as Exception;
      return _getExceptionMessage(exception);
    }
    return 'Something went wrong. Please try again.';
  }

  String _getExceptionMessage(Exception exception) {
    final message = exception.toString();

    // Network errors
    if (message.contains('SocketException') ||
        message.contains('NetworkException')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout errors
    if (message.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    // Authentication errors
    if (message.contains('Invalid login credentials') ||
        message.contains('Invalid email or password')) {
      return 'Invalid email or password. Please check and try again.';
    }

    if (message.contains('Email not confirmed')) {
      return 'Please verify your email before logging in.';
    }

    if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    }

    // Validation errors
    if (message.contains('ValidationException')) {
      return 'Please check your input and try again.';
    }

    // Server errors
    if (message.contains('500') || message.contains('Internal Server Error')) {
      return 'Something went wrong on our end. We\'re working on it!';
    }

    // Default friendly message
    return 'Something unexpected happened. Please try again.';
  }
}
