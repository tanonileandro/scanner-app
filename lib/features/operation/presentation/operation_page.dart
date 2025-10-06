import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../transport/presentation/providers.dart';
import '../../barcode/presentation/providers.dart';
import '../../session/presentation/sessions_provider.dart';

class OperationPage extends ConsumerStatefulWidget {
  final String mode; // 'cargar' | 'descargar'
  const OperationPage({super.key, required this.mode});

  @override
  ConsumerState<OperationPage> createState() => _OperationPageState();
}

class _OperationPageState extends ConsumerState<OperationPage> {
  final _hidController = TextEditingController();
  final _hidFocus = FocusNode();
  final _operatorCtl = TextEditingController();
  bool _showHid = false;

  @override
  void dispose() {
    _hidController.dispose();
    _hidFocus.dispose();
    _operatorCtl.dispose();
    super.dispose();
  }

  SessionsState _sessions(WidgetRef ref) =>
      widget.mode == 'cargar' ? ref.watch(cargarSessionsProvider) : ref.watch(descargarSessionsProvider);
  SessionsNotifier _sessionsNotifier(WidgetRef ref) =>
      widget.mode == 'cargar' ? ref.read(cargarSessionsProvider.notifier) : ref.read(descargarSessionsProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final trState = ref.watch(transportProvider);
    final trNotifier = ref.read(transportProvider.notifier);
    final sesState = _sessions(ref);
    final sesNotifier = _sessionsNotifier(ref);

    final title = widget.mode == 'descargar' ? 'Descargar camión' : 'Cargar camión';
    final historicTitle = widget.mode == 'descargar'
        ? 'Histórico de camiones descargados'
        : 'Histórico de camiones cargados';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(widget.mode == 'descargar' ? Icons.download_rounded : Icons.upload_rounded),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),

        // Selector de transportista
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Seleccionar transportista',
            prefixIcon: Icon(Icons.local_shipping_outlined),
            border: OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: trState.selected,
              hint: const Text('Elegí un transportista'),
              isExpanded: true,
              items: trState.items
                  .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => trNotifier.select(v),
            ),
          ),
        ),
        if (trState.items.isEmpty) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton.icon(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.add),
            label: const Text('Agregar transportista'),
          ),
        ),

        const SizedBox(height: 12),

        // Operador (persona de logística)
        TextField(
          controller: _operatorCtl,
          decoration: const InputDecoration(
            labelText: 'Persona de logística',
            hintText: 'Nombre y apellido',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),

        const SizedBox(height: 12),

        // Estado de camión en curso
        if (sesState.draftSeq != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(
              avatar: const Icon(Icons.local_shipping_outlined),
              label: Text('Camión #${sesState.draftSeq} (en curso)'),
            ),
          ),

        // Acciones: Iniciar camión / Escanear
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.playlist_add),
                label: const Text('Iniciar camión'),
                onPressed: () async {
                  final transport = trState.selected;
                  final op = _operatorCtl.text.trim();
                  if (transport == null || transport.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seleccioná un transportista.')),
                    );
                    return;
                  }
                  if (op.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingresá la persona de logística.')),
                    );
                    return;
                  }
                  final seq = await sesNotifier.startDraft(transport: transport, operatorName: op);
                  if (seq != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Camión #$seq iniciado')),
                    );
                    setState((){});
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.center_focus_strong),
                label: const Text('Escanear con cámara'),
                onPressed: (sesState.draftSeq == null)
                    ? null
                    : () {
                        final op = _operatorCtl.text.trim();
                        final seq = sesState.draftSeq!;
                        context.go('/scan-camera?op=${Uri.encodeComponent(op)}&seq=$seq');
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.keyboard),
                label: const Text('Escáner (HID)'),
                onPressed: (sesState.draftSeq == null)
                    ? null
                    : () {
                        setState(() => _showHid = true);
                        _hidFocus.requestFocus();
                      },
              ),
            ),
          ],
        ),
        if (_showHid && sesState.draftSeq != null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _hidController,
            focusNode: _hidFocus,
            decoration: const InputDecoration(
              labelText: 'Apunte aquí y dispare el lector (Enter confirma)',
              prefixIcon: Icon(Icons.qr_code_2),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) async {
              final code = v.trim();
              if (code.isNotEmpty) {
                final transport = trState.selected!;
                final op = _operatorCtl.text.trim();
                final seq = sesState.draftSeq!;
                final err = await ref.read(barcodeProvider.notifier).addCode(
                      code: code, transport: transport, operatorName: op, sessionSeq: seq);
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leído: $code')));
                }
              }
              _hidController.clear();
              _hidFocus.requestFocus();
            },
            textInputAction: TextInputAction.done,
          ),
        ],

        const SizedBox(height: 12),

        // Guardar / finalizar
        FilledButton.icon(
          icon: const Icon(Icons.save_outlined),
          label: Text(widget.mode == 'descargar' ? 'Guardar descarga' : 'Guardar carga'),
          onPressed: (sesState.draftSeq == null)
              ? null
              : () async {
                  await sesNotifier.finalize(sesState.draftSeq!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camión guardado')),
                    );
                  }
                },
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.history),
            const SizedBox(width: 8),
            Text(historicTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),

        if (sesState.loading) const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        )
        else if (sesState.history.isEmpty)
          const Text('Aún no hay camiones guardados.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sesState.history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = sesState.history[i];
              final dt = s.createdAt.toLocal();
              final when = '${dt.year}-${_2(dt.month)}-${_2(dt.day)} ${_2(dt.hour)}:${_2(dt.minute)}';
              return ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text('Camión #${s.seq} · ${s.transport}'),
                subtitle: Text(when),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/session-detail?seq=${s.seq}'),
              );
            },
          ),
      ],
    );
  }
}

String _2(int n) => n.toString().padLeft(2, '0');
