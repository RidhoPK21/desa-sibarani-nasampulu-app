// lib/presentation/widgets/idm/idm_trend_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';

class IdmTrendChart extends StatefulWidget {
  final List<IdmModel> history;
  const IdmTrendChart({super.key, required this.history});

  @override
  State<IdmTrendChart> createState() => _IdmTrendChartState();
}

class _IdmTrendChartState extends State<IdmTrendChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Center(
          child: Text(
            'Riwayat IDM belum tersedia.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFF0F0F0), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= widget.history.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${widget.history[idx].tahun}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchCallback: (event, response) {
              setState(() {
                _touchedIndex = response?.lineBarSpots?.first.spotIndex ?? -1;
              });
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final idm = widget.history[s.spotIndex];
                return LineTooltipItem(
                  '${idm.tahun}\n${idm.skorIdm.toStringAsFixed(4)}\n${idm.statusIdm}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          minY: 0.6,
          maxY: 0.9,
          lineBarsData: [
            // IDM Line
            LineChartBarData(
              spots: widget.history
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.skorIdm))
                  .toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: _touchedIndex == index ? 6 : 4,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // IKS Line
            LineChartBarData(
              spots: widget.history
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.skorIks))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF1565C0).withValues(alpha: 0.6),
              barWidth: 1.5,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // IKE Line
            LineChartBarData(
              spots: widget.history
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.skorIke))
                  .toList(),
              isCurved: true,
              color: AppColors.accent.withValues(alpha: 0.7),
              barWidth: 1.5,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
