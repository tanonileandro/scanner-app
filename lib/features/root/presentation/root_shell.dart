import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootShell extends StatefulWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indexForLocation(String l) => l.startsWith('/sync') ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _indexForLocation(loc);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Códigos'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            icon: const Icon(Icons.more_vert),
            onSelected: (v) { if (v == 'settings') context.go('/settings'); },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Configuración'),
              )),
            ],
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => i == 0 ? context.go('/home') : context.go('/sync'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_outlined), activeIcon: Icon(Icons.sync), label: 'Sincronizar'),
        ],
      ),
    );
  }
}
