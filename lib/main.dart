import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/app.dart';
import 'package:babyblue/features/mood_tracker/data/database_helper.dart';
import 'package:babyblue/features/mood_tracker/data/mood_repository.dart';

/// Application entry point.
///
/// Performs async initialisation (SQLite database) before launching
/// the widget tree. The database instance is injected into the
/// Riverpod provider graph via an override so that no global
/// singletons are needed.
void main() async {
  // Required when calling async code before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for consistent UX.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Warm status bar style.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // ── Initialise local database ──────────────────────────────────
  final database = await initializeDatabase();

  // ── Launch ─────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        // Inject the live database into the provider graph.
        databaseProvider.overrideWithValue(database),
      ],
      child: const App(),
    ),
  );
}
