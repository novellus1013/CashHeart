import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// main.dart의 기존 _buildLightTheme()/_buildDarkTheme()를 흡수.
/// 색상 값만 lib/theme/app_colors.dart 토큰 기준으로 갱신, 나머지 구조는 동일.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colors = AppColors.light;
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'pretendard',
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
      ),
      extensions: const [colors],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.bg,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: Sizes.size20,
          color: colors.text,
        ),
        iconTheme: IconThemeData(color: colors.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: Sizes.size14,
          color: colors.text2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: colors.surface,
      dividerColor: colors.border,
    );
  }

  static ThemeData dark() {
    const colors = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'pretendard',
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.dark,
      ),
      extensions: const [colors],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.bg,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: Sizes.size20,
          color: colors.text,
        ),
        iconTheme: IconThemeData(color: colors.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: Sizes.size14,
          color: colors.text3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: colors.surface,
      dividerColor: colors.border,
    );
  }
}
