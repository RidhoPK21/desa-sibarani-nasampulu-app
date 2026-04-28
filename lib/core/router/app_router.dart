import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
// Note: Nanti kamu import file layout dan screen di sini
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';
<<<<<<< Updated upstream

=======
import '../../features/auth/pages/login_screen.dart';
import '../../features/admin/infografis/pages/infografis_screen.dart';
import '../../features/admin/infografis/pages/tambah_dusun_screen.dart';
>>>>>>> Stashed changes

final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    redirect: (context, state) {
      final isGoingToAdmin = state.uri.toString().startsWith('/admin');
      if (isGoingToAdmin && !authState) {
        return '/';
      }
      return null;
    },

    routes: [
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) => PublicLayout(child: child), // Harus kamu buat file UI-nya
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(), // Panggil layar uji coba kita
          ),
        ],
      ),

      GoRoute(
          path: '/login-rahasia',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Halaman Login Admin')))
      ),

      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminLayout(child: child), // Harus kamu buat file UI-nya
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const InfografisScreen(),
          ),
          GoRoute(
            path: '/admin/infografis/tambah',
            builder: (context, state) => const TambahDusunScreen(),
          ),
        ],
      ),
    ],
  );
});