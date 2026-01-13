import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/presentation/screens/category_management_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/create_strategy_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/dashboard_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/edit_strategy_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/enhanced_onboarding_flow.dart';
import 'package:kairo/features/allocation/presentation/screens/strategies_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/income_entry_screen.dart';
import 'package:kairo/features/allocation/presentation/screens/income_history_screen.dart';
import 'package:kairo/features/auth/presentation/screens/login_screen.dart';
import 'package:kairo/features/auth/presentation/screens/registration_screen.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';
import 'package:kairo/features/commun/presentation/screens/error_screen.dart';
import 'package:kairo/features/commun/presentation/screens/splash_screen.dart';
import 'package:kairo/features/settings/presentation/screens/settings_screen.dart';

/// Router configuration for the Kairo app
/// Implements authentication-aware routing with protected routes

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.value != null;
      final isOnAuthPage = state.matchedLocation.startsWith('/auth');
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Show splash while loading auth state
      if (authState.isLoading) {
        return isOnSplash ? null : '/splash';
      }

      // Auth state has loaded - proceed with routing

      // If authenticated and trying to access auth pages or splash, redirect to dashboard
      if (isAuthenticated && (isOnAuthPage || isOnSplash)) {
        final profile = ref.read(currentUserProfileProvider).value;

        // If user hasn't completed onboarding, send to onboarding
        if (profile != null && !profile['onboarding_completed']) {
          return '/onboarding';
        }

        return '/dashboard';
      }

      // If not authenticated and on splash, redirect to login
      if (!isAuthenticated && isOnSplash) {
        return '/auth/login';
      }

      // If not authenticated and trying to access protected pages, redirect to login
      if (!isAuthenticated && !isOnAuthPage && !isOnOnboarding) {
        return '/auth/login';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ========================================================================
      // SPLASH SCREEN
      // ========================================================================
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ========================================================================
      // AUTHENTICATION ROUTES
      // ========================================================================
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/auth/login',
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      // ========================================================================
      // ONBOARDING ROUTES (Protected)
      // ========================================================================
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const EnhancedOnboardingFlow(),
      ),

      // ========================================================================
      // MAIN APP ROUTES (Protected)
      // ========================================================================
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          // Income routes
          GoRoute(
            path: 'income/new',
            name: 'income-new',
            builder: (context, state) => const IncomeEntryScreen(),
          ),
          GoRoute(
            path: 'income/history',
            name: 'income-history',
            builder: (context, state) => const IncomeHistoryScreen(),
          ),
        ],
      ),

      // ========================================================================
      // CATEGORY ROUTES (Protected)
      // ========================================================================
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),

      // ========================================================================
      // STRATEGY ROUTES (Protected)
      // ========================================================================
      GoRoute(
        path: '/strategies',
        name: 'strategies',
        builder: (context, state) => const StrategiesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'strategy-new',
            builder: (context, state) => const CreateStrategyScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'strategy-edit',
            builder: (context, state) {
              // Strategy should be passed as extra parameter
              final strategy = state.extra as AllocationStrategy?;
              if (strategy == null) {
                return const ErrorScreen(
                  message: 'Strategy not found. Please go back and try again.',
                );
              }
              return EditStrategyScreen(strategy: strategy);
            },
          ),
        ],
      ),

      // ========================================================================
      // SETTINGS ROUTES (Protected)
      // ========================================================================
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ========================================================================
      // ERROR / 404 ROUTE
      // ========================================================================
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final error = state.extra as String?;
          return ErrorScreen(message: error ?? 'An error occurred');
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      message: 'Page not found: ${state.matchedLocation}',
    ),
  );
});
