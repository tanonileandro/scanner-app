import 'package:sqflite/sqflite.dart';

class TransportDao {
  final Database db;
  TransportDao(this.db);

  Future<void> createIfNeeded() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transports(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      );
    ''');
  }

  Future<int> insert(Map<String, Object?> row) =>
      db.insert('transports', row, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<List<Map<String, Object?>>> getAll() =>
      db.query('transports', orderBy: 'name ASC');

  Future<int> deleteById(String id) =>
      db.delete('transports', where: 'id = ?', whereArgs: [id]);
}
