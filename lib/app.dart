import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/barcode/presentation/pages/home_page.dart';
import 'features/barcode/presentation/pages/scan_page.dart';
import 'features/transport/presentation/pages/settings_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage(), routes: [
      GoRoute(path: 'scan', builder: (_, __) => const ScanPage()),
      GoRoute(path: 'settings', builder: (_, __) => const SettingsPage()),
    ]),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp.router(
      title: 'Barcode Sync',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: _router,
    );
  }
}
