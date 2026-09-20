import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/lessons/data/models/lesson_detail.dart';
import 'package:babyblue/features/lessons/presentation/providers/lesson_detail_provider.dart';

/// Browsable lesson catalogue screen.
///
/// Replaces the previous "coming soon" placeholder. Loads lesson data
/// from the JSON-driven [allLessonsProvider] and renders a vertical
/// list of tappable cards that navigate to [LessonDetailScreen].
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(allLessonsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text('Lessons', style: theme.textTheme.headlineLarge),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Guided lessons on maternal wellness, self-care, and bonding.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),

              // ── Lesson list ─────────────────────────────────────
              Expanded(
                child: lessonsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryLavender),
                  ),
                  error: (e, _) => Center(
                    child: Text('Failed to load lessons',
                        style: theme.textTheme.bodyMedium),
                  ),
                  data: (lessons) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: lessons.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _LessonCard(lesson: lessons[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private Widgets ────────────────────────────────────────────────

/// A rich card for a single lesson in the catalogue list.
class _LessonCard extends StatelessWidget {
  final LessonDetail lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.go('/lessons/${lesson.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryLight.withAlpha(50),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLavender.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail / play icon ──────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryLavender.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_circle_filled_rounded,
                size: 32,
                color: AppTheme.primaryLavender,
              ),
            ),
            const SizedBox(width: 14),

            // ── Text content ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLavender,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Duration + read-time badges.
                  Row(
                    children: [
                      _Badge(
                        icon: Icons.play_circle_outline_rounded,
                        label: lesson.duration,
                        color: AppTheme.accentPeach,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        icon: Icons.schedule_rounded,
                        label: lesson.readTime,
                        color: AppTheme.successGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chevron ───────────────────────────────────────
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color.withAlpha(200)),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
