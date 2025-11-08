import 'package:sqflite/sqflite.dart';
import '../../../common/constants.dart';
import '../../../common/data/local/app_database.dart';
import 'session_entity.dart';

class SessionDao {
  Future<Database> get _db async => AppDatabase.instance();

  Future<int> upsert(SessionEntity entity) async {
    final db = await _db;
    await db.delete(Constants.sessionTable);
    return db.insert(Constants.sessionTable, entity.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> clear() async {
    final db = await _db;
    return db.delete(Constants.sessionTable);
  }

  Future<SessionEntity?> getLatest() async {
    final db = await _db;
    final res = await db.query(Constants.sessionTable, orderBy: 'createdAt DESC', limit: 1);
    if (res.isEmpty) return null;
    return SessionEntity.fromMap(res.first);
  }
}
