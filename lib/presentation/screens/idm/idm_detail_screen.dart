// lib/presentation/screens/idm/idm_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';

class IdmDetailScreen extends StatelessWidget {
  final IdmModel idm;
  const IdmDetailScreen({super.key, required this.idm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail IDM ${idm.tahun}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Indikator Ketahanan Sosial (IKS)',
              Icons.people_rounded,
              const Color(0xFF1565C0),
            ),
            const SizedBox(height: 12),
            ..._buildIksIndicators(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Indikator Ketahanan Ekonomi (IKE)',
              Icons.account_balance_rounded,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            ..._buildIkeIndicators(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Indikator Ketahanan Lingkungan (IKL)',
              Icons.eco_rounded,
              const Color(0xFF00695C),
            ),
            const SizedBox(height: 12),
            ..._buildIklIndicators(),
            const SizedBox(height: 20),
            _buildStatusLegend(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skor IDM',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  idm.statusIdm,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                idm.skorIdm.toStringAsFixed(4),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'dari 1.0000',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: idm.skorIdm,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniScore(
                label: 'IKS',
                nilai: idm.skorIks,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              _MiniScore(
                label: 'IKE',
                nilai: idm.skorIke,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              _MiniScore(
                label: 'IKL',
                nilai: idm.skorIkl,
                color: const Color(0xFF00695C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIksIndicators() => [
    _IndicatorItem(
      nama: 'Pelayanan Kesehatan',
      nilai: 0.85,
      icon: Icons.local_hospital_rounded,
    ),
    _IndicatorItem(
      nama: 'Kondisi Kesehatan Masyarakat',
      nilai: 0.78,
      icon: Icons.health_and_safety_rounded,
    ),
    _IndicatorItem(
      nama: 'Akses Pendidikan',
      nilai: 0.82,
      icon: Icons.school_rounded,
    ),
    _IndicatorItem(
      nama: 'Modal Sosial',
      nilai: 0.89,
      icon: Icons.group_rounded,
    ),
    _IndicatorItem(nama: 'Permukiman', nilai: 0.76, icon: Icons.home_rounded),
  ];

  List<Widget> _buildIkeIndicators() => [
    _IndicatorItem(
      nama: 'Keragaman Produksi Masyarakat',
      nilai: 0.71,
      icon: Icons.agriculture_rounded,
    ),
    _IndicatorItem(
      nama: 'Pusat Perdagangan',
      nilai: 0.74,
      icon: Icons.store_rounded,
    ),
    _IndicatorItem(
      nama: 'Akses Distribusi/Logistik',
      nilai: 0.69,
      icon: Icons.local_shipping_rounded,
    ),
    _IndicatorItem(
      nama: 'Akses Perbankan/Kredit',
      nilai: 0.72,
      icon: Icons.account_balance_wallet_rounded,
    ),
    _IndicatorItem(
      nama: 'Lembaga Ekonomi',
      nilai: 0.80,
      icon: Icons.business_rounded,
    ),
  ];

  List<Widget> _buildIklIndicators() => [
    _IndicatorItem(
      nama: 'Kualitas Lingkungan',
      nilai: 0.82,
      icon: Icons.park_rounded,
    ),
    _IndicatorItem(
      nama: 'Potensi Rawan Bencana',
      nilai: 0.75,
      icon: Icons.warning_amber_rounded,
    ),
    _IndicatorItem(
      nama: 'Tanggap Bencana',
      nilai: 0.78,
      icon: Icons.emergency_rounded,
    ),
  ];

  Widget _buildStatusLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Klasifikasi Status IDM',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _LegendItem(
            color: AppColors.idmMandiri,
            status: 'Mandiri',
            range: 'IDM > 0,8155',
          ),
          _LegendItem(
            color: AppColors.idmMaju,
            status: 'Maju',
            range: '0,7072 < IDM â‰¤ 0,8155',
          ),
          _LegendItem(
            color: AppColors.idmBerkembang,
            status: 'Berkembang',
            range: '0,5989 < IDM â‰¤ 0,7072',
          ),
          _LegendItem(
            color: AppColors.idmTertinggal,
            status: 'Tertinggal',
            range: '0,4907 < IDM â‰¤ 0,5989',
          ),
          _LegendItem(
            color: AppColors.idmSangat,
            status: 'Sangat Tertinggal',
            range: 'IDM â‰¤ 0,4907',
          ),
        ],
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final double nilai;
  final Color color;
  const _MiniScore({
    required this.label,
    required this.nilai,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              nilai.toStringAsFixed(3),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorItem extends StatelessWidget {
  final String nama;
  final double nilai;
  final IconData icon;
  const _IndicatorItem({
    required this.nama,
    required this.nilai,
    required this.icon,
  });

  Color get _color {
    if (nilai >= 0.8) return AppColors.idmMaju;
    if (nilai >= 0.7) return AppColors.idmBerkembang;
    if (nilai >= 0.6) return AppColors.idmTertinggal;
    return AppColors.idmSangat;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            nilai.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: nilai,
                backgroundColor: _color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(_color),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String status;
  final String range;
  const _LegendItem({
    required this.color,
    required this.status,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Text(
            range,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
