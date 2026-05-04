import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/logo-toba.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Menu Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Sibarani Nasampulu',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _AdminMenuTile(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              selected: location == '/admin' || location.startsWith('/admin/infografis'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                context.go('/admin');
              },
            ),
            _AdminMenuTile(
              icon: Icons.bar_chart_rounded,
              title: 'Kelola IDM',
              selected: location == '/admin/idm',
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                context.go('/admin/idm');
              },
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
