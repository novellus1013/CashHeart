import 'package:flutter/material.dart';

/// design_handoff_cashheart 스펙의 색 토큰.
/// primary(#FF6258) = 준 마음(given), secondary(#027DFD) = 받은 마음(received).
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primarySoft;
  final Color secondary;
  final Color secondarySoft;
  final Color bg;
  final Color surface;
  final Color text;
  final Color text2;
  final Color text3;
  final Color border;
  final Color borderSoft;
  final Color balanced;
  final Color tilted;
  final Color severe;
  final Color balancedSoft;
  final Color tiltedSoft;
  final Color severeSoft;

  /// hero 카드 배경(design_handoff `--card-grad`, 160deg).
  final Gradient cardGrad;

  /// PillNav 배경(design_handoff `--nav-bg`, 반투명 0.94 — blur와 함께 사용).
  final Color navBg;

  /// 준 마음(given) 색 — 파랑 계열(secondary). 2026-07-10 시안 검수에서
  /// 기존 앱 관습(내가 준 돈 = 파랑, 받은 돈 = 빨강)을 따르기로 최종 확정.
  /// design_handoff 문서 원문은 반대(primary=given)로 적혀 있으나, 실제 화면에서
  /// 이 매핑이 더 자연스럽다는 사용자 피드백으로 뒤집었다 — 항상 이 getter로만 접근할 것.
  Color get given => secondary;

  /// 받은 마음(received) 색 — 빨강 계열(primary).
  Color get received => primary;

  const AppColors({
    required this.primary,
    required this.primarySoft,
    required this.secondary,
    required this.secondarySoft,
    required this.bg,
    required this.surface,
    required this.text,
    required this.text2,
    required this.text3,
    required this.border,
    required this.borderSoft,
    required this.balanced,
    required this.tilted,
    required this.severe,
    required this.balancedSoft,
    required this.tiltedSoft,
    required this.severeSoft,
    required this.cardGrad,
    required this.navBg,
  });

  static const light = AppColors(
    primary: Color(0xFFFF6258),
    primarySoft: Color(0xFFFFEDEB),
    secondary: Color(0xFF027DFD),
    secondarySoft: Color(0xFFE7F2FF),
    bg: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1A1A1A),
    text2: Color(0xFF666666),
    text3: Color(0xFF9A9A9A),
    border: Color(0xFFE5E5E5),
    borderSoft: Color(0xFFF0F0F0),
    balanced: Color(0xFF4CAF50),
    tilted: Color(0xFFFFA726),
    severe: Color(0xFFFF6258),
    balancedSoft: Color(0xFFE8F5E9),
    tiltedSoft: Color(0xFFFFF3E0),
    severeSoft: Color(0xFFFFEDEB),
    // 2026-07-11 사용자 검수: 원안(#FFF6F5)이 너무 미묘해 눈에 띄게 보이도록 조정.
    cardGrad: LinearGradient(
      begin: Alignment(-0.34, -0.94),
      end: Alignment(0.34, 0.94),
      colors: [Color(0xFFFFFFFF), Color(0xFFFFE3DE)],
    ),
    // rgba(255,255,255,0.94)
    navBg: Color(0xF0FFFFFF),
  );

  static const dark = AppColors(
    primary: Color(0xFFFF7A70),
    // rgba(255,122,112,0.16) — 프로토타입 다크는 라이트값 복붙이 아니라 반투명.
    primarySoft: Color(0x29FF7A70),
    secondary: Color(0xFF4DA3FF),
    // rgba(77,163,255,0.16)
    secondarySoft: Color(0x294DA3FF),
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    text: Color(0xFFF5F5F5),
    text2: Color(0xFFA0A0A0),
    text3: Color(0xFF6E6E6E),
    border: Color(0xFF2C2C2C),
    borderSoft: Color(0xFF262626),
    balanced: Color(0xFF5DBA61),
    tilted: Color(0xFFFFB74D),
    severe: Color(0xFFFF7A70),
    // rgba(93,186,97,0.16) / rgba(255,183,77,0.16) / rgba(255,122,112,0.16)
    balancedSoft: Color(0x295DBA61),
    tiltedSoft: Color(0x29FFB74D),
    severeSoft: Color(0x29FF7A70),
    // 2026-07-11 사용자 검수: 라이트와 동일하게 대비 강화.
    cardGrad: LinearGradient(
      begin: Alignment(-0.34, -0.94),
      end: Alignment(0.34, 0.94),
      colors: [Color(0xFF232323), Color(0xFF37241F)],
    ),
    // rgba(28,28,28,0.94)
    navBg: Color(0xF01C1C1C),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primarySoft,
    Color? secondary,
    Color? secondarySoft,
    Color? bg,
    Color? surface,
    Color? text,
    Color? text2,
    Color? text3,
    Color? border,
    Color? borderSoft,
    Color? balanced,
    Color? tilted,
    Color? severe,
    Color? balancedSoft,
    Color? tiltedSoft,
    Color? severeSoft,
    Gradient? cardGrad,
    Color? navBg,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      border: border ?? this.border,
      borderSoft: borderSoft ?? this.borderSoft,
      balanced: balanced ?? this.balanced,
      tilted: tilted ?? this.tilted,
      severe: severe ?? this.severe,
      balancedSoft: balancedSoft ?? this.balancedSoft,
      tiltedSoft: tiltedSoft ?? this.tiltedSoft,
      severeSoft: severeSoft ?? this.severeSoft,
      cardGrad: cardGrad ?? this.cardGrad,
      navBg: navBg ?? this.navBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondarySoft: Color.lerp(secondarySoft, other.secondarySoft, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      balanced: Color.lerp(balanced, other.balanced, t)!,
      tilted: Color.lerp(tilted, other.tilted, t)!,
      severe: Color.lerp(severe, other.severe, t)!,
      balancedSoft: Color.lerp(balancedSoft, other.balancedSoft, t)!,
      tiltedSoft: Color.lerp(tiltedSoft, other.tiltedSoft, t)!,
      severeSoft: Color.lerp(severeSoft, other.severeSoft, t)!,
      cardGrad: Gradient.lerp(cardGrad, other.cardGrad, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
    );
  }
}
