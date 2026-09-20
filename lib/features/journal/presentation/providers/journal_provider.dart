import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:babyblue/features/journal/data/journal_repository.dart';
import 'package:babyblue/features/journal/data/models/journal_entry.dart';
import 'package:babyblue/features/journal/data/models/journal_mood.dart';

const _uuid = Uuid();

/// Provides the current list of journal entries (newest first).
final journalEntriesProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(
        JournalNotifier.new);

/// Manages local journal entries via the [JournalRepository].
class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final repo = ref.read(journalRepositoryProvider);
    return repo.getEntries();
  }

  /// Create and save a new journal entry.
  Future<void> addEntry({
    required JournalMood mood,
    required String content,
    String promptUsed = '',
    List<String> gratitude = const [],
    String inputType = 'text',
  }) async {
    final repo = ref.read(journalRepositoryProvider);
    final entry = JournalEntry(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      mood: mood,
      promptUsed: promptUsed,
      content: content,
      gratitude: gratitude,
      inputType: inputType,
    );

    await repo.addEntry(entry);
    ref.invalidateSelf();
  }

  /// Update an existing entry.
  Future<void> updateEntry(JournalEntry entry) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.updateEntry(entry);
    ref.invalidateSelf();
  }

  /// Delete an entry by ID.
  Future<void> deleteEntry(String id) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.deleteEntry(id);
    ref.invalidateSelf();
  }
}

// ── Segmented Timeline Providers ──────────────────────────────────

/// Today's journal entries.
final todayEntriesProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  // Re-evaluate whenever the main entries list changes.
  await ref.watch(journalEntriesProvider.future);

  final repo = ref.read(journalRepositoryProvider);
  return repo.getEntriesForDate(DateTime.now());
});

/// Yesterday's journal entries.
final yesterdayEntriesProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  await ref.watch(journalEntriesProvider.future);

  final repo = ref.read(journalRepositoryProvider);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return repo.getEntriesForDate(yesterday);
});

/// Past 7 days of entries (excluding today and yesterday).
final pastWeekEntriesProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  await ref.watch(journalEntriesProvider.future);

  final repo = ref.read(journalRepositoryProvider);
  final now = DateTime.now();
  final startOfYesterday =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  final sevenDaysAgo =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));

  return repo.getEntriesInRange(sevenDaysAgo, startOfYesterday);
});
