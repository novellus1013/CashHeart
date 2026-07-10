import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';

/// 홈/상세 화면 상단 요약 카드. design_handoff의 pastel hero card.
/// 금액 자체를 강조하기보다 준/받은 마음의 비율(형태)로 관계를 보여준다 — 화살표 없음.
class HeroCard extends StatelessWidget {
  final String label;
  final int netAmount;
  final int givenAmount;
  final int receivedAmount;
  final Widget? trailing;

  const HeroCard({
    super.key,
    required this.label,
    required this.netAmount,
    required this.givenAmount,
    required this.receivedAmount,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final total = givenAmount + receivedAmount;
    final tilt = total == 0 ? 0.0 : (receivedAmount - givenAmount) / total;
    final netColor = netAmount >= 0 ? colors.received : colors.given;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size20,
        vertical: Sizes.size24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primarySoft, colors.secondarySoft],
        ),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: colors.text2),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          Gaps.v10,
          Text(
            MoneyFormatter.formatAbbreviated(netAmount),
            style: AppTextStyles.heroAmount.copyWith(color: netColor),
          ),
          Gaps.v16,
          BalanceVisualization(tilt: tilt),
          Gaps.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountLabel(
                label: '준 마음',
                amountText: MoneyFormatter.formatAbbreviated(givenAmount),
                color: colors.given,
              ),
              _AmountLabel(
                label: '받은 마음',
                amountText: MoneyFormatter.formatAbbreviated(receivedAmount),
                color: colors.received,
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final String amountText;
  final Color color;
  final bool alignEnd;

  const _AmountLabel({
    required this.label,
    required this.amountText,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
        Gaps.v4,
        Text(
          amountText,
          style: AppTextStyles.amountSmall.copyWith(color: color),
        ),
      ],
    );
  }
}
