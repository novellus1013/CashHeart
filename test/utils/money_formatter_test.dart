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
}
