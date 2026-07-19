// UpdatePolicyService(권장 업데이트 다이얼로그 노출 정책, Sprint 5) 검증.
// SharedPreferences.setMockInitialValues로 플랫폼 채널 없이 저장/조회를 테스트한다.

import 'package:cash_heart/services/update_policy_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UpdatePolicyService service;

  setUp(() {
    service = UpdatePolicyService.instance;
  });

  group('UpdatePolicyService.isNotificationEnabled', () {
    test('저장된 값이 없으면 기본값 true', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await service.isNotificationEnabled(), isTrue);
    });

    test('설정에서 꺼두면 false를 반환한다', () async {
      SharedPreferences.setMockInitialValues({
        UpdatePolicyService.notificationEnabledKey: false,
      });
      expect(await service.isNotificationEnabled(), isFalse);
    });
  });

  group('UpdatePolicyService.isSnoozed / snooze', () {
    test('스누즈한 적 없으면 false', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await service.isSnoozed('1.3.0'), isFalse);
    });

    test('같은 버전을 방금 스누즈했으면 true', () async {
      SharedPreferences.setMockInitialValues({});
      await service.snooze('1.3.0');
      expect(await service.isSnoozed('1.3.0'), isTrue);
    });

    test('스누즈 대상 버전과 다른 최신 버전이면 false(새 버전 출시 시 스누즈 무효화)', () async {
      SharedPreferences.setMockInitialValues({});
      await service.snooze('1.3.0');
      expect(await service.isSnoozed('1.4.0'), isFalse);
    });

    test('스누즈 만료 시각이 지났으면 false', () async {
      SharedPreferences.setMockInitialValues({
        'update_snooze_version': '1.3.0',
        'update_snooze_until_ms':
            DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      });
      expect(await service.isSnoozed('1.3.0'), isFalse);
    });
  });
}
