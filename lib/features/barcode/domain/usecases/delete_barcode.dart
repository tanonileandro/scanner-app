import '../../../../core/result.dart';
import '../repositories/barcode_repository.dart';

class DeleteBarcode {
  final BarcodeRepository repo;
  DeleteBarcode(this.repo);

  Future<Result<void>> call(String id) => repo.delete(id);
}
