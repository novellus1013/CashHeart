import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `StreamChart` 이식 — 받은 마음(위)/준 마음(아래) 누적 흐름을
/// 0 기준선(점선) 위아래 영역으로 그린다. 화살표 없이 형태로만 방향을 전달한다.
class StreamChart extends StatelessWidget {
  final List<Gift> gifts;
  final double height;

  const StreamChart({super.key, required this.gifts, this.height = 130});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (gifts.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '흐름을 그리려면 기록이 더 필요해요',
            style: AppTextStyles.caption.copyWith(color: colors.text3),
          ),
        ),
      );
    }

    final sorted = [...gifts]..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StreamChartPainter(
          sorted: sorted,
          receivedColor: colors.received,
          givenColor: colors.given,
          zeroLineColor: colors.text,
        ),
      ),
    );
  }
}

class _StreamChartPainter extends CustomPainter {
  final List<Gift> sorted;
  final Color receivedColor;
  final Color givenColor;
  final Color zeroLineColor;

  _StreamChartPainter({
    required this.sorted,
    required this.receivedColor,
    required this.givenColor,
    required this.zeroLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padX = 8.0;
    final mid = size.height / 2;
    final w = size.width;

    final t0 = sorted.first.date;
    final t1 = sorted.last.date;
    final span = (t1 - t0).clamp(1, double.maxFinite.toInt()).toDouble();

    var cumReceived = 0;
    var cumGiven = 0;
    final receivedPts = <Offset>[];
    final givenPts = <Offset>[];

    for (final gift in sorted) {
      if (gift.direction == GiftDirection.received) {
        cumReceived += gift.amount;
      } else {
        cumGiven += gift.amount;
      }
      final x = padX + ((gift.date - t0) / span) * (w - padX * 2);
      receivedPts.add(Offset(x, cumReceived.toDouble()));
      givenPts.add(Offset(x, cumGiven.toDouble()));
    }

    final maxV = [
      cumReceived.toDouble(),
      cumGiven.toDouble(),
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    double yUp(double v) => mid - (v / maxV) * (mid - 10);
    double yDown(double v) => mid + (v / maxV) * (mid - 10);

    Path linePath(List<Offset> pts, double Function(double) yOf) {
      final path = Path();
      for (var i = 0; i < pts.length; i++) {
        final p = Offset(pts[i].dx, yOf(pts[i].dy));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path;
    }

    Path areaPath(List<Offset> pts, double Function(double) yOf) {
      final path = Path()..moveTo(padX, mid);
      for (final p in pts) {
        path.lineTo(p.dx, yOf(p.dy));
      }
      path.lineTo(pts.last.dx, mid);
      path.close();
      return path;
    }

    canvas.drawPath(
      areaPath(receivedPts, yUp),
      Paint()..color = receivedColor.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      areaPath(givenPts, yDown),
      Paint()..color = givenColor.withValues(alpha: 0.16),
    );

    canvas.drawPath(
      linePath(receivedPts, yUp),
      Paint()
        ..color = receivedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      linePath(givenPts, yDown),
      Paint()
        ..color = givenColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    _drawDashedLine(
      canvas,
      Offset(padX, mid),
      Offset(w - padX, mid),
      zeroLineColor.withValues(alpha: 0.5),
    );

    // 그래프가 무엇을 나타내는지 바로 알 수 있도록 위/아래 영역에 라벨을 붙인다
    // (2026-07-11 검수: "그래프가 뭘 의미하는지 잘 안 드러남" 피드백 반영).
    _drawLabel(canvas, '받은 마음', Offset(padX, 4), receivedColor);
    _drawLabel(canvas, '준 마음', Offset(padX, size.height - 16), givenColor);
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashWidth = 2.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final totalLength = (end - start).distance;
    final dashCount = (totalLength / (dashWidth + dashSpace)).floor();
    final direction = (end - start) / totalLength;

    for (var i = 0; i < dashCount; i++) {
      final segmentStart = start + direction * (i * (dashWidth + dashSpace));
      final segmentEnd = segmentStart + direction * dashWidth;
      canvas.drawLine(segmentStart, segmentEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StreamChartPainter oldDelegate) {
    return oldDelegate.sorted != sorted ||
        oldDelegate.receivedColor != receivedColor ||
        oldDelegate.givenColor != givenColor;
  }
}
