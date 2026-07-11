import 'package:flutter/material.dart';

/// design_handoff `--elev`/`--elev-2` 그림자 토큰. 라이트/다크 값이 다르므로
/// 위젯에서 직접 `BoxShadow(...)`를 하드코딩하지 않고 이 토큰을 참조한다.
class AppElevations {
  static List<BoxShadow> elev(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ];
  }

  static List<BoxShadow> elev2(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ];
  }
}
