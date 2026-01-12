import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Login screen with social authentication (Story 1.2)
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // New user - redirect to registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your registration'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        context.push('/auth/register');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // New user - redirect to registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your registration'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        context.push('/auth/register');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign-in failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Choose your preferred sign-in method',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Middle Section - Sign-In Options
                Column(
                  children: [
                    const SizedBox(height: 48),

                    // Google Sign-In Button
                    _SocialSignInButton(
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                      isLoading: _isGoogleLoading,
                      logo:
                          'G', // Will use text instead of icon for better branding
                      label: 'Continue with Google',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F1F1F),
                      borderColor: const Color(0xFFDADCE0),
                    ),
                    const SizedBox(height: 12),

                    // Apple Sign-In Button
                    _SocialSignInButton(
                      onPressed: isLoading ? null : _handleAppleSignIn,
                      isLoading: _isAppleLoading,
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),

                // Bottom Section - Create Account
                Column(
                  children: [
                    const SizedBox(height: 24),

                    // Divider with Text
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'New to Kairo?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Create Account Button
                    FilledButton.tonal(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.push('/auth/register');
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

// Custom Social Sign-In Button Widget
class _SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String? logo; // For text-based logos like "G" for Google
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _SocialSignInButton({
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.logo,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  }) : assert(icon != null || logo != null,
            'Either icon or logo must be provided');

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: borderColor != null ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show either icon or text logo
                if (icon != null)
                  Icon(icon, size: 22)
                else if (logo != null)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: foregroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      logo!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
    );
  }
}
