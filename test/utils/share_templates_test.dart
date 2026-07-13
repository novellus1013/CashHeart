import 'package:cash_heart/utils/share_card_case.dart';
import 'package:cash_heart/utils/share_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loadShareTemplate', () {
    test('3개 케이스 모두 title과 비어있지 않은 messages를 갖는다', () async {
      for (final caseType in [
        ShareCardCase.oneWayGiven,
        ShareCardCase.oneWayReceived,
        ShareCardCase.soulmate,
      ]) {
        final template = await loadShareTemplate(caseType);

        expect(template.title, isNotEmpty);
        expect(template.messages, isNotEmpty);
      }
    });

    test('none 케이스는 로드할 수 없다', () {
      expect(
        () => loadShareTemplate(ShareCardCase.none),
        throwsArgumentError,
      );
    });
  });

  group('pickRandomMessage', () {
    test('exclude와 다른 문구를 반환한다(후보 2개 이상일 때)', () {
      final messages = ['A', 'B', 'C'];

      for (var i = 0; i < 20; i++) {
        final picked = pickRandomMessage(messages, exclude: 'A');
        expect(picked, isNot('A'));
      }
    });

    test('후보가 1개뿐이면 그대로 반환한다', () {
      expect(pickRandomMessage(['혼자'], exclude: '혼자'), '혼자');
    });

    test('빈 목록이면 빈 문자열을 반환한다', () {
      expect(pickRandomMessage([]), '');
    });
  });
}
