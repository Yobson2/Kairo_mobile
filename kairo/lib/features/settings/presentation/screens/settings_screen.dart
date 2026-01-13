import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/utils.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

/// Settings screen with user preferences and account management (Phase 5)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile section
                _ProfileSection(user: user),

                const Divider(),

                // Preferences section
                _SectionHeader(title: 'Preferences'),
                _SettingsTile(
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: 'System default',
                  onTap: () => _showThemeDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () => _showLanguageDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.currency_exchange,
                  title: 'Default Currency',
                  subtitle: 'KES (Kenyan Shilling)',
                  onTap: () => _showCurrencyDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => _showNotificationsDialog(context),
                ),

                const Divider(),

                // Data & Privacy section
                _SectionHeader(title: 'Data & Privacy'),
                _SettingsTile(
                  icon: Icons.cloud_download,
                  title: 'Export Data',
                  subtitle: 'Download your data',
                  onTap: () => _exportData(context),
                ),
                _SettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: () => _showDeleteAccountDialog(context),
                  isDestructive: true,
                ),

                const Divider(),

                // Support section
                _SectionHeader(title: 'Support'),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help using Kairo',
                  onTap: () => _openHelpCenter(context),
                ),
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve',
                  onTap: () => _reportBug(context),
                ),
                _SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts',
                  onTap: () => _sendFeedback(context),
                ),

                const Divider(),

                // Legal section
                _SectionHeader(title: 'Legal'),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _openPrivacyPolicy(context),
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _openTermsOfService(context),
                ),
                _SettingsTile(
                  icon: Icons.gavel_outlined,
                  title: 'Licenses',
                  onTap: () => _showLicenses(context),
                ),

                const Divider(),

                // App info
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Kairo',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSizes.paddingXSmall),
                        Text(
                          'Version 1.0.0',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          'Allocate with intention, live with clarity',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Sign out button
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: AppButton.outlined(
                    onPressed: () => _signOut(context),
                    label: 'Sign Out',
                    icon: Icons.logout,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView.generic(message: 'Error loading settings: $e'),
      ),
    );
  }

  // Dialog methods
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('System Default'),
              value: 'system',
              groupValue: 'system',
              onChanged: (_) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (_) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (_) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: const Icon(Icons.check),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Kiswahili'),
              subtitle: const Text('Coming soon'),
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              title: const Text('Français'),
              subtitle: const Text('Coming soon'),
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'KES - Kenyan Shilling',
            'NGN - Nigerian Naira',
            'GHS - Ghanaian Cedi',
            'ZAR - South African Rand',
            'USD - US Dollar',
            'EUR - Euro',
          ]
              .map((currency) => RadioListTile(
                    title: Text(currency),
                    value: currency,
                    groupValue: 'KES - Kenyan Shilling',
                    onChanged: (_) => Navigator.pop(context),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Income Reminders'),
              subtitle: const Text('Remind me to add income entries'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Insights'),
              subtitle: const Text('Notify me of new insights'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Marketing'),
              subtitle: const Text('Tips and updates about Kairo'),
              value: false,
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all your data. '
          'This action cannot be undone.\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _exportData(BuildContext context) {
    context.showInfoSnackBar('Preparing your data export...');
  }

  void _deleteAccount(BuildContext context) {
    context.showWarningSnackBar('Account deletion initiated. Check your email.');
  }

  void _openHelpCenter(BuildContext context) {
    context.showInfoSnackBar('Opening help center...');
  }

  void _reportBug(BuildContext context) {
    context.showInfoSnackBar('Opening bug report form...');
  }

  void _sendFeedback(BuildContext context) {
    context.showInfoSnackBar('Opening feedback form...');
  }

  void _openPrivacyPolicy(BuildContext context) {
    context.showInfoSnackBar('Opening privacy policy...');
  }

  void _openTermsOfService(BuildContext context) {
    context.showInfoSnackBar('Opening terms of service...');
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Kairo',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Kairo. All rights reserved.',
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(signOutProvider.notifier).execute();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }
}

/// Profile section widget
class _ProfileSection extends StatelessWidget {
  final dynamic user;

  const _ProfileSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final email = user.email ?? 'No email';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              initial,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    return '${date.month}/${date.year}';
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingLarge, AppSizes.paddingMedium, AppSizes.paddingLarge, AppSizes.paddingSmall),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

/// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.error : null,
      ),
      onTap: onTap,
    );
  }
}
