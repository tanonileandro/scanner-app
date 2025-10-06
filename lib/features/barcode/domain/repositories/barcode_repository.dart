import '../../../../core/result.dart';
import '../entities/barcode_item.dart';

abstract class BarcodeRepository {
  Future<Result<void>> add(BarcodeItem item);
  Future<Result<List<BarcodeItem>>> all();
  Future<Result<void>> delete(String id);
  Future<Result<void>> clear();

  Future<Result<void>> syncWithDrive();
  Future<Result<void>> syncWithSheetLink(String sheetUrl, {String sheetName = 'Hoja 1'});
}
