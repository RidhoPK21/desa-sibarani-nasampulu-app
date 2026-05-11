import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../features/auth/providers/auth_provider.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;

  const AdminLayout({
    super.key,
    required this.child,
  });

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) return;

    context.go('/');
  }

  void _showLogoutModal(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade500,
                  size: 36,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Yakin Ingin Keluar?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Anda akan mengakhiri sesi admin dan kembali ke halaman publik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);

                        await _logout(context, ref);
                      },
                      child: const Text(
                        'Ya, Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    const primaryColor = Color(0xFF123524);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset(
              AppAssets.logoDesa,
              height: 30,
              width: 30,
            ),

            const SizedBox(width: 12),

            const Text(
              'Panel Admin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.logoDesa,
                    width: 40,
                    height: 40,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Desa Sibarani',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                children: [
                  _buildMenu(
                    context,
                    title: 'Dashboard',
                    path: '/admin',
                    icon: Icons.dashboard_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'Infografis',
                    path: '/admin/infografis',
                    icon: Icons.pie_chart_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'Kegiatan Desa',
                    path: '/admin/kegiatan',
                    icon: Icons.local_activity_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'Berita',
                    path: '/admin/berita',
                    icon: Icons.article_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'APBDes',
                    path: '/admin/apbdes',
                    icon: Icons.account_balance_wallet_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'PPID',
                    path: '/admin/ppid',
                    icon: Icons.folder_copy_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),

                  _buildMenu(
                    context,
                    title: 'IDM',
                    path: '/admin/idm',
                    icon: Icons.bar_chart_rounded,
                    currentPath: currentPath,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin Desa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'admin@sibarani.desa.id',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Logout',
                    icon: Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () {
                      _showLogoutModal(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: child,
    );
  }

  Widget _buildMenu(
    BuildContext context, {
    required String title,
    required String path,
    required IconData icon,
    required String currentPath,
    required Color primaryColor,
  }) {
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isActive
            ? primaryColor
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isActive
              ? Colors.white
              : Colors.grey.shade500,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.w600,
            color: isActive
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
        onTap: () {
          Navigator.pop(context);

          context.go(path);
        },
      ),
    );
  }
}