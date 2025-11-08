import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../common/constants.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, Constants.dbName);

    _db = await openDatabase(
      dbPath,
      version: Constants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${Constants.sessionTable}(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            token TEXT NOT NULL,
            name TEXT,
            lastname TEXT,
            email TEXT,
            role TEXT,
            image TEXT,
            createdAt INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sessions_createdAt ON ${Constants.sessionTable}(createdAt DESC);');
      },
    );
    return _db!;
  }
}
