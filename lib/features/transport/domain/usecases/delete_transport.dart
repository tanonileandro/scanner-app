import '../../../../core/result.dart';
import '../repositories/transport_repository.dart';

class DeleteTransport {
  final TransportRepository repo;
  DeleteTransport(this.repo);
  Future<Result<void>> call(String id) => repo.delete(id);
}
