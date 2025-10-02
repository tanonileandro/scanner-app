import 'package:flutter/material.dart';
import '../../domain/entities/barcode_item.dart';

class BarcodeListTile extends StatelessWidget {
  final BarcodeItem item;
  final VoidCallback onDelete;
  const BarcodeListTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdAt.toLocal().toString();
    return ListTile(
      leading: const Icon(Icons.qr_code_2),
      title: Text(item.code),
      subtitle: Text('${item.transport} • $dateStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
