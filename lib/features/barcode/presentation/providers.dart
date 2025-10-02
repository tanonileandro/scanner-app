import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di.dart';
import '../../../core/result.dart';
import '../../barcode/domain/entities/barcode_item.dart';
import '../../barcode/domain/usecases/add_barcode.dart';
import '../../barcode/domain/usecases/get_barcodes.dart';
import '../../barcode/domain/usecases/sync_barcodes.dart';
import '../../barcode/domain/usecases/delete_barcode.dart';
import '../../barcode/domain/usecases/clear_all.dart';

final uuid = Uuid();

class BarcodeState {
  final List<BarcodeItem> items;
  final bool loading;
  final String? error;

  const BarcodeState({required this.items, this.loading = false, this.error});

  BarcodeState copyWith({
    List<BarcodeItem>? items,
    bool? loading,
    String? error,
  }) =>
      BarcodeState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: error,
      );
}

class BarcodeNotifier extends StateNotifier<BarcodeState> {
  BarcodeNotifier() : super(const BarcodeState(items: []));

  final _get = sl<GetBarcodes>();
  final _add = sl<AddBarcode>();
  final _del = sl<DeleteBarcode>();
  final _clear = sl<ClearAll>();
  final _sync = sl<SyncBarcodes>();

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _get();
    if (res is Ok<List<BarcodeItem>>) {
      state = state.copyWith(items: res.data, loading: false);
    } else if (res is Err<List<BarcodeItem>>) {
      state = state.copyWith(loading: false, error: res.message);
    }
  }

  Future<void> addCode({
    required String code,
    required String transport,
  }) async {
    final item = BarcodeItem(
      id: uuid.v4(),
      code: code,
      transport: transport,
      createdAt: DateTime.now(),
    );
    final res = await _add(item);
    if (res is Err<void>) {
      state = state.copyWith(error: res.message);
    }
    await load();
  }

  Future<void> deleteById(String id) async {
    final res = await _del(id);
    if (res is Err<void>) {
      state = state.copyWith(error: res.message);
    }
    await load();
  }

  Future<void> clearAll() async {
    final res = await _clear();
    if (res is Err<void>) {
      state = state.copyWith(error: res.message);
    }
    await load();
  }

  Future<void> syncDrive() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _sync();
    if (res is Err<void>) {
      state = state.copyWith(loading: false, error: res.message);
    } else {
      state = state.copyWith(loading: false);
    }
  }
}

final barcodeProvider =
    StateNotifierProvider<BarcodeNotifier, BarcodeState>((ref) {
  final n = BarcodeNotifier();
  n.load();
  return n;
});
