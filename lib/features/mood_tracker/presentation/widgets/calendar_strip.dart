import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';
import 'package:babyblue/features/mood_tracker/presentation/providers/mood_provider.dart';

/// A horizontal, scrollable 7-day calendar strip displaying dates
/// and corresponding past mood icons.
///
/// Tapping any cell triggers [onTap] to expand the full-month view.
/// Today is visually highlighted with a filled lavender circle.
class CalendarStrip extends ConsumerWidget {
  /// Called when the user taps any calendar cell.
  final VoidCallback onTap;

  const CalendarStrip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekMoods = ref.watch(weekMoodsProvider);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLavender.withAlpha(18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: weekMoods.when(
          data: (moods) => _buildStrip(moods, todayKey),
          loading: () => _buildStrip({}, todayKey),
          error: (_, _) => _buildStrip({}, todayKey),
        ),
      ),
    );
  }

  Widget _buildStrip(Map<DateTime, MoodEntry?> moods, DateTime todayKey) {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dayOffset = index - 3; // -3 to +3
        final date = DateTime(today.year, today.month, today.day + dayOffset);
        final isToday = date == todayKey;
        final entry = moods[date];
        final dayAbbr = DateFormat('E').format(date).substring(0, 3).toUpperCase();
        final dayNum = date.day.toString();

        // Get mood emoji if entry exists.
        String? moodEmoji;
        if (entry != null) {
          final idx = (entry.moodScore - 1).clamp(0, 4);
          moodEmoji = AppConstants.moodEmojis[idx];
        }

        return _DayCell(
          dayAbbr: dayAbbr,
          dayNum: dayNum,
          moodEmoji: moodEmoji,
          isToday: isToday,
          isFuture: date.isAfter(todayKey),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String dayAbbr;
  final String dayNum;
  final String? moodEmoji;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.dayAbbr,
    required this.dayNum,
    this.moodEmoji,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day abbreviation.
        Text(
          isToday ? 'TODAY' : dayAbbr,
          style: TextStyle(
            fontSize: isToday ? 9 : 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppTheme.primaryLavender : AppTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Date number in a circle.
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday
                ? AppTheme.primaryLavender
                : isFuture
                    ? Colors.transparent
                    : Colors.transparent,
            border: !isToday && moodEmoji != null
                ? Border.all(
                    color: AppTheme.primaryLight.withAlpha(100),
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              dayNum,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday
                    ? Colors.white
                    : isFuture
                        ? AppTheme.textMuted.withAlpha(120)
                        : AppTheme.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Mood emoji (or empty space).
        SizedBox(
          height: 20,
          child: moodEmoji != null
              ? Text(moodEmoji!, style: const TextStyle(fontSize: 14))
              : isFuture
                  ? const SizedBox.shrink()
                  : Icon(
                      Icons.circle_outlined,
                      size: 8,
                      color: AppTheme.textMuted.withAlpha(60),
                    ),
        ),
      ],
    );
  }
}
