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

  /// Detail 변형: 균형 상태 pill(우측 상단, `toneLabel` 카피는 호출자가 넘김).
  final Widget? statePill;

  /// Detail 변형: 관찰자 톤 메시지 인용구(`toneMessage` 카피는 호출자가 넘김).
  final String? quoteMessage;

  /// Detail 변형: hero 카드 안에 이어 붙일 콘텐츠(StreamChart 등).
  final Widget? extra;

  /// 순잔액 텍스트 스타일. 기본값은 Home용 [AppTextStyles.heroAmount](38px).
  /// Person Detail은 [AppTextStyles.detailAmount](30px)를 넘긴다.
  final TextStyle amountStyle;

  const HeroCard({
    super.key,
    required this.label,
    required this.netAmount,
    required this.givenAmount,
    required this.receivedAmount,
    this.trailing,
    this.statePill,
    this.quoteMessage,
    this.extra,
    this.amountStyle = AppTextStyles.heroAmount,
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
        gradient: colors.cardGrad,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        // 2026-07-11 사용자 검수: 카드 윤곽이 흐릿해 보여 테두리 추가.
        border: Border.all(color: colors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: colors.text2),
                ),
              ),
              if (statePill != null) statePill!,
              if (trailing != null) trailing!,
            ],
          ),
          Gaps.v10,
          Text(
            MoneyFormatter.formatAbbreviated(netAmount),
            style: amountStyle.copyWith(color: netColor),
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
          if (extra != null) ...[Gaps.v12, extra!],
          if (quoteMessage != null) ...[
            Gaps.v16,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.size14,
                vertical: Sizes.size12,
              ),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(Sizes.size10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: Sizes.size18,
                    color: colors.text3,
                  ),
                  Gaps.h8,
                  Expanded(
                    child: Text(
                      quoteMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.text,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
