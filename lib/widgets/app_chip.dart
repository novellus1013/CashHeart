import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `Chip` 이식. 선택되면 [activeColor]로 채워지고, 아니면
/// surface 배경 + border만 보인다.
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  /// 선택 시 채움 색(기본 text — 검정에 가까운 fill). 방향성 accent가 필요한
  /// 화면(Add/Edit Gift의 given/received)은 이 값을 넘긴다.
  final Color? activeColor;

  const AppChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final fill = activeColor ?? colors.text;
    // activeColor 미지정(기본 fill=colors.text)일 땐 다크모드에서 fill이 거의
    // 흰색이 되어 하드코딩된 Colors.white 글자가 안 보이던 버그(2026-07-11) —
    // 이 경우 배경(surface)색을 글자색으로 써서 라이트/다크 모두 대비를 보장한다.
    // activeColor를 명시적으로 넘긴 경우(예: given/received accent)는 항상
    // 흰 글자로도 대비가 충분해 그대로 둔다.
    final foreground = activeColor != null ? Colors.white : colors.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: Sizes.size40,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: Sizes.size18),
        decoration: BoxDecoration(
          color: active ? fill : colors.surface,
          borderRadius: AppRadii.pillRadius,
          border: active ? null : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: Sizes.size16,
                color: active ? foreground : colors.text2,
              ),
              Gaps.h5,
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 14.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? foreground : colors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// design_handoff `ChipRow` 이식 — 가로 스크롤 칩 목록.
class ChipRow<T> extends StatelessWidget {
  final List<T> items;

  /// 아직 아무것도 선택되지 않은 상태(폼 미입력 등)를 표현하려면 null을 넘긴다 —
  /// 이 경우 모든 칩이 비활성 상태로 렌더된다.
  final T? value;
  final ValueChanged<T> onChanged;
  final String Function(T item) labelOf;
  final IconData Function(T item)? iconOf;
  final Color? activeColor;

  const ChipRow({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelOf,
    this.iconOf,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items) ...[
            AppChip(
              label: labelOf(item),
              active: item == value,
              icon: iconOf?.call(item),
              activeColor: activeColor,
              onTap: () => onChanged(item),
            ),
            Gaps.h8,
          ],
        ],
      ),
    );
  }
}
