import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../features/admin/infografis/pages/infografis_screen.dart';
import '../../features/admin/infografis/pages/tambah_dusun_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // 🔥 LOGIKA REDIRECT YANG LEBIH CERDAS
    redirect: (context, state) {
      final path = state.uri.path;
      final isGoingToAdmin = path.startsWith('/admin');
      final isGoingToLogin = path == '/login-rahasia';

      // 1. Jika ke arah Admin tapi belum login -> Tendang ke Beranda
      if (isGoingToAdmin && !authState) {
        return '/';
      }

      // 2. Jika ke arah Login tapi SUDAH login -> Langsung ke Dashboard Admin
      if (isGoingToLogin && authState) {
        return '/admin';
      }

      return null;
    },

    routes: [
      // --- AREA PUBLIK ---
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) => PublicLayout(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(),
          ),
          GoRoute(
            path: '/idm',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Halaman IDM Publik'))),
          ),
        ],
      ),

      // --- LOGIN ---
      GoRoute(
        path: '/login-rahasia',
        builder: (context, state) => LoginScreen(
          onLogin: () async {
            // Melakukan proses login
            await ref.read(authProvider.notifier).login("dummy_token");
            // Navigasi ke admin akan ditangani otomatis oleh 'redirect' di atas 
            // karena authState berubah, tapi kita panggil manual agar instan.
            if (context.mounted) {
              context.go('/admin');
            }
          },
        ),
      ),

      // --- AREA ADMIN ---
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const InfografisScreen(),
          ),
          GoRoute(
            path: '/admin/infografis/tambah',
            builder: (context, state) => const TambahDusunScreen(),
          ),
          GoRoute(
            path: '/admin/idm',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Halaman Kelola IDM'))),
          ),
        ],
      ),
    ],
  );
});
