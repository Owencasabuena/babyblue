import 'package:flutter/material.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/lessons/data/models/lesson.dart';

/// A compact card for displaying a suggested lesson.
///
/// Shows the lesson emoji, title, subtitle, and duration badge.
/// Designed to be used in a horizontal scrolling list.
class SuggestedLessonCard extends StatelessWidget {
  final Lesson lesson;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  const SuggestedLessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emoji icon ──────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(lesson.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Title ───────────────────────────────────────────
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),

            // ── Subtitle ────────────────────────────────────────
            Expanded(
              child: Text(
                lesson.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Duration badge ──────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentPeach.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: AppTheme.accentPeach.withAlpha(200),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentPeach.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
