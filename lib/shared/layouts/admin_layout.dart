import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../features/auth/providers/auth_provider.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child; // Pengganti <Outlet />

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    Future<void> logout() async {
      await ref.read(authProvider.notifier).logout();
      if (!context.mounted) return;
      context.go('/');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        backgroundColor: const Color(0xFF123524),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF123524)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(AppAssets.logoDesa, width: 48, height: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Menu Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kelola konten dan statistik desa',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _AdminMenuTile(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              selected: location == '/admin',
              onTap: () => context.go('/admin'),
            ),
            _AdminMenuTile(
              icon: Icons.bar_chart_rounded,
              title: 'Kelola IDM',
              selected: location == '/admin/idm',
              onTap: () => context.go('/admin/idm'),
            ),
            _AdminMenuTile(
              icon: Icons.article_rounded,
              title: 'Kelola Berita',
              selected: location == '/admin/berita',
              onTap: () => context.go('/admin/berita'),
            ),
            _AdminMenuTile(
              icon: Icons.folder_copy_rounded,
              title: 'Kelola PPID',
              selected: location == '/admin/ppid',
              onTap: () => context.go('/admin/ppid'),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: child, // Konten admin akan masuk ke sini
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF123524) : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? const Color(0xFF123524) : null,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
