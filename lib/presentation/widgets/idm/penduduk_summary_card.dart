// lib/presentation/widgets/idm/penduduk_summary_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';
import 'package:intl/intl.dart';

class PendudukSummaryCard extends StatelessWidget {
  final PendudukStatsModel stats;
  const PendudukSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'id_ID');

    return Column(
      children: [
        // Hero total penduduk
        Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Penduduk',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                fmt.format(stats.totalPenduduk),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _GenderChip(
                    label: 'Laki-laki',
                    value: fmt.format(stats.lakiLaki),
                    icon: Icons.male_rounded,
                    color: const Color(0xFF42A5F5),
                  ),
                  const SizedBox(width: 8),
                  _GenderChip(
                    label: 'Perempuan',
                    value: fmt.format(stats.perempuan),
                    icon: Icons.female_rounded,
                    color: const Color(0xFFEC407A),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid statistik
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              label: 'Jumlah Dusun',
              value: fmt.format(stats.kepalaKeluarga),
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF7B1FA2),
            ),
            _StatCard(
              label: 'Data Kemiskinan',
              value: stats.pendudukMiskin == 0
                  ? '-'
                  : fmt.format(stats.pendudukMiskin),
              icon: Icons.volunteer_activism_rounded,
              color: const Color(0xFFE65100),
            ),
            _StatCard(
              label: 'Rasio L/P',
              value: '${stats.rasioJenisKelamin.toStringAsFixed(1)}%',
              icon: Icons.balance_rounded,
              color: const Color(0xFF0277BD),
            ),
            _StatCard(
              label: 'Rata-rata Dusun',
              value: stats.kepalaKeluarga == 0
                  ? '-'
                  : '${(stats.totalPenduduk / stats.kepalaKeluarga).toStringAsFixed(1)} jiwa',
              icon: Icons.people_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _GenderChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
