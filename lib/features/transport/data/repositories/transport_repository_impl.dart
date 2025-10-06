import '../../../../core/result.dart';
import '../../domain/entities/transport.dart';
import '../../domain/repositories/transport_repository.dart';
import '../datasources/local/transport_dao.dart';

class TransportRepositoryImpl implements TransportRepository {
  final TransportDao dao;
  TransportRepositoryImpl(this.dao);

  @override
  Future<Result<void>> add(Transport t) async {
    try {
      await dao.insert({'id': t.id, 'name': t.name});
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo agregar el transportista', e, s);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await dao.deleteById(id);
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo eliminar', e, s);
    }
  }

  @override
  Future<Result<List<Transport>>> all() async {
    try {
      final rows = await dao.getAll();
      final list = rows.map((r) => Transport(
        id: r['id'] as String,
        name: r['name'] as String,
      )).toList();
      return Result.ok(list);
    } catch (e, s) {
      return Result.err('Error leyendo transportistas', e, s);
    }
  }
}
