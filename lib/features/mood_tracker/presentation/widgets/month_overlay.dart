import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/core/theme/app_theme.dart';
import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';
import 'package:babyblue/features/mood_tracker/presentation/providers/mood_provider.dart';

/// Shows a full-month calendar overlay as a modal bottom sheet.
///
/// Displays a 7-column grid with mood emojis on logged days,
/// a mood summary count at the bottom, and month navigation arrows.
///
/// Call [MonthOverlay.show] to present it.
class MonthOverlay {
  MonthOverlay._();

  /// Present the month overlay as a modal bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MonthOverlayContent(),
    );
  }
}

class _MonthOverlayContent extends ConsumerStatefulWidget {
  const _MonthOverlayContent();

  @override
  ConsumerState<_MonthOverlayContent> createState() =>
      _MonthOverlayContentState();
}

class _MonthOverlayContentState extends ConsumerState<_MonthOverlayContent> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    // Don't allow navigating past the current month.
    if (nextMonth.isAfter(DateTime(now.year, now.month + 1))) return;
    setState(() {
      _currentMonth = nextMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthMoods = ref.watch(monthMoodsProvider(_currentMonth));
    final monthLabel = DateFormat('MMMM yyyy').format(_currentMonth);
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;
    final canGoNext = !isCurrentMonth;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Month navigation ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  color: AppTheme.primaryLavender,
                ),
                Text(
                  monthLabel,
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: canGoNext ? _nextMonth : null,
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  color: canGoNext
                      ? AppTheme.primaryLavender
                      : AppTheme.textMuted.withAlpha(60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Weekday headers ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted.withAlpha(150),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Calendar grid ────────────────────────────────────
          monthMoods.when(
            data: (moods) => _buildGrid(moods, now),
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.all(40),
              child: Text('Could not load moods'),
            ),
          ),

          const SizedBox(height: 8),

          // ── Mood summary ─────────────────────────────────────
          monthMoods.when(
            data: (moods) => _buildSummary(moods),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGrid(Map<DateTime, MoodEntry?> moods, DateTime now) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final totalDays = lastDay.day;

    // Monday = 1, so offset = (weekday - 1).
    final startOffset = (firstDay.weekday - 1) % 7;
    final totalCells = startOffset + totalDays;
    final rows = ((totalCells) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > totalDays) {
                return const Expanded(child: SizedBox(height: 52));
              }

              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNum,
              );
              final entry = moods[date];
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              String? emoji;
              Color? moodColor;
              if (entry != null) {
                final idx = (entry.moodScore - 1).clamp(0, 4);
                emoji = AppConstants.moodEmojis[idx];
                moodColor = AppTheme.moodColors[idx];
              }

              return Expanded(
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primaryLavender.withAlpha(20)
                        : emoji != null
                            ? moodColor!.withAlpha(15)
                            : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(
                            color: AppTheme.primaryLavender.withAlpha(80),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday
                              ? AppTheme.primaryLavender
                              : date.isAfter(now)
                                  ? AppTheme.textMuted.withAlpha(80)
                                  : AppTheme.textDark,
                        ),
                      ),
                      if (emoji != null) ...[
                        const SizedBox(height: 2),
                        Text(emoji, style: const TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildSummary(Map<DateTime, MoodEntry?> moods) {
    // Count moods per score.
    final counts = <int, int>{};
    for (final entry in moods.values) {
      if (entry != null) {
        counts[entry.moodScore] = (counts[entry.moodScore] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          'No moods logged this month',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted.withAlpha(150),
          ),
        ),
      );
    }

    // Sort by count descending.
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryLight.withAlpha(40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sorted.map((e) {
            final idx = (e.key - 1).clamp(0, 4);
            final emoji = AppConstants.moodEmojis[idx];
            final label = AppConstants.moodLabels[idx];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  '${e.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted.withAlpha(180),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
