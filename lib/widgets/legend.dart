import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `Legend` 이식 — "받은 마음"/"준 마음" 색 범례.
class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    Widget dot(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Sizes.size9,
              height: Sizes.size9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Gaps.h5,
            Text(label, style: AppTextStyles.caption.copyWith(color: colors.text2)),
          ],
        );

    return Padding(
      padding: EdgeInsets.only(top: Sizes.size14),
      child: Row(
        children: [
          dot(colors.received, '받은 마음'),
          Gaps.h16,
          dot(colors.given, '준 마음'),
        ],
      ),
    );
  }
}
