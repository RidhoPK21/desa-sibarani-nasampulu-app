import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../presentation/screens/admin/idm_admin_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/idm/idm_screen.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/layouts/public_layout.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) =>
            PublicLayout(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(),
          ),
          GoRoute(
            path: '/profil',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Profil'),
          ),
          GoRoute(
            path: '/infografis',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Infografis'),
          ),
          GoRoute(
            path: '/kegiatan',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Kegiatan'),
          ),
          GoRoute(path: '/idm', builder: (context, state) => const IdmScreen()),
          GoRoute(
            path: '/dokumentasi',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Dokumentasi'),
          ),
          GoRoute(
            path: '/berita',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Berita'),
          ),
          GoRoute(
            path: '/apb-desa',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'APB Desa'),
          ),
          GoRoute(
            path: '/galeri',
            builder: (context, state) =>
                const _ComingSoonScreen(title: 'Galeri'),
          ),
        ],
      ),
      GoRoute(
        path: '/login-rahasia',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            return LoginScreen(
              onLogin: () async {
                await ref.read(authProvider.notifier).login('demo-token');
                if (!context.mounted) return;
                context.go('/admin');
              },
            );
          },
        ),
      ),
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text(
                  'Dashboard Admin\nPilih menu Kelola IDM dari drawer.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/admin/idm',
            builder: (context, state) => const IdmAdminScreen(),
          ),
        ],
      ),
    ],
  );
});

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 52,
                color: Color(0xFF4EA674),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123524),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman ini sedang dipersiapkan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
