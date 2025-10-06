import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di.dart';
import '../../../core/result.dart';
import '../domain/entities/barcode_item.dart';
import '../domain/usecases/add_barcode.dart';
import '../domain/usecases/get_barcodes.dart';
import '../domain/usecases/sync_barcodes.dart';
import '../domain/usecases/delete_barcode.dart';
import '../domain/usecases/clear_all.dart';

final _uuid = const Uuid();

class BarcodeState {
  final List<BarcodeItem> items;
  final bool loading;
  final String? error;

  const BarcodeState({required this.items, this.loading = false, this.error});

  BarcodeState copyWith({List<BarcodeItem>? items, bool? loading, String? error}) =>
      BarcodeState(items: items ?? this.items, loading: loading ?? this.loading, error: error);
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

  Future<String?> addCode({
    required String code,
    required String transport,
    required String operatorName,
    required int sessionSeq,
  }) async {
    final item = BarcodeItem(
      id: _uuid.v4(),
      code: code.trim(),
      transport: transport,
      operatorName: operatorName.trim(),
      sessionSeq: sessionSeq,
      createdAt: DateTime.now(),
    );
    final res = await _add(item);
    if (res is Err<void>) {
      state = state.copyWith(error: res.message);
      return res.message;
    }
    await load();
    return null;
  }

  Future<void> deleteById(String id) async {
    final res = await _del(id);
    if (res is Err<void>) state = state.copyWith(error: res.message);
    await load();
  }

  Future<void> clearAll() async {
    final res = await _clear();
    if (res is Err<void>) state = state.copyWith(error: res.message);
    await load();
  }

  Future<void> syncDrive() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _sync();
    state = state.copyWith(loading: false, error: (res is Err<void>) ? res.message : null);
  }
}

final barcodeProvider =
    StateNotifierProvider<BarcodeNotifier, BarcodeState>((ref) {
  final n = BarcodeNotifier();
  n.load();
  return n;
});
