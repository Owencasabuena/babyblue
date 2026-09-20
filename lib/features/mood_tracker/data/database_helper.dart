import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:babyblue/core/constants.dart';

/// Initialises the SQLite database used for offline mood storage.
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
    },
  );
}
