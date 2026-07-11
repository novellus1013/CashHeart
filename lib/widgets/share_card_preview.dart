import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';

/// design_handoff `ShareCard` 이식 — Sprint 3는 단일 톤 프리뷰만(9 변형/이미지
/// export는 Sprint 4 소유). 배경은 관계 균형 상태에 따라 자동으로 정해진다.
class ShareCardPreview extends StatelessWidget {
  final String personName;
  final int tintSeed;
  final RelationshipStats stats;
  final String message;

  const ShareCardPreview({
    super.key,
    required this.personName,
    required this.tintSeed,
    required this.stats,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      width: 280,
      padding: EdgeInsets.all(Sizes.size24),
      decoration: BoxDecoration(
        gradient: colors.cardGrad,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(name: personName, tintSeed: tintSeed, size: 44),
              Gaps.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.text),
                    ),
                    Text(
                      stats.count > 0 ? '${stats.years}년간 ${stats.count}번의 마음' : '함께 쌓아가는 관계예요',
                      style: TextStyle(fontSize: 12, color: colors.text2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v20,
          Text(
            message,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text, height: 1.4),
          ),
          Gaps.v20,
          if (stats.count >= 2) ...[
            BalanceVisualization(tilt: stats.tilt),
            Gaps.v8,
            Text(
              balanceStateLabel(stats.state),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: stats.state.color(colors),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
