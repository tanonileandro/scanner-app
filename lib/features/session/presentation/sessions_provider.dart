import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di.dart';
import '../../../core/result.dart';
import '../../session/data/repositories/session_repository_impl.dart';
import '../../session/domain/entities/session.dart';

class SessionsState {
  final List<Session> history;
  final int? draftSeq; // camión en curso
  final bool loading;
  final String? error;

  const SessionsState({
    required this.history,
    this.draftSeq,
    this.loading = false,
    this.error,
  });

  SessionsState copyWith({
    List<Session>? history,
    int? draftSeq,
    bool? loading,
    String? error,
  }) => SessionsState(
        history: history ?? this.history,
        draftSeq: draftSeq ?? this.draftSeq,
        loading: loading ?? this.loading,
        error: error,
      );
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  SessionsNotifier(this.mode) : super(const SessionsState(history: [])) {
    loadHistory();
  }

  final String mode; // 'cargar' | 'descargar'
  final _repo = sl<SessionRepository>();

  Future<void> loadHistory() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _repo.historyByMode(mode);
    if (res is Ok<List<Session>>) {
      state = state.copyWith(history: res.data, loading: false);
    } else if (res is Err<List<Session>>) {
      state = state.copyWith(loading: false, error: res.message);
    }
  }

  Future<int?> startDraft({required String transport, required String operatorName}) async {
    final r = await _repo.createDraft(mode: mode, transport: transport, operatorName: operatorName);
    if (r is Ok<int>) {
      state = state.copyWith(draftSeq: r.data);
      return r.data;
    } else if (r is Err<int>) {
      state = state.copyWith(error: r.message);
    }
    return null;
  }

  Future<void> finalize(int seq) async {
    final r = await _repo.finalize(seq);
    if (r is Err<void>) {
      state = state.copyWith(error: r.message);
    }
    state = state.copyWith(draftSeq: null);
    await loadHistory();
  }
}

final cargarSessionsProvider =
    StateNotifierProvider.autoDispose<SessionsNotifier, SessionsState>(
        (ref) => SessionsNotifier('cargar'));

final descargarSessionsProvider =
    StateNotifierProvider.autoDispose<SessionsNotifier, SessionsState>(
        (ref) => SessionsNotifier('descargar'));
