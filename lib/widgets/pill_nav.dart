import 'dart:ui';

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

  /// 화면 콘텐츠가 이 플로팅 내비게이션과 겹치지 않도록 예약해야 하는 하단
  /// 여백. `MainShellScreen`이 PillNav를 `24 + 시스템 인셋(MediaQuery.padding.
  /// bottom)`만큼 띄워서 그리므로, 콘텐츠 쪽 padding도 같은 인셋을 더해야
  /// 기기별 안드로이드 네비게이션 바 높이(제스처 바/3버튼 바)와 무관하게 안전하다.
  /// (2026-07-11: 안드로이드 시스템 바 색을 억지로 칠하는 방식은 API 35+
  /// edge-to-edge 강제 적용 기기에서 무시될 수 있다는 지적으로, "겹치지 않게
  /// 안전 영역을 확보"하는 이 방식으로 대체 — 색 지정은 구버전 호환용으로만 유지.)
  static double bottomClearance(BuildContext context) =>
      Sizes.size96 + Sizes.size24 + MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ClipRRect(
      borderRadius: AppRadii.pillRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.size12,
            vertical: Sizes.size8,
          ),
          decoration: BoxDecoration(
            color: colors.navBg,
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
                    color: isSelected ? colors.primary : Colors.transparent,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: Sizes.size20,
                        color: isSelected ? Colors.white : colors.text3,
                      ),
                      if (isSelected) ...[
                        Gaps.h4,
                        Text(
                          item.label,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
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
        ),
      ),
    );
  }
}
