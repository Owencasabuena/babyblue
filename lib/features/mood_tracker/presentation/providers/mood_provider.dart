import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';
import 'package:babyblue/features/mood_tracker/data/mood_repository.dart';

const _uuid = Uuid();

/// Provides the current list of mood entries (newest first).
///
/// Widgets watch this to reactively rebuild whenever the user logs
/// a new mood or deletes an existing entry.
final moodEntriesProvider =
    AsyncNotifierProvider<MoodNotifier, List<MoodEntry>>(MoodNotifier.new);

/// Manages local mood entries via the [MoodRepository].
class MoodNotifier extends AsyncNotifier<List<MoodEntry>> {
  /// Load recent entries on first access.
  @override
  Future<List<MoodEntry>> build() async {
    final repo = ref.read(moodRepositoryProvider);
    return repo.getEntries();
  }

  /// Log a new mood entry and refresh the list.
  Future<void> logMood({
    required int moodScore,
    String note = '',
    List<String> tags = const [],
  }) async {
    final repo = ref.read(moodRepositoryProvider);
    final entry = MoodEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      moodScore: moodScore,
      note: note,
      tags: tags,
    );

    await repo.addEntry(entry);

    // Invalidate so the next read re-fetches from the DB.
    ref.invalidateSelf();
  }

  /// Remove an entry and refresh.
  Future<void> deleteEntry(String id) async {
    final repo = ref.read(moodRepositoryProvider);
    await repo.deleteEntry(id);
    ref.invalidateSelf();
  }
}

// ── Derived Providers ──────────────────────────────────────────────

/// Today's most recent mood entry, or `null` if nothing logged yet.
///
/// Automatically re-evaluates when [moodEntriesProvider] changes
/// (i.e. after a log or delete).
final todayMoodProvider = FutureProvider<MoodEntry?>((ref) async {
  // Force dependency on the entries list so we refresh after mutations.
  await ref.watch(moodEntriesProvider.future);

  final repo = ref.read(moodRepositoryProvider);
  return repo.getEntryForDate(DateTime.now());
});

/// A map of `DateTime(year, month, day)` → latest [MoodEntry?] for the
/// 7-day window centred on today (3 days back, today, 3 days forward).
///
/// Used by the calendar strip to show mood emojis on each date cell.
final weekMoodsProvider =
    FutureProvider<Map<DateTime, MoodEntry?>>((ref) async {
  await ref.watch(moodEntriesProvider.future);

  final repo = ref.read(moodRepositoryProvider);
  final today = DateTime.now();
  final Map<DateTime, MoodEntry?> result = {};

  for (int i = -3; i <= 3; i++) {
    final date = DateTime(today.year, today.month, today.day + i);
    result[date] = await repo.getEntryForDate(date);
  }

  return result;
});

/// All mood entries for a given month, keyed by calendar day.
///
/// Used by the expandable month overlay to render a full-month grid
/// with mood emojis and a summary count.
final monthMoodsProvider =
    FutureProvider.family<Map<DateTime, MoodEntry?>, DateTime>(
  (ref, month) async {
    await ref.watch(moodEntriesProvider.future);

    final repo = ref.read(moodRepositoryProvider);
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final entries = await repo.getEntriesInRange(start, end);

    // Group by calendar day, keeping the latest entry per day.
    final Map<DateTime, MoodEntry?> result = {};
    for (final entry in entries) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      // entries are already sorted DESC, so first hit is the latest.
      result.putIfAbsent(day, () => entry);
    }

    return result;
  },
);

