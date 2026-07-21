import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter.formatAbbreviated', () {
    test('9자리 이하는 축약하지 않는다', () {
      final result = MoneyFormatter.formatAbbreviated(999999999);
      expect(result, isNot(contains('억원')));
    });

    test('10자리(10억) 이상은 억 단위로 축약한다', () {
      final result = MoneyFormatter.formatAbbreviated(1234567890);
      expect(result, '12.3억원');
    });

    test('억 단위로 정확히 떨어지면 소수점을 생략한다', () {
      final result = MoneyFormatter.formatAbbreviated(1200000000);
      expect(result, '12억원');
    });

    test('음수 금액도 부호를 유지하며 축약한다', () {
      final result = MoneyFormatter.formatAbbreviated(-1234567890);
      expect(result, '-12.3억원');
    });
  });

  group('MoneyFormatter.formatWonShort', () {
    test('1만 미만은 콤마 포맷 그대로', () {
      expect(MoneyFormatter.formatWonShort(9000), '9,000');
    });

    test('1만 이상 1억 미만은 만 단위로 반올림', () {
      expect(MoneyFormatter.formatWonShort(5300000), '530만');
    });

    test('1억 이상은 억 단위(소수점 1자리, 정수면 생략)', () {
      expect(MoneyFormatter.formatWonShort(120000000), '1.2억');
      expect(MoneyFormatter.formatWonShort(200000000), '2억');
    });

    test('음수는 부호를 유지한다', () {
      expect(MoneyFormatter.formatWonShort(-5300000), '-530만');
    });
  });
}
