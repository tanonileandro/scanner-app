import '../../../../core/result.dart';
import '../../domain/entities/barcode_item.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../datasources/local/barcode_dao.dart';
import '../datasources/remote/drive_remote.dart';
import '../datasources/remote/sheets_remote.dart';
import '../models/barcode_model.dart';

class BarcodeRepositoryImpl implements BarcodeRepository {
  final BarcodeDao dao;
  final DriveRemote remote;
  final SheetsRemote sheets;

  BarcodeRepositoryImpl({required this.dao, required this.remote, required this.sheets});

  @override
  Future<Result<void>> add(BarcodeItem item) async {
    try {
      if (await dao.existsCode(item.code)) {
        return Result.err('El código ya fue escaneado.');
      }
      await dao.insert(BarcodeModel.fromEntity(item));
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo guardar el código', e, s);
    }
  }

  @override
  Future<Result<List<BarcodeItem>>> all() async {
    try {
      final rows = await dao.getAll();
      final list = List<BarcodeItem>.from(rows);
      return Result.ok(list);
    } catch (e, s) {
      return Result.err('Error leyendo base local', e, s);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await dao.deleteById(id);
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo eliminar', e, s);
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await dao.clear();
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('No se pudo limpiar', e, s);
    }
  }

  @override
  Future<Result<void>> syncWithDrive() async {
    try {
      final rows = await dao.getAll();
      await remote.uploadCsv(rows);
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('Falló la sincronización con Drive', e, s);
    }
  }

  @override
  Future<Result<void>> syncWithSheetLink(String sheetUrl, {String sheetName = 'Hoja 1'}) async {
    try {
      final id = SheetsRemote.extractSpreadsheetId(sheetUrl);
      if (id == null) return Result.err('Link de Google Sheets inválido.');
      final rows = await dao.getAll();
      await sheets.appendBarcodes(spreadsheetId: id, sheetName: sheetName, items: rows);
      return Result.ok(null);
    } catch (e, s) {
      return Result.err('Falló la sincronización con Google Sheets', e, s);
    }
  }
}

