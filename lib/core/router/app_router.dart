import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- PROVIDERS ---
import '../../features/auth/providers/auth_provider.dart';

// --- LAYOUTS ---
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';

// --- SCREENS PUBLIK ---
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../features/public/idm/screens/idm_screen.dart';
import '../../features/public/kegiatan/screens/kegiatan_screen.dart';
import '../../features/public/apbdes/presentation/screens/apbdes_list_screen.dart';
import '../../features/public/apbdes/presentation/screens/apbdes_detail_screen.dart';
import '../../features/public/berita/screens/berita_screen.dart';
import '../../features/public/berita/screens/berita_detail_screen.dart';
import '../../features/public/profil/screens/profil_screen.dart';
import '../../features/public/infografis/screens/infografis_publik_screen.dart';
import '../../features/public/galeri/screens/galeri_screen.dart';
import '../../features/public/ppid/screens/ppid_screen.dart';

// --- SCREENS ADMIN ---
import '../../features/admin/dashboard/screens/admin_dashboard_screen.dart'; //  Import Dashboard Asli
import '../../features/admin/ppid/screens/admin_ppid_screen.dart';
import '../../features/admin/kegiatan/screens/admin_kegiatan_screen.dart';
import '../../features/admin/infografis/screens/admin_infografis_screen.dart';
import '../../features/admin/idm/screens/admin_idm_screen.dart';
import '../../features/admin/apbdes/screens/admin_apbdes_screen.dart';
import '../../features/admin/berita/screens/admin_berita_screen.dart';

// --- AUTH ---
import '../../features/auth/pages/login_screen.dart';

// Keys untuk memisahkan tumpukan navigasi agar tidak saling tumpang tindih
final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

// Provider Router Utama
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    //  SATPAM ROUTER (Redirect Guard)
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      final isGoingToAdmin = state.uri.toString().startsWith('/admin');
      final isGoingToLogin = state.uri.toString() == '/login';

      // Skenario A: Belum login tapi mau masuk /admin -> Tendang ke /login
      if (isGoingToAdmin && !authState) {
        return '/login';
      }

      // Skenario B: Sudah login tapi mau buka halaman /login -> Langsung bawa ke /admin
      if (isGoingToLogin && authState) {
        return '/admin';
      }

      return null; // Lanjutkan perjalanan jika aman
    },

    routes: [
      // ==========================================
      // 1. AREA PUBLIK (WARGA)
      // Dibungkus dengan PublicLayout (Navbar Warga)
      // ==========================================
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) {
          final currentLocation = state.uri.toString();
          return PublicLayout(location: currentLocation, child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const BerandaScreen()),
          GoRoute(path: '/idm', builder: (context, state) => const IdmScreen()),
          GoRoute(path: '/kegiatan', builder: (context, state) => const KegiatanScreen()),
          GoRoute(path: '/apb-desa', builder: (context, state) => const ApbdesListScreen()),
          GoRoute(
            path: '/apb-desa/:id',
            builder: (context, state) {
              final apbdesId = state.pathParameters['id']!;
              return ApbdesDetailScreen(id: apbdesId);
            },
          ),
          GoRoute(path: '/berita', builder: (context, state) => const BeritaScreen()),
          GoRoute(
            path: '/berita/:id',
            builder: (context, state) {
              final beritaId = state.pathParameters['id']!;
              return BeritaDetailScreen(id: beritaId);
            },
          ),
          GoRoute(path: '/profil', builder: (context, state) => const ProfilScreen()),
          GoRoute(path: '/infografis', builder: (context, state) => const InfografisPublikScreen()),
          GoRoute(path: '/galeri', builder: (context, state) => const GaleriScreen()),
          GoRoute(path: '/dokumentasi', builder: (context, state) => const PpidPublicScreen()),
        ],
      ),

      // ==========================================
      // 2. PINTU MASUK ADMIN (LOGIN)
      // ==========================================
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ==========================================
      // 3. AREA ADMIN (PERANGKAT DESA)
      // Dibungkus dengan AdminLayout (Sidebar Admin)
      // ==========================================
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) {
          return AdminLayout(child: child);
        },
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/infografis', builder: (context, state) => const AdminInfografisScreen()),
          GoRoute(path: '/admin/kegiatan', builder: (context, state) => const AdminKegiatanScreen()),
          GoRoute(path: '/admin/ppid', builder: (context, state) => const AdminPpidScreen()),
          GoRoute(path: '/admin/idm', builder: (context, state) => const AdminIdmScreen()),
          GoRoute(path: '/admin/berita', builder: (context, state) => const AdminBeritaScreen()),
          GoRoute(path: '/admin/apbdes', builder: (context, state) => const AdminApbdesScreen()),
          // Rute /admin/profil dan /admin/banner SUDAH DIMUSNAHKAN!
        ],
      ),
    ],
  );
});