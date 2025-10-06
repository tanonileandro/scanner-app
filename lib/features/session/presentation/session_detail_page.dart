import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di.dart';
import '../../../core/result.dart'; // ✅ Necesario para Ok/Err tipados
import '../../session/data/repositories/session_repository_impl.dart';
import '../../barcode/data/datasources/local/barcode_dao.dart';
import '../../barcode/presentation/widgets/barcode_list_tile.dart';
import '../../barcode/data/models/barcode_model.dart';
import '../../session/domain/entities/session.dart';

class SessionDetailPage extends ConsumerStatefulWidget {
  const SessionDetailPage({super.key});

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage> {
  int? seq;
  List<BarcodeModel> items = [];
  String title = 'Detalle de camión';
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    final q = GoRouterState.of(context).uri.queryParameters;
    seq = int.tryParse(q['seq'] ?? '');
    _load();
  }

  Future<void> _load() async {
    if (seq == null) {
      setState(() {
        loading = false;
        error = 'Parámetro inválido';
      });
      return;
    }

    final repo = sl<SessionRepository>();
    final r = await repo.get(seq!);

    if (r is Ok<Session>) {
      final s = r.data;
      title = 'Camión #${s.seq} · ${s.transport}';
      final dao = sl<BarcodeDao>();
      items = await dao.getBySession(seq!);
      setState(() {
        loading = false;
      });
    } else if (r is Err<Session>) {
      setState(() {
        loading = false;
        error = r.message;
      });
    } else {
      // fallback improbable
      setState(() {
        loading = false;
        error = 'Error desconocido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => BarcodeListTile(
                    item: items[i],
                    onDelete: () {}, // Detalle en solo lectura
                  ),
                ),
    );
  }
}
