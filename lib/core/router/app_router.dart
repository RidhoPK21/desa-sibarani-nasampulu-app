import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../features/auth/pages/login_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider); // Pantau status login

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // 🔥 SATPAM ROUTER (Redirect Guard)
    // Jika user mencoba buka '/admin' tapi belum login, tendang ke '/'
    redirect: (context, state) {
      final isGoingToAdmin = state.uri.toString().startsWith('/admin');
      if (isGoingToAdmin && !authState) {
        return '/'; // Tendang ke Beranda Publik
      }
      return null; // Lanjutkan perjalanan
    },

    routes: [
      // ================= CANGKANG PUBLIK =================
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) => PublicLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(),
          ),
        ],
      ),

      // ================= LOGIN RAHASIA =================
      GoRoute(
          path: '/login-rahasia',
          builder: (context, state) => const LoginScreen(),
      ),

      // ================= CANGKANG ADMIN =================
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
