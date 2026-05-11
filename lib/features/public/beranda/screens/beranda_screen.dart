import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String? _statusKoneksi;
  bool _isLoading = false;

  void _testKoneksiBackend() async {
    setState(() {
      _isLoading = true;
      _statusKoneksi = null;
    });

    try {
      final response = await api.get('/info/berita');
      final responseText = response.data.toString();
      final displayData = responseText.length > 100
          ? '${responseText.substring(0, 100)}...'
          : responseText;

      setState(() {
        _statusKoneksi =
            '✅ Berhasil terhubung!\n\nStatus: ${response.statusCode}\nData: $displayData';
      });
    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 500) {
          _statusKoneksi =
              '❌ Server backend bermasalah (Error 500). Cek log Laravel!';
        } else {
          _statusKoneksi = '❌ Gagal terhubung!\n\nError: ${e.message}';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Hero Banner ---
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: const DecorationImage(
              image: AssetImage(AppAssets.monument),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.68),
                  Colors.black.withValues(alpha: 0.12),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(AppAssets.logoDesa, width: 54, height: 54),
                const SizedBox(height: 10),
                const Text(
                  'Desa Sibarani Nasampulu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Portal informasi dan layanan desa',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // --- Menu Grid ---
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            _MenuCard(
              title: 'IDM Desa',
              subtitle: 'Statistik pembangunan',
              icon: Icons.bar_chart_rounded,
              onTap: () => context.go('/idm'),
            ),
            _MenuCard(
              title: 'PPID',
              subtitle: 'Dokumen publik',
              icon: Icons.folder_copy_rounded,
              onTap: () => context.go('/ppid'),
            ),
            _MenuCard(
              title: 'Galeri',
              subtitle: 'Dokumentasi kegiatan',
              icon: Icons.photo_library_rounded,
              onTap: () => context.go('/galeri'),
            ),
            _MenuCard(
              title: 'Admin',
              subtitle: 'Kelola konten',
              icon: Icons.admin_panel_settings_rounded,
              onTap: () => context.go('/admin'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- Panel Uji Koneksi Backend ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Uji Koneksi Backend',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              if (_statusKoneksi != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusKoneksi!.startsWith('✅')
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusKoneksi!,
                    style: TextStyle(
                      fontSize: 13,
                      color: _statusKoneksi!.startsWith('✅')
                          ? const Color(0xFF065F46)
                          : const Color(0xFF9F1239),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _testKoneksiBackend,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.network_ping, size: 18),
                      label: Text(_isLoading ? 'Menghubungi...' : 'Uji API'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/login-rahasia'),
                      icon: const Icon(Icons.sensor_door, size: 18),
                      label: const Text('Pintu Rahasia'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}