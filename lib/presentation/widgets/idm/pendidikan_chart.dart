import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';

class PendidikanChart extends StatefulWidget {
  final List<PendidikanModel> data;

  const PendidikanChart({super.key, required this.data});

  @override
  State<PendidikanChart> createState() => _PendidikanChartState();
}

class _PendidikanChartState extends State<PendidikanChart> {
  int _touchedIdx = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.fold<int>(0, (sum, item) => sum + item.jumlah);

    if (widget.data.isEmpty || total == 0) {
      return const _EmptyChart(message: 'Data pendidikan belum tersedia.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIdx =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
                sections: widget.data.asMap().entries.map((entry) {
                  final isTouched = entry.key == _touchedIdx;
                  final color = AppColors
                      .chartColors[entry.key % AppColors.chartColors.length];
                  return PieChartSectionData(
                    value: entry.value.jumlah.toDouble(),
                    color: color,
                    radius: isTouched ? 40 : 32,
                    title: '',
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.asMap().entries.map((entry) {
                final color = AppColors
                    .chartColors[entry.key % AppColors.chartColors.length];
                final item = entry.value;
                final percent = total == 0 ? 0 : item.jumlah / total * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.tingkat,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}
