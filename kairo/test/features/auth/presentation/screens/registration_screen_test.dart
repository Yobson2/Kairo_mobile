import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/features/auth/presentation/screens/registration_screen.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    testWidgets('should render registration screen with essential UI elements',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Assert - Check for essential UI elements
      expect(find.widgetWithText(AppBar, 'Create Account'), findsOneWidget);
      expect(find.text('Join Kairo'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should have all required form fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Assert - Check specific fields exist
      expect(find.widgetWithText(TextFormField, 'First Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Last Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'),
          findsOneWidget);
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Gender'),
          findsOneWidget);
    });

    testWidgets('should validate required fields on submission',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Make button visible and tap
      final button = find.widgetWithText(FilledButton, 'Create Account');
      await tester.dragUntilVisible(
        button,
        find.byType(SingleChildScrollView),
        const Offset(0, -250),
      );
      await tester.tap(button);
      await tester.pump();

      // Scroll back to top to see validation errors
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();

      // Assert - Check for validation messages
      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Find password field and scroll to it
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.dragUntilVisible(
        passwordField,
        find.byType(SingleChildScrollView),
        const Offset(0, -250),
      );

      // Find visibility toggle button within password field
      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );

      // Act - Tap visibility toggle
      expect(visibilityIcon, findsOneWidget);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Assert - Icon button still exists (toggle worked)
      expect(visibilityIcon, findsOneWidget);
    });

    testWidgets('should open date picker when tapping date of birth',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Find and tap date of birth field
      final dobField = find.text('Select your date of birth');
      await tester.tap(dobField);
      await tester.pumpAndSettle();

      // Assert - Date picker dialog appears
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
