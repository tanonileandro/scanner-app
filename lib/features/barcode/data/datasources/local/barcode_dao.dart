import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/barcode_model.dart';

class BarcodeDao {
  Database? _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'barcodes.db');
    _db = await openDatabase(
      dbPath,
      version: 2, // 🚀 subimos versión para agregar 'transport'
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE barcodes(
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL,
            transport TEXT NOT NULL,
            created_at INTEGER NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute("ALTER TABLE barcodes ADD COLUMN transport TEXT NOT NULL DEFAULT '';");
        }
      },
    );
  }

  Future<int> insert(BarcodeModel model) async =>
      await _db!.insert('barcodes', model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<BarcodeModel>> getAll() async {
    final rows = await _db!.query('barcodes', orderBy: 'created_at DESC');
    return rows.map((r) => BarcodeModel.fromMap(r)).toList();
  }

  Future<int> deleteById(String id) async =>
      await _db!.delete('barcodes', where: 'id = ?', whereArgs: [id]);

  Future<int> clear() async => await _db!.delete('barcodes');

  Future<int> clearByTransport(String transport) async =>
      await _db!.delete('barcodes', where: 'transport = ?', whereArgs: [transport]);
}
