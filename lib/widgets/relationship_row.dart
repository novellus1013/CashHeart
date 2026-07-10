import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';

/// 홈 화면 지인 목록 행. design_handoff의 person row(카드) 재현.
/// 방향은 화살표가 아니라 하단 mini balance bar의 비율로만 전달한다.
class RelationshipRow extends StatelessWidget {
  final String name;
  final String categoryLabel;
  final Color categoryColor;
  final String metaText;
  final String netAmountText;
  final double tilt;
  final VoidCallback? onTap;

  const RelationshipRow({
    super.key,
    required this.name,
    required this.categoryLabel,
    required this.categoryColor,
    required this.metaText,
    required this.netAmountText,
    required this.tilt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

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
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: Sizes.size16,
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
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(Sizes.size10),
                        ),
                        child: Text(
                          categoryLabel,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: Sizes.size12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  netAmountText,
                  style: AppTextStyles.amountSmall.copyWith(
                    color: colors.text,
                  ),
                ),
              ],
            ),
            Gaps.v4,
            Text(
              metaText,
              style: AppTextStyles.caption.copyWith(color: colors.text3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Gaps.v8,
            BalanceVisualization(tilt: tilt, compact: true),
          ],
        ),
      ),
    );
  }
}
