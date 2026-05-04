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
          GoRoute(path: '/idm', builder: (context, state) => const IdmScreen()),
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
