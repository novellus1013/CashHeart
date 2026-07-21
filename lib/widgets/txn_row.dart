import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// design_handoff `TxnRow` 이식 — Person Detail 거래 내역 행.
class TxnRow extends StatelessWidget {
  final Gift gift;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const TxnRow({super.key, required this.gift, this.onTap, this.onMore});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isReceived = gift.direction == GiftDirection.received;
    final accent = isReceived ? colors.received : colors.given;
    final soft = isReceived ? colors.secondarySoft : colors.primarySoft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          Sizes.size14,
          Sizes.size12,
          Sizes.size4,
          Sizes.size12,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: colors.borderSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(Sizes.size10),
              ),
              child: Icon(gift.category.icon, size: Sizes.size20, color: accent),
            ),
            Gaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        gift.categoryLabel,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                      Gaps.h6,
                      Text(
                        isReceived ? '받음' : '줌',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  if (gift.note.isNotEmpty) ...[
                    Gaps.v2,
                    Text(
                      gift.note,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        color: colors.text2,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Gaps.v2,
                  Text(
                    DateFormat('yyyy.MM.dd')
                        .format(DateTime.fromMillisecondsSinceEpoch(gift.date)),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      color: colors.text3,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isReceived ? '+' : '−'}${MoneyFormatter.formatWonShort(gift.amount)}',
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            if (onMore != null)
              IconButton(
                onPressed: onMore,
                icon: Icon(Icons.more_vert, size: Sizes.size20, color: colors.text3),
              ),
          ],
        ),
      ),
    );
  }
}
