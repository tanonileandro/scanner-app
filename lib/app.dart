import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/root/presentation/root_shell.dart';
import 'features/home/presentation/start_page.dart';
import 'features/operation/presentation/operation_page.dart';
import 'features/sync/presentation/sync_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'features/scan/presentation/scan_camera_page.dart';
import 'features/session/presentation/session_detail_page.dart';

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => RootShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const StartPage()),
        GoRoute(path: '/sync', builder: (_, __) => const SyncPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        GoRoute(
          path: '/operation',
          builder: (ctx, st) {
            final mode = st.uri.queryParameters['mode'] ?? 'cargar';
            return OperationPage(mode: mode);
          },
        ),
        GoRoute(path: '/scan-camera', builder: (_, __) => const ScanCameraPage()),
        GoRoute(path: '/session-detail', builder: (_, __) => const SessionDetailPage()),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp.router(
      title: 'Barcode Sync',
      debugShowCheckedModeBanner: false,
      theme: base,
      routerConfig: _router,
    );
  }
}
