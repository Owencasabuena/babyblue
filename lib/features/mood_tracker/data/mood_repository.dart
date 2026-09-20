import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:babyblue/core/constants.dart';
import 'package:babyblue/features/mood_tracker/data/models/mood_entry.dart';

/// Riverpod provider for the SQLite [Database] instance.
///
/// Must be overridden in `main.dart` with the initialised database.
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in ProviderScope with the '
    'initialised Database instance.',
  );
});

/// Provides the [MoodRepository] with a database dependency.
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MoodRepository(db);
});

/// Repository for CRUD operations on local mood entries.
///
/// All reads and writes go through SQLite, making the mood tracker
/// fully functional offline.
class MoodRepository {
  final Database _db;

  MoodRepository(this._db);

  /// Insert a new mood entry.
  Future<void> addEntry(MoodEntry entry) async {
    await _db.insert(
      AppConstants.moodTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all mood entries, newest first.
  ///
  /// [limit] caps the number of rows returned (default 100).
  Future<List<MoodEntry>> getEntries({int limit = 100}) async {
    final rows = await _db.query(
      AppConstants.moodTable,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  /// Fetch entries logged in the last [days] days.
  Future<List<MoodEntry>> getRecentEntries({int days = 7}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    final rows = await _db.query(
      AppConstants.moodTable,
      where: 'timestamp >= ?',
      whereArgs: [cutoff],
      orderBy: 'timestamp DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  /// Delete a single entry by its UUID.
  Future<void> deleteEntry(String id) async {
    await _db.delete(
      AppConstants.moodTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Count total entries (for statistics).
  Future<int> countEntries() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${AppConstants.moodTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Fetch the most recent entry for a specific calendar date, or `null`.
  Future<MoodEntry?> getEntryForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await _db.query(
      AppConstants.moodTable,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MoodEntry.fromMap(rows.first);
  }

  /// Fetch all entries between [start] (inclusive) and [end] (exclusive).
  Future<List<MoodEntry>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db.query(
      AppConstants.moodTable,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }
}
