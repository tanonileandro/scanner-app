import 'package:flutter/material.dart';
import '../../domain/entities/barcode_item.dart';

class BarcodeListTile extends StatelessWidget {
  final BarcodeItem item;
  final VoidCallback onDelete;
  const BarcodeListTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dt = item.createdAt.toLocal();
    final when = '${dt.year}-${_2(dt.month)}-${_2(dt.day)} ${_2(dt.hour)}:${_2(dt.minute)}:${_2(dt.second)}';
    return ListTile(
      leading: const Icon(Icons.qr_code_2),
      title: Text(item.code),
      subtitle: Text('${item.transport} • ${item.operatorName} • $when'),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
    );
  }

  String _2(int n) => n.toString().padLeft(2, '0');
}
