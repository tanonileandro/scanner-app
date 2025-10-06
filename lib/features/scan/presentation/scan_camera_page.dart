import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../transport/presentation/providers.dart';
import '../../barcode/presentation/providers.dart';

class ScanCameraPage extends ConsumerStatefulWidget {
  const ScanCameraPage({super.key});

  @override
  ConsumerState<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends ConsumerState<ScanCameraPage> {
  bool _busy = false;

  Future<void> _save(String raw, String operatorName, int sessionSeq) async {
    if (_busy) return;
    _busy = true;

    final transport = ref.read(transportProvider).selected;
    if (transport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un transportista antes de escanear.')),
      );
      _busy = false;
      return;
    }
    final err = await ref.read(barcodeProvider.notifier)
        .addCode(code: raw, transport: transport, operatorName: operatorName, sessionSeq: sessionSeq);
    if (mounted) {
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leído [#$sessionSeq - $transport - $operatorName]: $raw')),
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 600));
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final transport = ref.watch(transportProvider).selected;
    final params = GoRouterState.of(context).uri.queryParameters;
    final op = params['op'] ?? '';
    final seq = int.tryParse(params['seq'] ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear con cámara')),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw != null && seq != null) _save(raw, op, seq);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Chip(
                  avatar: const Icon(Icons.local_shipping_outlined),
                  label: Text(transport == null || seq == null
                      ? 'Sin camión/transportista'
                      : 'Camión #$seq · $transport'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
