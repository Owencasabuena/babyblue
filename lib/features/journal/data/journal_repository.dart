import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/features/journal/data/models/journal_entry.dart';
import 'package:babyblue/features/mood_tracker/data/mood_repository.dart';

/// Provides the [JournalRepository] with the shared database.
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return JournalRepository(db);
});

/// Repository for CRUD operations on local journal entries.
///
/// All reads and writes go through SQLite, making the journal
/// fully functional offline.
class JournalRepository {
  final Database _db;

  JournalRepository(this._db);

  /// Insert a new journal entry.
  Future<void> addEntry(JournalEntry entry) async {
    await _db.insert(
      AppConstants.journalTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing journal entry.
  Future<void> updateEntry(JournalEntry entry) async {
    await _db.update(
      AppConstants.journalTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Delete a single entry by its UUID.
  Future<void> deleteEntry(String id) async {
    await _db.delete(
      AppConstants.journalTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetch all journal entries, newest first.
  Future<List<JournalEntry>> getEntries({int limit = 100}) async {
    final rows = await _db.query(
      AppConstants.journalTable,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(JournalEntry.fromMap).toList();
  }

  /// Fetch all entries for a specific calendar date.
  Future<List<JournalEntry>> getEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await _db.query(
      AppConstants.journalTable,
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC',
    );
    return rows.map(JournalEntry.fromMap).toList();
  }

  /// Fetch all entries between [start] (inclusive) and [end] (exclusive).
  Future<List<JournalEntry>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db.query(
      AppConstants.journalTable,
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC',
    );
    return rows.map(JournalEntry.fromMap).toList();
  }
}
