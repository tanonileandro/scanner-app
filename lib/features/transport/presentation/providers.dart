import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di.dart';
import '../../../core/result.dart';
import '../domain/entities/transport.dart';
import '../domain/usecases/add_transport.dart';
import '../domain/usecases/delete_transport.dart';
import '../domain/usecases/get_transports.dart';

final _uuid = const Uuid();

class TransportState {
  final List<Transport> items;
  final String? selected; // nombre seleccionado
  final bool loading;
  final String? error;

  const TransportState({
    required this.items,
    this.selected,
    this.loading = false,
    this.error,
  });

  TransportState copyWith({
    List<Transport>? items,
    String? selected,
    bool? loading,
    String? error,
  }) => TransportState(
        items: items ?? this.items,
        selected: selected ?? this.selected,
        loading: loading ?? this.loading,
        error: error,
      );
}

class TransportNotifier extends StateNotifier<TransportState> {
  TransportNotifier() : super(const TransportState(items: []));

  final _get = sl<GetTransports>();
  final _add = sl<AddTransport>();
  final _del = sl<DeleteTransport>();

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _get();
    if (res is Ok<List<Transport>>) {
      final list = res.data;
      final sel = state.selected ?? (list.isNotEmpty ? list.first.name : null);
      state = state.copyWith(items: list, selected: sel, loading: false);
    } else if (res is Err<List<Transport>>) {
      state = state.copyWith(loading: false, error: res.message);
    }
  }

  void select(String? name) => state = state.copyWith(selected: name);

  Future<void> add(String name) async {
    final t = Transport(id: _uuid.v4(), name: name.trim());
    final res = await _add(t);
    if (res is Err<void>) state = state.copyWith(error: res.message);
    await load();
    state = state.copyWith(selected: name);
  }

  Future<void> delete(String id) async {
    final res = await _del(id);
    if (res is Err<void>) state = state.copyWith(error: res.message);
    await load();
  }
}

final transportProvider =
    StateNotifierProvider<TransportNotifier, TransportState>((ref) {
  final n = TransportNotifier();
  n.load();
  return n;
});
