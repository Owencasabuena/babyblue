import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/core/router/app_router.dart';

/// Root application widget.
///
/// Configures theming, routing, and global app behaviour.
/// Must be a child of [ProviderScope].
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────
      theme: AppTheme.lightTheme,

      // ── Routing ───────────────────────────────────────────
      routerConfig: router,
    );
  }
}
