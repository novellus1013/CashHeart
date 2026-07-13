import 'package:cash_heart/utils/korean_particle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pickJosa', () {
    test('받침 있는 글자로 끝나면 withBatchim을 반환한다', () {
      expect(
        pickJosa('정훈', withBatchim: '이', withoutBatchim: '가'),
        '이',
      );
      expect(
        pickJosa('김민준님', withBatchim: '이', withoutBatchim: '가'),
        '이',
      );
    });

    test('받침 없는 글자로 끝나면 withoutBatchim을 반환한다', () {
      expect(
        pickJosa('민수', withBatchim: '이', withoutBatchim: '가'),
        '가',
      );
      expect(
        pickJosa('하나', withBatchim: '이', withoutBatchim: '가'),
        '가',
      );
    });

    test('한글이 아닌 마지막 글자는 받침 없음으로 간주한다', () {
      expect(
        pickJosa('Tom', withBatchim: '이', withoutBatchim: '가'),
        '가',
      );
    });

    test('빈 문자열은 withoutBatchim을 반환한다', () {
      expect(pickJosa('', withBatchim: '이', withoutBatchim: '가'), '가');
    });
  });
}
