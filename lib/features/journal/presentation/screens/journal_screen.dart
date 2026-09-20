import 'package:flutter/material.dart';

import 'package:babyblue/core/theme/app_theme.dart';

/// Placeholder screen for the Journal feature.
///
/// Provides a polished "coming soon" state that fits the overall
/// visual language of the app.
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLavender.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 40,
                    color: AppTheme.primaryLavender,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'My Journal',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'A private space for your thoughts,\ngratitude, and reflections — coming soon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLavender.withAlpha(20),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '🚀  In Development',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryLavender,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
