// ============================================================================
// ERROR SCREEN
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kairo/core/components/components.dart';
import 'package:kairo/core/utils/utils.dart';

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: ErrorView.generic(
        message: message,
        onRetry: () => context.go('/dashboard'),
      ),
    );
  }
}
