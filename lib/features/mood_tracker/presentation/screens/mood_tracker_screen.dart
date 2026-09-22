import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/lessons/presentation/providers/suggested_lessons_provider.dart';
import 'package:babyblue/features/lessons/presentation/widgets/suggested_lesson_card.dart';
import 'package:babyblue/features/mood_tracker/presentation/widgets/calendar_strip.dart';
import 'package:babyblue/features/mood_tracker/presentation/widgets/daily_mood_card.dart';
import 'package:babyblue/features/mood_tracker/presentation/widgets/month_overlay.dart';

/// The main mood-tracking home screen.
///
/// Layout (top → bottom):
/// 1. Scrollable 7-day calendar strip (tappable → month overlay)
/// 2. Daily mood status card (logged or "Log Mood" prompt)
/// 3. Suggested lessons section (adaptive to current mood)
///
/// No greetings, user handles, or introductory text.
class MoodTrackerScreen extends ConsumerWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suggestedLessons = ref.watch(suggestedLessonsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Calendar Strip ──────────────────────────────────
              SliverToBoxAdapter(
                child: CalendarStrip(
                  onTap: () => MonthOverlay.show(context),
                ),
              ),

              // ── Daily Mood Card ─────────────────────────────────
              const SliverToBoxAdapter(
                child: DailyMoodCard(),
              ),

              // ── Suggested Lessons Header ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPeach.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: AppTheme.accentPeach,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Suggested Lessons',
                        style: theme.textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        'Today',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryLavender,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Suggested Lessons List ──────────────────────────
              SliverToBoxAdapter(
                child: suggestedLessons.when(
                  data: (lessons) {
                    if (lessons.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No lessons available right now.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    return SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        itemCount: lessons.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return SuggestedLessonCard(
                            lesson: lessons[index],
                            onTap: () {
                              context.go('/lessons/${lessons[index].id}');
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryLavender,
                      ),
                    ),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load lessons.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

              // ── Bottom spacing ──────────────────────────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
