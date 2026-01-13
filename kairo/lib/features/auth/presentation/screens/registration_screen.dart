import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/theme/theme.dart';
import 'package:kairo/core/utils/utils.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = UserProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      phoneNumber: null,
    );

    await ref.read(signUpProvider.notifier).execute(
          email: _emailController.text.trim(),
          password: '', // Password will be set via magic link
          profile: profile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);

    // Listen for registration state changes
    ref.listen<AsyncValue<void>>(signUpProvider, (previous, next) {
      next.when(
        data: (_) {
          SnackBarHelper.showSuccess(
            context,
            'Account created! Please check your email to verify.',
            duration: AppDurations.snackBarLong,
          );
        },
        error: (error, stackTrace) {
          SnackBarHelper.showError(
            context,
            'Registration failed: $error',
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Information Section
                const SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // First Name
                AppTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      AppValidators.name(v, fieldName: 'First name'),
                  enabled: !signUpState.isLoading,
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Last Name
                AppTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  prefixIcon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      AppValidators.name(v, fieldName: 'Last name'),
                  enabled: !signUpState.isLoading,
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Date of Birth
                DatePickerField.dateOfBirth(
                  selectedDate: _dateOfBirth,
                  onDateSelected: (date) => setState(() => _dateOfBirth = date),
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Gender
                AppSimpleDropdown(
                  value: _selectedGender,
                  label: 'Gender (Optional)',
                  hint: 'Select if you wish',
                  prefixIcon: Icons.wc_outlined,
                  items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  enabled: !signUpState.isLoading,
                ),
                const SizedBox(height: AppSizes.paddingXLarge),

                // Account Section
                const SectionHeader(
                  icon: Icons.email_outlined,
                  title: 'Account Details',
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AppValidators.email,
                  enabled: !signUpState.isLoading,
                ),

                const SizedBox(height: AppSizes.paddingXLarge),

                // Create Account Button
                AppButton.primary(
                  onPressed: _handleRegistration,
                  label: 'Create Account',
                  isLoading: signUpState.isLoading,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSizes.paddingMedium),

                // Privacy & Terms
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our\n'),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppButton.text(
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'Sign In',
                    ),
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
