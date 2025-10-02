import '../../../../core/result.dart';
import '../entities/barcode_item.dart';


abstract class BarcodeRepository {
  Future<Result<void>> add(BarcodeItem item);
  Future<Result<List<BarcodeItem>>> all();
  Future<Result<void>> delete(String id);
  Future<Result<void>> clear();

  /// Sube CSV a Drive (crea o actualiza), y puede traer cambios remotos (futuro).
  Future<Result<void>> syncWithDrive();
}
