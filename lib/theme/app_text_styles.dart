import 'package:flutter/material.dart';

/// design_handoff_cashheart 스펙의 타이포그래피 토큰.
/// 폰트는 기존 앱과 동일하게 pretendard.
class AppTextStyles {
  static const _fontFamily = 'pretendard';

  static const h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  /// 금액 표시 전용 — 자릿수가 흔들리지 않도록 tabular figures 적용.
  static const amount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// HeroCard 등 화면 최상단 강조 금액 전용(디자인 스펙: Home hero 38px).
  static const heroAmount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 목록 행 등에서 쓰는 작은 금액 표시.
  static const amountSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
