import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../transport/presentation/providers.dart';
import '../../settings/presentation/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trState = ref.watch(transportProvider);
    final trNotifier = ref.read(transportProvider.notifier);

    final st = ref.watch(settingsProvider);
    final stNotifier = ref.read(settingsProvider.notifier);
    final linkCtl = TextEditingController(text: st.sheetsLink ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Google Sheets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: linkCtl,
            decoration: const InputDecoration(
              labelText: 'Link de Google Sheets (compartido a tu cuenta)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: st.saving ? null : () => stNotifier.saveLink(linkCtl.text.trim()),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar link'),
            ),
          ),
          const Divider(height: 32),
          const Text('Transportistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (trState.error != null)
            MaterialBanner(
              content: Text(trState.error!),
              actions: [TextButton(onPressed: trNotifier.load, child: const Text('Reintentar'))],
            ),
          ...trState.items.map((t) => ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(t.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => trNotifier.delete(t.id),
                ),
                onTap: () => trNotifier.select(t.name),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final name = await showDialog<String>(
                context: context, builder: (_) => const _AddTransportDialog());
              if (name != null && name.trim().isNotEmpty) trNotifier.add(name);
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar transportista'),
          ),
        ],
      ),
    );
  }
}

class _AddTransportDialog extends StatefulWidget {
  const _AddTransportDialog();

  @override
  State<_AddTransportDialog> createState() => _AddTransportDialogState();
}
class _AddTransportDialogState extends State<_AddTransportDialog> {
  final c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo transportista'),
      content: TextField(
        controller: c,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nombre'),
        onSubmitted: (_) => Navigator.pop(context, c.text),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Guardar')),
      ],
    );
  }
}
