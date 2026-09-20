import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:babyblue/core/constants.dart';

/// Initialises the SQLite database used for offline storage.
///
/// Called once during app startup in `main.dart`. The returned [Database]
/// instance is then injected into the Riverpod provider tree.
Future<Database> initializeDatabase() async {
  final databasesPath = await getDatabasesPath();
  final dbPath = p.join(databasesPath, AppConstants.dbName);

  return openDatabase(
    dbPath,
    version: AppConstants.dbVersion,
    onCreate: (Database db, int version) async {
      // Create the mood entries table.
      await db.execute('''
        CREATE TABLE ${AppConstants.moodTable} (
          id         TEXT    PRIMARY KEY,
          timestamp  INTEGER NOT NULL,
          mood_score INTEGER NOT NULL,
          note       TEXT    DEFAULT '',
          tags       TEXT    DEFAULT ''
        )
      ''');

      // Create the journal entries table.
      await db.execute('''
        CREATE TABLE ${AppConstants.journalTable} (
          id          TEXT    PRIMARY KEY,
          created_at  INTEGER NOT NULL,
          mood_label  TEXT    NOT NULL,
          mood_icon   TEXT    NOT NULL,
          prompt_used TEXT    DEFAULT '',
          content     TEXT    NOT NULL,
          gratitude   TEXT    DEFAULT '',
          input_type  TEXT    DEFAULT 'text'
        )
      ''');
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // v1 → v2: add journal_entries table.
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${AppConstants.journalTable} (
            id          TEXT    PRIMARY KEY,
            created_at  INTEGER NOT NULL,
            mood_label  TEXT    NOT NULL,
            mood_icon   TEXT    NOT NULL,
            prompt_used TEXT    DEFAULT '',
            content     TEXT    NOT NULL,
            gratitude   TEXT    DEFAULT '',
            input_type  TEXT    DEFAULT 'text'
          )
        ''');
      }
    },
  );
}
