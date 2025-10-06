import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _BigAction(
          title: 'Cargar camión',
          icon: Icons.upload_rounded,
          color: Colors.green,
          onTap: () => context.go('/operation?mode=cargar'),
        ),
        const SizedBox(height: 12),
        _BigAction(
          title: 'Descargar camión',
          icon: Icons.download_rounded,
          color: Colors.orange,
          onTap: () => context.go('/operation?mode=descargar'),
        ),
      ],
    );
  }
}

class _BigAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BigAction({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
