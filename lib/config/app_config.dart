/// 앱 환경 설정
///
/// - 개발 모드: AppConfig.setDev()
/// - 프로덕션 모드: AppConfig.setProd()
///
/// main.dart에서 앱 시작 전에 설정
class AppConfig {
  static AppEnvironment _environment = AppEnvironment.dev;

  /// 현재 환경
  static AppEnvironment get environment => _environment;

  /// 개발 모드 여부
  static bool get isDev => _environment == AppEnvironment.dev;

  /// 프로덕션 모드 여부
  static bool get isProd => _environment == AppEnvironment.prod;

  /// Mock 데이터 사용 여부 (dev에서만 true)
  static bool get useMockData => isDev;

  /// Sentry 사용 여부 (prod에서만 true)
  static bool get useSentry => isProd;

  /// 개발 모드로 설정
  static void setDev() {
    _environment = AppEnvironment.dev;
  }

  /// 프로덕션 모드로 설정
  static void setProd() {
    _environment = AppEnvironment.prod;
  }
}

enum AppEnvironment {
  dev,
  prod,
}
