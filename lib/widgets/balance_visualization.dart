import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:flutter/material.dart';

/// 관계의 균형/일방성을 막대 비율로만 표현한다. 화살표(↑↓→)는 절대 쓰지 않는다.
///
/// [tilt] = (받은 마음 - 준 마음) / (받은 마음 + 준 마음), 범위 -1.0 ~ 1.0.
/// 음수면 준 마음(given) 비중이, 양수면 받은 마음(received) 비중이 크다.
/// balanced/tilted/severe 상태는 막대의 준/받음 경계 지점에 겹치는 마커로 표시한다 —
/// 마커가 중앙에서 멀어질수록(=비율이 한쪽으로 쏠릴수록) 더 짙은 상태색을 띠므로
/// 비율과 상태의 관계가 위치만으로도 바로 읽힌다.
class BalanceVisualization extends StatelessWidget {
  final double tilt;

  /// true면 목록 행 등에 쓰는 작은 미니바.
  final bool compact;

  /// 상태 라벨 카피(선택). Sprint 3 카피 톤 게이트 이전에는 호출자가 넘기지 않는 것을 권장.
  final String? label;

  const BalanceVisualization({
    super.key,
    required this.tilt,
    this.compact = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final clampedTilt = tilt.clamp(-1.0, 1.0);
    final givenRatio = ((1 - clampedTilt) / 2).clamp(0.0, 1.0);
    final receivedRatio = 1 - givenRatio;
    final barHeight = compact ? 6.0 : 10.0;
    final markerSize = compact ? 12.0 : 16.0;
    final state = BalanceState.fromTilt(clampedTilt);

    final track = LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final markerCenter = trackWidth * givenRatio;

        return SizedBox(
          height: markerSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(barHeight / 2),
                child: SizedBox(
                  height: barHeight,
                  width: trackWidth,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (givenRatio * 1000).round().clamp(1, 999),
                        child: Container(color: colors.given),
                      ),
                      Expanded(
                        flex: (receivedRatio * 1000).round().clamp(1, 999),
                        child: Container(color: colors.received),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: (markerCenter - markerSize / 2).clamp(
                  0.0,
                  trackWidth - markerSize,
                ),
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    color: state.color(colors),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (label == null) return track;

    return Row(
      children: [
        Expanded(child: track),
        Gaps.h8,
        Text(
          label!,
          style: AppTextStyles.caption.copyWith(color: colors.text2),
        ),
      ],
    );
  }
}
