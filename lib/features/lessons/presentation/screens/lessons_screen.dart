import 'package:flutter/material.dart';

import 'package:babyblue/core/theme/app_theme.dart';

/// Placeholder screen for the Educational Lessons feature.
///
/// Provides a polished "coming soon" state that fits the overall
/// visual language of the app.
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

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
                    color: AppTheme.accentPeach.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: AppTheme.accentPeach,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Educational Lessons',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Guided lessons on maternal wellness,\nself-care, and bonding — coming soon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPeach.withAlpha(20),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '🚀  In Development',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentPeach,
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
