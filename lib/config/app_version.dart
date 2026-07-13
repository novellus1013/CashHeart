/// 스토어 최신 버전 상수 — 배포마다 수동으로 갱신한다.
///
/// Firebase Remote Config/Play Store API 연동은 Sprint 5에서 검토 후 폐기
/// 확정(2026-07-13) — CashHeart는 순수 로컬 SQLite라 서버 호환성 문제로 인한
/// 강제 업데이트 필요성이 낮고, 신규 Firebase 프로젝트 설정은 사용자 계정
/// 접근이 필요해 AI가 대신 할 수 없다는 점도 고려했다. 설치된 버전
/// (package_info_plus)과 이 상수를 비교하는 로컬 방식을 그대로 유지한다.
/// 실제 트리거 정책은 `UpdatePolicyService`(스누즈)와 `MainShellScreen`
/// `_checkForUpdate()` 참고.
class AppVersion {
  static const String latest = '1.2.0';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=co.novelus.cashheart';
}
