import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `BottomSheet` 이식 — `showModalBottomSheet` 래퍼.
/// drag handle + 선택적 title을 표준화해 화면마다 반복되지 않게 한다.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final colors = Theme.of(context).extension<AppColors>()!;

      return SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            Sizes.size16,
            Sizes.size10,
            Sizes.size16,
            Sizes.size12,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.sheet),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: Sizes.size14),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (title != null) ...[
                Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(color: colors.text),
                ),
                Gaps.v12,
              ],
              builder(context),
            ],
          ),
        ),
      );
    },
  );
}
