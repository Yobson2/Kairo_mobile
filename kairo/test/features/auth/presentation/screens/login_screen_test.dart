import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairo/features/auth/presentation/screens/login_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('should render all UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App branding
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('Welcome to Kairo'), findsOneWidget);
      expect(find.text('Allocate with intention, live with clarity'), findsOneWidget);

      // Form fields
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Buttons
      expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Create New Account'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Forgot Password?'), findsOneWidget);
    });

    testWidgets('should validate email field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find login button and tap without entering email
      final loginButton = find.widgetWithText(FilledButton, 'Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      // Tap login button
      final loginButton = find.widgetWithText(FilledButton, 'Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter email but not password
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      // Tap login button
      final loginButton = find.widgetWithText(FilledButton, 'Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should show visibility icon (password is obscured)
      expect(find.widgetWithIcon(IconButton, Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      final visibilityToggle = find.widgetWithIcon(IconButton, Icons.visibility);
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Should now show visibility_off icon (password is visible)
      expect(find.widgetWithIcon(IconButton, Icons.visibility_off), findsOneWidget);

      // Toggle back
      final visibilityOffToggle = find.widgetWithIcon(IconButton, Icons.visibility_off);
      await tester.tap(visibilityOffToggle);
      await tester.pumpAndSettle();

      // Should show visibility icon again (password is obscured)
      expect(find.widgetWithIcon(IconButton, Icons.visibility), findsOneWidget);
    });

    testWidgets('should have email and password fields enabled initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      final emailWidget = tester.widget<TextFormField>(emailField);
      final passwordWidget = tester.widget<TextFormField>(passwordField);

      expect(emailWidget.enabled, isNot(false));
      expect(passwordWidget.enabled, isNot(false));
    });

    testWidgets('should have email placeholder text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that email hint text is present
      expect(find.text('your.email@example.com'), findsOneWidget);
    });
  });
}
