import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../transport/presentation/providers.dart';
import '../providers.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _hidController = TextEditingController();
  final _hidFocus = FocusNode();

  @override
  void dispose() {
    _hidController.dispose();
    _hidFocus.dispose();
    super.dispose();
  }

  void _save(String code, String? transport) {
    if (transport == null || transport.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un transportista antes de escanear')),
      );
      return;
    }
    ref.read(barcodeProvider.notifier).addCode(code: code, transport: transport);
  }

  void _onKeyboardSubmit(String value) {
    final code = value.trim();
    if (code.isEmpty) return;
    final transport = ref.read(transportProvider).selected;
    _save(code, transport);
    _hidController.clear();
    _hidFocus.requestFocus();
    if (transport != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leído (HID) [$transport]: $code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transport = ref.watch(transportProvider).selected;

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear')),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw == null) return;
              _save(raw, transport);
              if (transport != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Leído (Cámara) [$transport]: $raw')),
                );
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Chip(
                  avatar: const Icon(Icons.local_shipping_outlined),
                  label: Text(transport ?? 'Sin transporte seleccionado'),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: ListTile(
                  title: const Text('Scanner Bluetooth (HID)'),
                  subtitle: const Text('Colocá el foco y escaneá; Enter confirma'),
                  trailing: SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _hidController,
                      focusNode: _hidFocus,
                      decoration: const InputDecoration(hintText: 'Enfoque aquí'),
                      onSubmitted: _onKeyboardSubmit,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Foco HID'),
        onPressed: () => _hidFocus.requestFocus(),
      ),
    );
  }
}
