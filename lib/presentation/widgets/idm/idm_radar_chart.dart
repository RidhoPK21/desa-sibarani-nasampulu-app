// lib/presentation/widgets/idm/idm_radar_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';

class IdmRadarChart extends StatelessWidget {
  final IdmModel idm;
  const IdmRadarChart({super.key, required this.idm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                ),
                radarBorderData: const BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
                gridBorderData: const BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return RadarChartTitle(text: 'IKS', angle: angle);
                    case 1:
                      return RadarChartTitle(text: 'IKE', angle: angle);
                    case 2:
                      return RadarChartTitle(text: 'IKL', angle: angle);
                    default:
                      return RadarChartTitle(text: '');
                  }
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withValues(alpha: 0.15),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    entryRadius: 4,
                    dataEntries: [
                      RadarEntry(value: idm.skorIks),
                      RadarEntry(value: idm.skorIke),
                      RadarEntry(value: idm.skorIkl),
                    ],
                  ),
                  RadarDataSet(
                    fillColor: Colors.transparent,
                    borderColor: Colors.grey.shade200,
                    borderWidth: 1,
                    entryRadius: 0,
                    dataEntries: const [
                      RadarEntry(value: 1.0),
                      RadarEntry(value: 1.0),
                      RadarEntry(value: 1.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendDot(
                label: 'IKS: ${idm.skorIks.toStringAsFixed(3)}',
                color: const Color(0xFF1565C0),
              ),
              _LegendDot(
                label: 'IKE: ${idm.skorIke.toStringAsFixed(3)}',
                color: AppColors.primary,
              ),
              _LegendDot(
                label: 'IKL: ${idm.skorIkl.toStringAsFixed(3)}',
                color: const Color(0xFF00695C),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
