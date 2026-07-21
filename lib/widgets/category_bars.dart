import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:flutter/material.dart';

class CategoryBarData {
  final String label;
  final IconData icon;
  final int received;
  final int given;

  const CategoryBarData({
    required this.label,
    required this.icon,
    required this.received,
    required this.given,
  });
}

/// design_handoff `CategoryBars` 이식 — 경조사 카테고리별 준/받은 마음 mini bar.
class CategoryBars extends StatelessWidget {
  final List<CategoryBarData> byCategory;

  const CategoryBars({super.key, required this.byCategory});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final maxValue = byCategory
        .expand((c) => [c.received, c.given])
        .fold<int>(1, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final category in byCategory) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(Sizes.size8),
                ),
                child: Icon(category.icon, size: 17, color: colors.text2),
              ),
              Gaps.h10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.label,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.5,
                            color: colors.text2,
                          ),
                        ),
                        Text(
                          category.received + category.given == 0
                              ? '–'
                              : MoneyFormatter.formatWonShort(
                                  category.received + category.given),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.5,
                            color: colors.text3,
                          ),
                        ),
                      ],
                    ),
                    Gaps.v4,
                    _MiniBar(
                      value: category.received,
                      max: maxValue,
                      color: colors.received,
                      track: colors.borderSoft,
                    ),
                    Gaps.v3,
                    _MiniBar(
                      value: category.given,
                      max: maxValue,
                      color: colors.given,
                      track: colors.borderSoft,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (category != byCategory.last) Gaps.v14,
        ],
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final int value;
  final int max;
  final Color color;
  final Color track;

  const _MiniBar({
    required this.value,
    required this.max,
    required this.color,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
