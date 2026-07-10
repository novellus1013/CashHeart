import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 관계 균형 상태. tilt = (received - given) / (received + given).
/// 라벨 카피는 Sprint 3 카피 톤 게이트 대상이라 여기서 하드코딩하지 않는다.
enum BalanceState {
  balanced,
  tilted,
  severe;

  static BalanceState fromTilt(double tilt) {
    final magnitude = tilt.abs();
    if (magnitude >= 0.55) return BalanceState.severe;
    if (magnitude >= 0.25) return BalanceState.tilted;
    return BalanceState.balanced;
  }
}

extension BalanceStateColor on BalanceState {
  Color color(AppColors colors) {
    switch (this) {
      case BalanceState.balanced:
        return colors.balanced;
      case BalanceState.tilted:
        return colors.tilted;
      case BalanceState.severe:
        return colors.severe;
    }
  }
}
