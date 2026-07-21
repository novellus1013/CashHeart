import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  /// v1.1까지 쓰인 bool 키(라이트/다크 토글만 지원). 마이그레이션 읽기 전용 — 더 이상 쓰지 않는다.
  static const String _legacyDarkModeKey = 'theme_mode';

  /// Sprint 3부터 — 자동(system)/라이트/다크 3옵션을 문자열로 저장.
  static const String _themeModeKey = 'theme_mode_v2';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  final SharedPreferences? _prefs;

  ThemeProvider([this._prefs]) {
    if (_prefs != null) {
      _themeMode = _loadThemeMode(_prefs);
    }
  }

  /// main()에서 호출하여 초기화된 ThemeProvider 반환
  static Future<ThemeProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeProvider(prefs);
  }

  /// 새 키(`theme_mode_v2`)가 없으면 v1.1 bool 키(`theme_mode`)를 읽어
  /// 사용자의 기존 라이트/다크 선택을 보존한다(신규 설치는 기본 system).
  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final saved = prefs.getString(_themeModeKey);
    if (saved != null) return _parseThemeMode(saved);

    final legacyIsDark = prefs.getBool(_legacyDarkModeKey);
    if (legacyIsDark != null) {
      return legacyIsDark ? ThemeMode.dark : ThemeMode.light;
    }

    return ThemeMode.system;
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(_themeMode));
    } catch (e) {
      debugPrint('ThemeProvider: 테마 저장 실패 - $e');
    }
  }
}
