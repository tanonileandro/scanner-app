import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/settings_provider.dart';
import '../../../core/di.dart';
import '../../../core/result.dart'; // 👈 NECESARIO para usar Ok / Err
import '../../barcode/domain/repositories/barcode_repository.dart';

class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final link = settings.sheetsLink;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Sincronización', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Google Sheets'),
            subtitle: Text(link ?? 'No configurado. Cargá el link en Configuración.'),
            trailing: FilledButton.icon(
              onPressed: (link == null || link.isEmpty)
                  ? null
                  : () async {
                      final repo = sl<BarcodeRepository>();
                      final res = await repo.syncWithSheetLink(link);

                      final ok = res is Ok<void>;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Sincronizado a Sheets' : 'Falló la sincronización')),
                        );
                      }
                    },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Sincronizar'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportar CSV a Drive está disponible en otra parte si lo necesitás.')),
          ),
          icon: const Icon(Icons.info_outline),
          label: const Text('Nota'),
        ),
      ],
    );
  }
}
