import 'package:cash_heart/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    test('신규 설치(저장값 없음)는 기본 system 모드', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(prefs);

      expect(provider.themeMode, ThemeMode.system);
    });

    test('v1.1 legacy bool 키(theme_mode=true)는 dark로 마이그레이션된다', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': true});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(prefs);

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('v1.1 legacy bool 키(theme_mode=false)는 light로 마이그레이션된다', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': false});
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(prefs);

      expect(provider.themeMode, ThemeMode.light);
    });

    test('새 키(theme_mode_v2)가 있으면 legacy 키보다 우선한다', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': true, // legacy: dark
        'theme_mode_v2': 'system', // 새 값: 사용자가 이후 system으로 바꿨다고 가정
      });
      final prefs = await SharedPreferences.getInstance();

      final provider = ThemeProvider(prefs);

      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode는 새 키에 문자열로 저장하고 즉시 반영한다', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = ThemeProvider(prefs);

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(prefs.getString('theme_mode_v2'), 'dark');
    });
  });
}
