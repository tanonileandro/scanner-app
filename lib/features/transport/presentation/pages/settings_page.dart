import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transportProvider);
    final notifier = ref.read(transportProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Transportistas')),
      body: Column(
        children: [
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              actions: [TextButton(onPressed: notifier.load, child: const Text('Reintentar'))],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.load,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final t = state.items[i];
                  final selected = t.name == state.selected;
                  return ListTile(
                    title: Text(t.name),
                    leading: selected ? const Icon(Icons.check_circle) : const Icon(Icons.local_shipping_outlined),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => notifier.delete(t.id),
                    ),
                    onTap: () => notifier.select(t.name),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        onPressed: () async {
          final name = await showDialog<String>(
            context: context,
            builder: (_) => const _AddDialog(),
          );
          if (name != null && name.trim().isNotEmpty) {
            await notifier.add(name);
          }
        },
      ),
    );
  }
}

class _AddDialog extends StatefulWidget {
  const _AddDialog();

  @override
  State<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<_AddDialog> {
  final c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo transportista'),
      content: TextField(
        controller: c,
        decoration: const InputDecoration(hintText: 'Nombre del transporte'),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.pop(context, c.text),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Guardar')),
      ],
    );
  }
}
