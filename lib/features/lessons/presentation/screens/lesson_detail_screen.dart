import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/lessons/presentation/providers/lesson_detail_provider.dart';
import 'package:babyblue/features/lessons/presentation/widgets/video_player_widget.dart';

/// YouTube-style lesson detail screen.
///
/// Layout:
/// - Top: [VideoPlayerWidget] rendering the lesson `.mp4`.
/// - Bottom: Scrollable metadata — title, category chip, tags,
///   duration / read-time row, and full body description.
class LessonDetailScreen extends ConsumerWidget {
  /// The lesson ID used to fetch data via [lessonDetailProvider].
  final String lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: lessonAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryLavender),
          ),
          error: (e, _) => Center(
            child: Text('Error loading lesson', style: theme.textTheme.bodyMedium),
          ),
          data: (lesson) {
            if (lesson == null) {
              return Center(
                child: Text('Lesson not found',
                    style: theme.textTheme.bodyMedium),
              );
            }

            return Column(
              children: [
                // ── Video player (top) ─────────────────────────
                SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      VideoPlayerWidget(videoUrl: lesson.videoUrl),

                      // Back button overlay.
                      Positioned(
                        top: 8,
                        left: 8,
                        child: SafeArea(
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Lesson info (bottom, scrollable) ──────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title.
                        Text(
                          lesson.title,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),

                        // Category chip + duration/read-time.
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _Chip(
                              icon: Icons.category_rounded,
                              label: lesson.category,
                              color: AppTheme.primaryLavender,
                            ),
                            _Chip(
                              icon: Icons.play_circle_outline_rounded,
                              label: lesson.duration,
                              color: AppTheme.accentPeach,
                            ),
                            _Chip(
                              icon: Icons.schedule_rounded,
                              label: lesson.readTime,
                              color: AppTheme.successGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tags.
                        if (lesson.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: lesson.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight
                                            .withAlpha(30),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.primaryLavender,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Divider.
                        Divider(
                          color: AppTheme.primaryLight.withAlpha(40),
                          height: 1,
                        ),
                        const SizedBox(height: 20),

                        // Description body.
                        Text(
                          lesson.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: AppTheme.textDark.withAlpha(210),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Private Widgets ────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
