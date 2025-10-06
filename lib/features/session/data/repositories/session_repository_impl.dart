import '../../../../core/result.dart';
import '../../domain/entities/session.dart';
import '../sessions_dao.dart';

class SessionRepository {
  final SessionsDao dao;
  SessionRepository(this.dao);

  Future<Result<int>> createDraft({required String mode, required String transport, required String operatorName}) async {
    try {
      final seq = await dao.createDraft(mode: mode, transport: transport, operatorName: operatorName);
      return Result.ok(seq);
    } catch (e, s) {
      return Result.err('No se pudo iniciar el camión', e, s);
    }
  }

  Future<Result<void>> finalize(int seq) async {
    try {
      await dao.finalize(seq);
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo finalizar el camión', e, s);
    }
  }

  Future<Result<List<Session>>> historyByMode(String mode) async {
    try {
      final rows = await dao.listFinalizedByMode(mode);
      final list = rows.map((r) => Session(
        seq: r['seq'] as int,
        mode: r['mode'] as String,
        transport: r['transport'] as String,
        operatorName: r['operator_name'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
        status: r['status'] as String,
      )).toList();
      return Result.ok(list);
    } catch (e, s) {
      return Result.err('Error leyendo histórico', e, s);
    }
  }

  Future<Result<Session>> get(int seq) async {
    try {
      final r = await dao.getBySeq(seq);
      if (r == null) return Result.err('Camión no encontrado');
      final s = Session(
        seq: r['seq'] as int,
        mode: r['mode'] as String,
        transport: r['transport'] as String,
        operatorName: r['operator_name'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
        status: r['status'] as String,
      );
      return Result.ok(s);
    } catch (e, s) {
      return Result.err('Error leyendo camión', e, s);
    }
  }
}
