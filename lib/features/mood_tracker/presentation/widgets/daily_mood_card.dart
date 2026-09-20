import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';
import 'package:babyblue/features/mood_tracker/presentation/providers/mood_provider.dart';
import 'package:babyblue/features/mood_tracker/presentation/widgets/mood_log_sheet.dart';

/// A prominent central card displaying today's mood status.
///
/// - If mood is logged: large emoji + "Today's Mood: [Label]" with a
///   coloured tint background.
/// - If not logged: "Today's Mood: Not logged yet" with a prominent
///   [Log Mood] button.
class DailyMoodCard extends ConsumerWidget {
  const DailyMoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMood = ref.watch(todayMoodProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: todayMood.when(
        data: (entry) => _buildCard(context, entry),
        loading: () => _buildLoadingCard(),
        error: (_, _) => _buildCard(context, null),
      ),
    );
  }

  Widget _buildCard(BuildContext context, MoodEntry? entry) {
    if (entry != null) {
      return _LoggedMoodCard(entry: entry);
    }
    return const _UnloggedMoodCard();
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLavender.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.primaryLavender,
        ),
      ),
    );
  }
}

/// Card shown when today's mood has been logged.
class _LoggedMoodCard extends StatelessWidget {
  final MoodEntry entry;

  const _LoggedMoodCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idx = (entry.moodScore - 1).clamp(0, 4);
    final emoji = AppConstants.moodEmojis[idx];
    final label = AppConstants.moodLabels[idx];
    final color = AppTheme.moodColors[idx];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(25),
            color.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large emoji.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Text(emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),

          // "Today's Mood:" label.
          Text(
            "Today's Mood:",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),

          // Mood label.
          Text(
            label,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),

          // Optional note preview.
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 16, color: color.withAlpha(150)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      entry.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textDark.withAlpha(180),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card shown when no mood has been logged today.
class _UnloggedMoodCard extends StatelessWidget {
  const _UnloggedMoodCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryLight.withAlpha(40),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLavender.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gentle pulsing emoji placeholder.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryLight.withAlpha(30),
              ),
              child: const Center(
                child: Text('🌸', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Today's Mood:",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Not logged yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textDark.withAlpha(160),
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 24),

          // Log Mood button.
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryLavender, AppTheme.accentPeach],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLavender.withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => MoodLogSheet.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_reaction_rounded, size: 22),
                label: const Text(
                  'Log Mood',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
