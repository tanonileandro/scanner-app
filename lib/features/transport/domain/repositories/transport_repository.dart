import '../../../../core/result.dart';
import '../entities/transport.dart';

abstract class TransportRepository {
  Future<Result<List<Transport>>> all();
  Future<Result<void>> add(Transport t);
  Future<Result<void>> delete(String id);
}
