import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme.light', () {
    final theme = AppTheme.light();

    test('AppColors 토큰이 라이트 값으로 등록된다', () {
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.bg, const Color(0xFFFAFAF8));
      expect(colors.primary, const Color(0xFFFF6258));
      expect(colors.secondary, const Color(0xFF027DFD));
    });

    test('scaffoldBackgroundColor/cardColor가 토큰과 일치한다', () {
      expect(theme.scaffoldBackgroundColor, AppColors.light.bg);
      expect(theme.cardColor, AppColors.light.surface);
    });

    test('balance soft 배경/cardGrad 토큰이 프로토타입 값과 일치한다', () {
      final colors = theme.extension<AppColors>()!;
      expect(colors.balancedSoft, const Color(0xFFE8F5E9));
      expect(colors.tiltedSoft, const Color(0xFFFFF3E0));
      expect(colors.severeSoft, const Color(0xFFFFEDEB));
      expect(colors.cardGrad, isA<LinearGradient>());
    });
  });

  group('AppTheme.dark', () {
    final theme = AppTheme.dark();

    test('AppColors 토큰이 다크 값으로 등록된다', () {
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.bg, const Color(0xFF121212));
      expect(colors.primary, const Color(0xFFFF7A70));
      expect(colors.secondary, const Color(0xFF4DA3FF));
    });

    test('scaffoldBackgroundColor/cardColor가 토큰과 일치한다', () {
      expect(theme.scaffoldBackgroundColor, AppColors.dark.bg);
      expect(theme.cardColor, AppColors.dark.surface);
    });

    test('다크 primarySoft/secondarySoft는 반투명(라이트값 복붙이 아니다)', () {
      final colors = theme.extension<AppColors>()!;
      expect(colors.primarySoft.a, closeTo(0x29 / 255, 0.01));
      expect(colors.primarySoft, isNot(AppColors.light.primarySoft));
      expect(colors.secondarySoft, isNot(AppColors.light.secondarySoft));
    });
  });

  test('다크모드 전환 시 배경/카드 색이 실제로 달라진다', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();

    expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
    expect(light.cardColor, isNot(dark.cardColor));
    expect(
      light.extension<AppColors>()!.primary,
      isNot(dark.extension<AppColors>()!.primary),
    );
  });
}
