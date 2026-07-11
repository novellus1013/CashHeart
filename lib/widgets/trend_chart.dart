import 'package:flutter/material.dart';

/// [TrendChart] 입력 — 월 1개 포인트(라벨 + 준/받은 마음 합계).
class TrendChartPoint {
  final String label;
  final int given;
  final int received;

  const TrendChartPoint({
    required this.label,
    required this.given,
    required this.received,
  });
}

/// design_handoff `TrendChart` 이식 — 월별 준/받은 마음 dual line.
/// Report의 기존 막대 차트를 대체한다.
class TrendChart extends StatelessWidget {
  final List<TrendChartPoint> months;
  final Color receivedColor;
  final Color givenColor;
  final Color gridColor;
  final Color labelColor;
  final double height;

  const TrendChart({
    super.key,
    required this.months,
    required this.receivedColor,
    required this.givenColor,
    required this.gridColor,
    this.labelColor = const Color(0xFF9E9E9E),
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(
              months: months,
              receivedColor: receivedColor,
              givenColor: givenColor,
              gridColor: gridColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final m in months)
              Expanded(
                child: Center(
                  child: Text(
                    m.label,
                    style: TextStyle(fontSize: 11, color: labelColor),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<TrendChartPoint> months;
  final Color receivedColor;
  final Color givenColor;
  final Color gridColor;

  _TrendChartPainter({
    required this.months,
    required this.receivedColor,
    required this.givenColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padX = 10.0;
    const padY = 16.0;
    final w = size.width;
    final h = size.height;

    final maxV = months
        .expand((m) => [m.received.toDouble(), m.given.toDouble()])
        .fold<double>(1, (a, b) => a > b ? a : b);

    double x(int i) =>
        padX +
        (i / (months.length - 1).clamp(1, double.maxFinite.toInt())) *
            (w - padX * 2);
    double y(double v) => h - padY - (v / maxV) * (h - padY * 2);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final f in [0.5, 1.0]) {
      final gy = h - padY - f * (h - padY * 2);
      canvas.drawLine(Offset(padX, gy), Offset(w - padX, gy), gridPaint);
    }

    Path buildPath(int Function(TrendChartPoint) valueOf) {
      final path = Path();
      for (var i = 0; i < months.length; i++) {
        final p = Offset(x(i), y(valueOf(months[i]).toDouble()));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path;
    }

    final receivedPaint = Paint()
      ..color = receivedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final givenPaint = Paint()
      ..color = givenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(buildPath((m) => m.received), receivedPaint);
    canvas.drawPath(buildPath((m) => m.given), givenPaint);

    for (var i = 0; i < months.length; i++) {
      canvas.drawCircle(
        Offset(x(i), y(months[i].received.toDouble())),
        2.6,
        Paint()..color = receivedColor,
      );
      canvas.drawCircle(
        Offset(x(i), y(months[i].given.toDouble())),
        2.6,
        Paint()..color = givenColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.months != months;
  }
}
