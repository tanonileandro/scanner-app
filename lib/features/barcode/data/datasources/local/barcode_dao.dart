import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/barcode_model.dart';

class BarcodeDao {
  Database? _db;
  String? _dbPath;

  Future<String> _resolvePath() async {
    if (_dbPath != null) return _dbPath!;
    final dir = await getApplicationDocumentsDirectory();
    _dbPath = p.join(dir.path, 'barcodes.db');
    return _dbPath!;
  }

  Future<void> init() async {
    final dbPath = await _resolvePath();
    _db = await openDatabase(
      dbPath,
      version: 5, // ⬅️ nueva versión
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE barcodes(
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL,
            transport TEXT NOT NULL,
            operator_name TEXT NOT NULL,
            session_seq INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          );
        ''');
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_barcodes_code ON barcodes(code);');

        await db.execute('''
          CREATE TABLE sessions(
            seq INTEGER PRIMARY KEY AUTOINCREMENT,
            mode TEXT NOT NULL,
            transport TEXT NOT NULL,
            operator_name TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            status TEXT NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute("ALTER TABLE barcodes ADD COLUMN transport TEXT NOT NULL DEFAULT '';");
        }
        if (oldV < 3) {
          await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_barcodes_code ON barcodes(code);');
        }
        if (oldV < 4) {
          await db.execute("ALTER TABLE barcodes ADD COLUMN operator_name TEXT NOT NULL DEFAULT '';");
        }
        if (oldV < 5) {
          await db.execute("ALTER TABLE barcodes ADD COLUMN session_seq INTEGER NOT NULL DEFAULT -1;");
          await db.execute('''
            CREATE TABLE IF NOT EXISTS sessions(
              seq INTEGER PRIMARY KEY AUTOINCREMENT,
              mode TEXT NOT NULL,
              transport TEXT NOT NULL,
              operator_name TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              status TEXT NOT NULL
            );
          ''');
        }
      },
    );
  }

  // Para que otros DAO usen el mismo archivo si lo necesitan
  Future<String> dbPath() async => _resolvePath();

  Future<bool> existsCode(String code) async {
    final rows = await _db!.query('barcodes', columns: ['id'], where: 'code = ?', whereArgs: [code], limit: 1);
    return rows.isNotEmpty;
  }

  Future<int> insert(BarcodeModel m) async =>
      await _db!.insert('barcodes', m.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<List<BarcodeModel>> getAll() async {
    final rows = await _db!.query('barcodes', orderBy: 'created_at DESC');
    return rows.map((r) => BarcodeModel.fromMap(r)).toList();
  }

  Future<List<BarcodeModel>> getBySession(int sessionSeq) async {
    final rows = await _db!.query('barcodes',
        where: 'session_seq = ?', whereArgs: [sessionSeq], orderBy: 'created_at DESC');
    return rows.map((r) => BarcodeModel.fromMap(r)).toList();
  }

  Future<int> deleteById(String id) async =>
      await _db!.delete('barcodes', where: 'id = ?', whereArgs: [id]);

  Future<int> clear() async => await _db!.delete('barcodes');
}
