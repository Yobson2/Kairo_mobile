import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kairo/core/router/app_router.dart';
import 'package:kairo/core/error/error_handler.dart';
import 'package:kairo/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize error handler and Sentry
  await ErrorHandler.initialize(
    sentryDsn: dotenv.env['SENTRY_DSN'] ?? '',
    environment: dotenv.env['ENVIRONMENT'] ?? 'development',
    enableInDevMode: false, // Only enable in production
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: KairoApp(),
    ),
  );
}

class KairoApp extends ConsumerWidget {
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kairo - Money Allocation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
