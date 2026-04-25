// lib/presentation/widgets/idm/idm_score_card.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';

class IdmScoreCard extends StatefulWidget {
  final IdmModel idm;
  const IdmScoreCard({super.key, required this.idm});

  @override
  State<IdmScoreCard> createState() => _IdmScoreCardState();
}

class _IdmScoreCardState extends State<IdmScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.idm.statusIdm.toLowerCase()) {
      case 'mandiri':
        return AppColors.idmMandiri;
      case 'maju':
        return AppColors.idmMaju;
      case 'berkembang':
        return AppColors.idmBerkembang;
      case 'tertinggal':
        return AppColors.idmTertinggal;
      default:
        return AppColors.idmSangat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Gauge
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => CustomPaint(
                  size: const Size(100, 100),
                  painter: _GaugePainter(
                    value: _animation.value * widget.idm.skorIdm,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Score Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.idm.statusIdm.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) => Text(
                        (_animation.value * widget.idm.skorIdm).toStringAsFixed(
                          4,
                        ),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _statusColor,
                        ),
                      ),
                    ),
                    Text(
                      'Skor IDM Tahun ${widget.idm.tahun}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Target
                    Row(
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Target Mandiri: > 0.8155',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar menuju Mandiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kemajuan menuju Mandiri',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${((widget.idm.skorIdm / 0.8155) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) => LinearProgressIndicator(
                    value: (_animation.value * widget.idm.skorIdm / 0.8155)
                        .clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                    minHeight: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Custom Gauge Painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = size.width * 0.44;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Value arc with gradient effect
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value,
      false,
      paint,
    );

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: (value * 100).toStringAsFixed(0),
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 4,
      ),
    );

    // % label
    final pctPainter = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(color: AppColors.textHint, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    pctPainter.layout();
    pctPainter.paint(
      canvas,
      Offset(center.dx - pctPainter.width / 2, center.dy + 10),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
