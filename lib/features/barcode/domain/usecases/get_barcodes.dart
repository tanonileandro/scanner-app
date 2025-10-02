import '../../../../core/result.dart';
import '../entities/barcode_item.dart';
import '../repositories/barcode_repository.dart';

class GetBarcodes {
  final BarcodeRepository repo;
  GetBarcodes(this.repo);

  Future<Result<List<BarcodeItem>>> call() => repo.all();
}
