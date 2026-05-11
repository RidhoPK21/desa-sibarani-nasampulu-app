// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- PROVIDERS ---
import '../../features/auth/providers/auth_provider.dart';

// --- LAYOUTS ---
import '../../shared/layouts/public_layout.dart';
import '../../shared/layouts/admin_layout.dart';

// --- SCREENS ---
import '../../features/public/beranda/screens/beranda_screen.dart';
import '../../features/public/kegiatan/screens/kegiatan_screen.dart';
import '../../features/public/idm/screens/idm_screen.dart';
import '../../features/public/apbdes/presentation/screens/apbdes_list_screen.dart';
import '../../features/public/apbdes/presentation/screens/apbdes_detail_screen.dart';
import '../../features/public/berita/screens/berita_screen.dart';
import '../../features/public/berita/screens/berita_detail_screen.dart';
import '../../features/public/profil/screens/profil_screen.dart';
import '../../features/public/infografis/screens/infografis_publik_screen.dart';
// Keys untuk memisahkan tumpukan navigasi agar tidak saling tumpang tindih
final rootNavigatorKey = GlobalKey<NavigatorState>();
final publicShellKey = GlobalKey<NavigatorState>();
final adminShellKey = GlobalKey<NavigatorState>();

// Provider Router Utama
final routerProvider = Provider<GoRouter>((ref) {
  // Pantau status login (true = login, false = belum)
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // 🔥 SATPAM ROUTER (Redirect Guard)
    redirect: (context, state) {
      final isGoingToAdmin = state.uri.toString().startsWith('/admin');

      // Jika mencoba masuk ke area /admin tapi belum login, tendang ke Beranda
      if (isGoingToAdmin && !authState) {
        return '/';
      }
      return null; // Lanjutkan perjalanan jika aman
    },

    routes: [
      // ================= 1. AREA PUBLIK (WARGA) =================
      ShellRoute(
        navigatorKey: publicShellKey,
        builder: (context, state, child) {
          // 🔥 PERBAIKAN: Ambil URL saat ini dan lempar ke PublicLayout
          // agar Navbar tahu menu mana yang sedang aktif
          final currentLocation = state.uri.toString();
          return PublicLayout(location: currentLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BerandaScreen(),
          ),
          GoRoute(
            path: '/idm',
            builder: (context, state) => const IdmScreen(),
          ),


          GoRoute(
            path: '/profil',
            builder: (context, state) => const ProfilScreen(),
          ),
          // ✅ RUTE: Layar Infografis Publik
          GoRoute(
            path: '/infografis',
            builder: (context, state) => const InfografisPublikScreen(),
          ),
          GoRoute(
            path: '/kegiatan',
            builder: (context, state) => const KegiatanScreen(),
          ),
          GoRoute(
            path: '/dokumentasi',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Dokumentasi (Segera Hadir)'))),
          ),
          GoRoute(
            path: '/berita',
            builder: (context, state) => const BeritaScreen(),
          ),
          GoRoute(
            path: '/berita/:id',
            builder: (context, state) {
              final beritaId = state.pathParameters['id']!;
              return BeritaDetailScreen(id: beritaId);
            },
          ),
          GoRoute(
            path: '/apb-desa',
            builder: (context, state) => const ApbdesListScreen(),
          ),

          // ✅ RUTE 2: Layar Detail APBDes (Menerima parameter ID dari ApbdesCard)
          GoRoute(
            path: '/apb-desa/:id',
            builder: (context, state) {
              // Menangkap ID yang dilempar oleh context.push('/apbdes/123')
              final apbdesId = state.pathParameters['id']!;
              return ApbdesDetailScreen(id: apbdesId);
            },
          ),
          GoRoute(
            path: '/galeri',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Galeri (Segera Hadir)'))),
          ),
        ],
      ),

      // ================= 2. PINTU RAHASIA (SIMULASI LOGIN) =================
      GoRoute(
        path: '/login-rahasia',
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pintu Rahasia Admin')),
              body: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.key),
                  label: const Text('Simulasi Login Sukses'),
                  onPressed: () async {
                    // 1. Panggil fungsi login di brankas Riverpod (ubah state jadi true)
                    await ref.read(authProvider.notifier).login('token_palsu_123');

                    // 2. Langsung pindahkan ke dashboard admin
                    if (context.mounted) {
                      context.go('/admin');
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),

      // ================= 3. AREA ADMIN (PERANGKAT DESA) =================
      ShellRoute(
        navigatorKey: adminShellKey,
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard, size: 80, color: Color(0xFF4A9F6A)),
                    SizedBox(height: 20),
                    Text(
                        'Selamat Datang di Dashboard Admin!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ),
          ),
          // TODO: Tim Admin menambahkan rute lain di sini (misal: /admin/berita, /admin/idm)
        ],
      ),
    ],
  );
});