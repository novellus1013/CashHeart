import 'package:shared_preferences/shared_preferences.dart';

/// 권장(recommended) 업데이트 다이얼로그 노출 정책(Sprint 5).
///
/// v2.0은 권장 다이얼로그만 자동 노출한다(2026-07-13 사용자 승인) — 로컬 상수
/// 비교(`AppVersion.latest`) 방식은 이미 설치된 구버전에 소급 적용이 안 되는
/// 구조적 한계가 있어, 그 위에 강제 업데이트 자동 트리거까지 만드는 비용 대비
/// 실익이 낮다고 판단해 `UpdateDialogVariant.forced`는 코드로만 보존한다.
class UpdatePolicyService {
  UpdatePolicyService._internal();
  static final UpdatePolicyService instance = UpdatePolicyService._internal();

  static const _snoozeUntilKey = 'update_snooze_until_ms';
  static const _snoozeVersionKey = 'update_snooze_version';

  /// Settings "인앱 업데이트 알림" 토글이 쓰는 키. 화면과 이 서비스가 동일한
  /// 키를 참조해야 토글 off가 실제로 다이얼로그 노출을 막는다.
  static const notificationEnabledKey = 'in_app_update_notification_enabled';

  /// "나중에" 클릭 시 재노출을 미루는 기간(2026-07-13 사용자 승인: 3일).
  static const snoozeDuration = Duration(days: 3);

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationEnabledKey) ?? true;
  }

  /// [latestVersion]에 대해 아직 스누즈 기간이 남아있으면 true.
  /// 스누즈 대상 버전이 [latestVersion]과 다르면(= 그 사이 새 버전이 나왔으면)
  /// 스누즈가 자동으로 무효화된다.
  Future<bool> isSnoozed(String latestVersion) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_snoozeVersionKey) != latestVersion) return false;

    final snoozeUntilMs = prefs.getInt(_snoozeUntilKey);
    if (snoozeUntilMs == null) return false;

    return DateTime.now().millisecondsSinceEpoch < snoozeUntilMs;
  }

  Future<void> snooze(String latestVersion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snoozeVersionKey, latestVersion);
    await prefs.setInt(
      _snoozeUntilKey,
      DateTime.now().add(snoozeDuration).millisecondsSinceEpoch,
    );
  }
}
