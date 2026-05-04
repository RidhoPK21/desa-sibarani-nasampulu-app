import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/public/beranda/screens/berita_screen.dart';
import '../../features/public/beranda/screens/beranda_screen.dart'; // Import BerandaScreen lama
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    routes: [
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) => PublicLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(), // Halaman Beranda
          ),
          GoRoute(
            path: '/berita',
            builder: (context, state) => const BeritaScreen(), // Halaman Berita
          ),
        ],
      ),

      GoRoute(
          path: '/login-rahasia',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Halaman Login Admin')))
      ),

      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const Scaffold(body: Center(child: Text('Dashboard Admin')))),
        ],
      ),
    ],
  );
});
