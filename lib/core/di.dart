import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../features/barcode/data/datasources/local/barcode_dao.dart';
import '../features/barcode/data/datasources/remote/drive_remote.dart';
import '../features/barcode/data/datasources/remote/sheets_remote.dart';
import '../features/barcode/data/repositories/barcode_repository_impl.dart';
import '../features/barcode/domain/repositories/barcode_repository.dart';
import '../features/barcode/domain/usecases/add_barcode.dart';
import '../features/barcode/domain/usecases/get_barcodes.dart';
import '../features/barcode/domain/usecases/sync_barcodes.dart';
import '../features/barcode/domain/usecases/delete_barcode.dart';
import '../features/barcode/domain/usecases/clear_all.dart';

// Transport
import '../features/transport/data/datasources/local/transport_dao.dart';
import '../features/transport/data/repositories/transport_repository_impl.dart';
import '../features/transport/domain/repositories/transport_repository.dart';
import '../features/transport/domain/usecases/get_transports.dart';
import '../features/transport/domain/usecases/add_transport.dart';
import '../features/transport/domain/usecases/delete_transport.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  final googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/spreadsheets',
    ],
  );
  sl.registerLazySingleton<GoogleSignIn>(() => googleSignIn);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Abrimos una DB para compartirla entre DAOs
  final db = await _openMainDb();
  sl.registerSingleton<Database>(db);

  // DAOs
  final barcodeDao = BarcodeDao();
  await barcodeDao.init(); // usa su propio archivo (barcodes.db)
  sl.registerSingleton<BarcodeDao>(barcodeDao);

  final transportDao = TransportDao(db);
  await transportDao.createIfNeeded();
  sl.registerSingleton<TransportDao>(transportDao);

  // Remotos
  sl.registerLazySingleton<DriveRemote>(() => DriveRemote(
        googleSignIn: sl(),
        httpClient: sl(),
      ));
  sl.registerLazySingleton<SheetsRemote>(() => SheetsRemote(
        googleSignIn: sl(),
        httpClient: sl(),
      ));

  // Repos
  sl.registerLazySingleton<BarcodeRepository>(() => BarcodeRepositoryImpl(
        dao: sl(),
        remote: sl(),
        sheets: sl(),
      ));

  sl.registerLazySingleton<TransportRepository>(() => TransportRepositoryImpl(sl()));

  // UseCases Barcode
  sl.registerLazySingleton(() => AddBarcode(sl()));
  sl.registerLazySingleton(() => GetBarcodes(sl()));
  sl.registerLazySingleton(() => SyncBarcodes(sl()));
  sl.registerLazySingleton(() => DeleteBarcode(sl()));
  sl.registerLazySingleton(() => ClearAll(sl()));

  // UseCases Transport
  sl.registerLazySingleton(() => GetTransports(sl()));
  sl.registerLazySingleton(() => AddTransport(sl()));
  sl.registerLazySingleton(() => DeleteTransport(sl()));
}

Future<Database> _openMainDb() async {
  // Base mínima solo para tabla 'transports'; 'barcodes' está en su propio archivo.
  // Si preferís unificar, podemos migrar luego.
  return openDatabase('main.db', version: 1, onCreate: (db, _) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transports(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      );
    ''');
  });
}
