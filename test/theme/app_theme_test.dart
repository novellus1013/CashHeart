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
