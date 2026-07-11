/// 스토어 최신 버전 상수 — 배포마다 수동으로 갱신한다.
///
/// Firebase Remote Config/Play Store API 연동 없이, 설치된 버전
/// (package_info_plus)과 이 상수를 비교해 업데이트 안내를 노출한다.
/// 서버 연동 버전은 Sprint 5 소유.
class AppVersion {
  static const String latest = '1.2.0';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=co.novelus.cashheart';
}
