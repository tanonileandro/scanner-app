import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SessionsDao {
  Database? _db;

  Future<void> init(String dbPath) async {
    _db = await openDatabase(dbPath);
    // Las tablas se crean desde BarcodeDao.onCreate/onUpgrade
  }

  Future<int> createDraft({
    required String mode,
    required String transport,
    required String operatorName,
  }) async {
    final seq = await _db!.insert('sessions', {
      // 'seq' autoincrement
      'mode': mode,
      'transport': transport,
      'operator_name': operatorName,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'status': 'draft',
    });
    return seq; // <-- rowid/autoincrement
  }

  Future<void> finalize(int seq) async {
    await _db!.update('sessions', {'status': 'finalized'},
        where: 'seq = ?', whereArgs: [seq]);
  }

  Future<List<Map<String, Object?>>> listFinalizedByMode(String mode) async {
    return _db!.query('sessions',
        where: 'status = ? AND mode = ?',
        whereArgs: ['finalized', mode],
        orderBy: 'seq DESC');
  }

  Future<Map<String, Object?>?> getBySeq(int seq) async {
    final r = await _db!.query('sessions', where: 'seq = ?', whereArgs: [seq], limit: 1);
    return r.isEmpty ? null : r.first;
  }
}
