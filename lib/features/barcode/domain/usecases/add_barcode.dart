import '../../../../core/result.dart';
import '../entities/barcode_item.dart';
import '../repositories/barcode_repository.dart';

class AddBarcode {
  final BarcodeRepository repo;
  AddBarcode(this.repo);

  Future<Result<void>> call(BarcodeItem item) => repo.add(item);
}
