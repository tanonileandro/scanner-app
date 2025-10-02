import '../../../../core/result.dart';
import '../entities/transport.dart';
import '../repositories/transport_repository.dart';

class AddTransport {
  final TransportRepository repo;
  AddTransport(this.repo);
  Future<Result<void>> call(Transport t) => repo.add(t);
}
