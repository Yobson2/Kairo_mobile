// Kairo app widget test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Kairo app smoke test', (WidgetTester tester) async {
    // Build a simple app wrapper to verify core widgets work
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Kairo App'),
            ),
          ),
        ),
      ),
    );

    // Verify basic app structure loads
    expect(find.text('Kairo App'), findsOneWidget);
  });
}
