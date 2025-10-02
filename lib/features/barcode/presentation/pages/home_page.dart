import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../transport/presentation/providers.dart';
import '../providers.dart';
import '../widgets/barcode_list_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bcState = ref.watch(barcodeProvider);
    final bcNotifier = ref.read(barcodeProvider.notifier);

    final trState = ref.watch(transportProvider);
    final trNotifier = ref.read(transportProvider.notifier);

    final selected = trState.selected;
    final filtered = selected == null
        ? <dynamic>[]
        : bcState.items.where((e) => e.transport == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Códigos'),
        actions: [
          IconButton(
            tooltip: 'Configurar transportistas',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Sincronizar con Google Sheets (usar link en código)',
            onPressed: bcState.loading ? null : () => bcNotifier.syncDrive(),
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            tooltip: 'Vaciar todo',
            onPressed: (!bcState.loading && bcState.items.isNotEmpty)
                ? () => bcNotifier.clearAll()
                : null,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: 'Escanear',
            onPressed: () => context.push('/scan'),
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          if (bcState.error != null)
            MaterialBanner(
              content: Text(bcState.error!),
              actions: [
                TextButton(onPressed: () => bcNotifier.load(), child: const Text('Reintentar')),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selected,
                    hint: const Text('Seleccioná un transportista'),
                    items: trState.items
                        .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => trNotifier.select(v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (selected == null)
                ? _EmptyTransport(onGoSettings: () => context.push('/settings'))
                : (filtered.isEmpty
                    ? _EmptyList(onScan: () => context.push('/scan'))
                    : RefreshIndicator(
                        onRefresh: () => bcNotifier.load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) => BarcodeListTile(
                            item: filtered[i],
                            onDelete: () => bcNotifier.deleteById(filtered[i].id),
                          ),
                        ),
                      )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear'),
        onPressed: () => context.push('/scan'),
      ),
    );
  }
}

class _EmptyTransport extends StatelessWidget {
  final VoidCallback onGoSettings;
  const _EmptyTransport({required this.onGoSettings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 72),
            const SizedBox(height: 12),
            const Text('No hay transportistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Agregá uno desde la Configuración.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onGoSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Ir a Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyList({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 72),
            const SizedBox(height: 12),
            const Text('No hay códigos para este transporte',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tocá “Escanear” para empezar.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Escanear con cámara'),
            ),
          ],
        ),
      ),
    );
  }
}
