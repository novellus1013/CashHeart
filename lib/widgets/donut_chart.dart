import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutSlice {
  final double value;
  final Color color;

  const DonutSlice({required this.value, required this.color});
}

/// design_handoff `Donut` 이식 — 카테고리별 분포 도넛.
class DonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final double size;
  final double thickness;

  /// 슬라이스가 채우지 않은 트랙 배경. 기본값은 호출부에서
  /// `Theme.of(context).extension<AppColors>()!.borderSoft`를 넘기는 것을 권장.
  final Color trackColor;

  const DonutChart({
    super.key,
    required this.slices,
    this.size = 156,
    this.thickness = 26,
    this.trackColor = const Color(0x14000000),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          slices: slices,
          thickness: thickness,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final double thickness;
  final Color trackColor;

  _DonutPainter({
    required this.slices,
    required this.thickness,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.thickness != thickness;
  }
}
