import '../../../../core/result.dart';
import '../entities/transport.dart';
import '../repositories/transport_repository.dart';

class GetTransports {
  final TransportRepository repo;
  GetTransports(this.repo);
  Future<Result<List<Transport>>> call() => repo.all();
}
