import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child; // Pengganti <Outlet />

  const AdminLayout({super.key, required this.child});

  // Fungsi untuk memunculkan Modal Konfirmasi Logout (Pengganti state showLogoutModal)
  void _showLogoutModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Peringatan Merah
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade500, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yakin Ingin Keluar?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda akan mengakhiri sesi admin ini dan kembali ke halaman utama publik.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context), // Batal
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context); // Tutup modal dialog dulu
                      await ref.read(authProvider.notifier).logout(); // Hapus token di background

                      // Tendang user kembali ke halaman Beranda Publik
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca path URL saat ini untuk menentukan menu mana yang sedang aktif
    final currentPath = GoRouterState.of(context).uri.path;
    const primaryColor = Color(0xFF4A9F6A); // Warna hijau Tailwind dari kodemu

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // HEADER KHUSUS HP (Otomatis punya tombol Hamburger Menu bawaan Scaffold)
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5, // Shadow tipis (border-b)
        title: Row(
          children: [
            // Jika ada aset logo, uncomment ini:
            // Image.asset('assets/images/logodesa.png', height: 30),
            // const SizedBox(width: 12),
            const Text('Panel Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      // SIDEBAR (Otomatis ditangani Scaffold sebagai Drawer)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // AREA LOGO & JUDUL (Header Drawer)
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: primaryColor, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Desa Sibarani',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // AREA MENU UTAMA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                children: [
                  _buildMenu(context, title: 'Dashboard', path: '/admin', icon: Icons.home_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'Infografis', path: '/admin/infografis', icon: Icons.pie_chart_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'Kegiatan Desa', path: '/admin/kegiatan', icon: Icons.local_activity_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'Berita', path: '/admin/berita', icon: Icons.article_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'APBDes', path: '/admin/apbdes', icon: Icons.account_balance_wallet_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'PPID', path: '/admin/ppid', icon: Icons.star_rounded, currentPath: currentPath, primaryColor: primaryColor),
                  _buildMenu(context, title: 'IDM', path: '/admin/idm', icon: Icons.add_circle_rounded, currentPath: currentPath, primaryColor: primaryColor),
                ],
              ),
            ),

            // AREA PROFIL USER (Bagian Bawah)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  // Info Teks
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Admin Desa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('admin@sibarani.desa.id', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  // Tombol Logout
                  IconButton(
                    icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                    tooltip: 'Keluar dari Panel Admin',
                    onPressed: () => _showLogoutModal(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // KONTEN UTAMA (Outlet)
      body: child,
    );
  }

  // Fungsi Pembantu untuk membuat tombol menu Sidebar yang elegan
  Widget _buildMenu(
      BuildContext context, {
        required String title,
        required String path,
        required IconData icon,
        required String currentPath,
        required Color primaryColor,
      }) {
    // Mengecek apakah menu ini sedang aktif
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? primaryColor : Colors.transparent,
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade500,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Tutup sidebar drawer
          context.go(path);       // Pindah halaman
        },
      ),
    );
  }
}