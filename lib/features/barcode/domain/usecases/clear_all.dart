import '../../../../core/result.dart';
import '../repositories/barcode_repository.dart';

class ClearAll {
  final BarcodeRepository repo;
  ClearAll(this.repo);

  Future<Result<void>> call() => repo.clear();
}
