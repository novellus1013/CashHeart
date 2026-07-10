import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PillNavItem {
  final IconData icon;
  final String label;

  const PillNavItem({required this.icon, required this.label});
}

/// design_handoff의 floating pill 하단 네비게이션. 실제 라우팅은 미연결(Sprint 3에서 화면에 연결).
class PillNav extends StatelessWidget {
  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const PillNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.size12,
        vertical: Sizes.size8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.pillRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(horizontal: Sizes.size4),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? Sizes.size16 : Sizes.size12,
                vertical: Sizes.size10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.primarySoft : Colors.transparent,
                borderRadius: AppRadii.pillRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: Sizes.size20,
                    color: isSelected ? colors.primary : colors.text3,
                  ),
                  if (isSelected) ...[
                    Gaps.h4,
                    Text(
                      item.label,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
