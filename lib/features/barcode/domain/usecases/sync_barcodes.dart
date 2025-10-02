import '../../../../core/result.dart';
import '../repositories/barcode_repository.dart';

class SyncBarcodes {
  final BarcodeRepository repo;
  SyncBarcodes(this.repo);

  Future<Result<void>> call() => repo.syncWithDrive();
}
