import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/utils.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Login screen with social authentication (Story 1.2)
/// Refactored to use reusable components from core/components
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final googleSignInNotifier = ref.read(googleSignInProvider.notifier);
      final userExists = await googleSignInNotifier.execute();

      if (!mounted) return;

      if (userExists) {
        // User exists - they will be redirected to dashboard by router
        SnackBarHelper.showSuccess(context, 'Welcome back!');
      } else {
        // New user - redirect to registration
        SnackBarHelper.showInfo(context, 'Please complete your registration');
        context.push('/auth/register');
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Google sign-in failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleLoading = true);

    try {
      final appleSignInNotifier = ref.read(appleSignInProvider.notifier);
      final userExists = await appleSignInNotifier.execute();

      if (!mounted) return;

      if (userExists) {
        // User exists - they will be redirected to dashboard by router
        SnackBarHelper.showSuccess(context, 'Welcome back!');
      } else {
        // New user - redirect to registration
        SnackBarHelper.showInfo(context, 'Please complete your registration');
        context.push('/auth/register');
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Apple sign-in failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isGoogleLoading || _isAppleLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section - Branding
                Column(
                  children: [
                    const SizedBox(height: 60),

                    // App Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    Text(
                      'Choose your preferred sign-in method',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.neutral600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Middle Section - Sign-In Options
                Column(
                  children: [
                    const SizedBox(height: AppSizes.paddingXXLarge),

                    // Google Sign-In Button - Using new component
                    SocialSignInButton.google(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      isLoading: _isGoogleLoading,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    // Apple Sign-In Button - Using new component
                    SocialSignInButton.apple(
                      onPressed: isLoading ? null : _handleAppleSignIn,
                      isLoading: _isAppleLoading,
                    ),

                    const SizedBox(height: AppSizes.paddingXLarge),
                  ],
                ),

                // Bottom Section - Create Account
                Column(
                  children: [
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Divider with Text
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.neutral300, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Text(
                            'New to Kairo?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutral600,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.neutral300, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Create Account Button - Using new component
                    AppButton.secondary(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.push('/auth/register');
                            },
                      label: 'Create New Account',
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
