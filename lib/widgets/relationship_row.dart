import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';

/// 홈 화면 지인 목록 행. design_handoff `PersonRow` 이식.
/// 방향은 화살표가 아니라 하단 mini balance bar의 비율로만 전달한다.
class RelationshipRow extends StatelessWidget {
  final String name;
  final int tintSeed;
  final String categoryLabel;
  final String metaText;
  final String netAmountText;
  final Color netAmountColor;

  /// 기록이 없는 person(빈 상태)에는 하단 mini bar를 표시하지 않는다.
  final bool hasRecords;
  final double tilt;

  /// 상태 라벨(`toneLabel` 카피, 예: "균형"/"기울어짐"/"한쪽으로 흐름") — 선택.
  final String? stateLabel;
  final VoidCallback? onTap;

  const RelationshipRow({
    super.key,
    required this.name,
    required this.tintSeed,
    required this.categoryLabel,
    required this.metaText,
    required this.netAmountText,
    required this.netAmountColor,
    required this.hasRecords,
    required this.tilt,
    this.stateLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = BalanceState.fromTilt(tilt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Sizes.size16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Avatar(name: name, tintSeed: tintSeed, size: 50),
                Gaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: AppTextStyles.rowName.copyWith(
                                color: colors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Gaps.h8,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Sizes.size8,
                              vertical: Sizes.size2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.bg,
                              borderRadius: BorderRadius.circular(Sizes.size10),
                            ),
                            child: Text(
                              categoryLabel,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: Sizes.size12,
                                fontWeight: FontWeight.w600,
                                color: colors.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gaps.v4,
                      Text(
                        metaText,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.text3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Gaps.h8,
                Text(
                  netAmountText,
                  style: AppTextStyles.amountSmall.copyWith(
                    color: netAmountColor,
                  ),
                ),
                Icon(Icons.chevron_right, size: Sizes.size20, color: colors.text3),
              ],
            ),
            if (hasRecords) ...[
              Gaps.v12,
              Padding(
                padding: EdgeInsets.only(left: Sizes.size64),
                child: Row(
                  children: [
                    SizedBox(
                      width: Sizes.size56,
                      child: BalanceVisualization(tilt: tilt, compact: true),
                    ),
                    if (stateLabel != null) ...[
                      Gaps.h10,
                      Text(
                        stateLabel!,
                        style: AppTextStyles.caption.copyWith(
                          color: state.color(colors),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
