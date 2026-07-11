import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('balanceToneMessage', () {
    test('기록이 없으면 count/state와 무관하게 "기록 없음" 톤', () {
      expect(
        balanceToneMessage(count: 0, state: BalanceState.balanced),
        '아직 오고 간 기록이 없어요.',
      );
    });

    test('기록이 1건이면 상태와 무관하게 "더 필요해요" 톤', () {
      expect(
        balanceToneMessage(count: 1, state: BalanceState.severe),
        '더 많은 기록이 쌓이면 관계의 흐름이 보여요.',
      );
    });

    test('기록이 2건 이상이면 상태별 관찰자 톤 메시지', () {
      expect(
        balanceToneMessage(count: 5, state: BalanceState.balanced),
        '주고받음이 균형 잡혀 있어요.',
      );
      expect(
        balanceToneMessage(count: 5, state: BalanceState.tilted),
        '주고받음이 한쪽으로 기울어 있어요.',
      );
      expect(
        balanceToneMessage(count: 5, state: BalanceState.severe),
        '이 관계는 한쪽으로 흐르고 있어요.',
      );
    });

    test('금지어(부족/낮은/차이남/균형이 깨짐)를 포함하지 않는다', () {
      for (final state in BalanceState.values) {
        for (final count in [0, 1, 5]) {
          final message = balanceToneMessage(count: count, state: state);
          expect(message, isNot(contains('부족')));
          expect(message, isNot(contains('낮은')));
          expect(message, isNot(contains('차이남')));
          expect(message, isNot(contains('깨짐')));
          expect(message, isNot(matches(RegExp(r'[↑↓→]'))));
        }
      }
    });
  });

  group('tiltDirectionNote', () {
    test('tilt 양수는 받은 마음 문구', () {
      expect(tiltDirectionNote(0.4), '받은 마음이 많아요');
    });

    test('tilt 음수는 준 마음 문구', () {
      expect(tiltDirectionNote(-0.4), '준 마음이 많아요');
    });
  });

  group('relativeTimeLabel', () {
    test('1일 미만은 "오늘"', () {
      expect(relativeTimeLabel(DateTime.now()), '오늘');
    });

    test('7일 미만은 "N일 전"', () {
      final date = DateTime.now().subtract(const Duration(days: 3));
      expect(relativeTimeLabel(date), '3일 전');
    });

    test('30일 미만은 "N주 전"', () {
      final date = DateTime.now().subtract(const Duration(days: 14));
      expect(relativeTimeLabel(date), '2주 전');
    });

    test('365일 미만은 "N개월 전"', () {
      final date = DateTime.now().subtract(const Duration(days: 90));
      expect(relativeTimeLabel(date), '3개월 전');
    });

    test('365일 이상은 "N년 전"', () {
      final date = DateTime.now().subtract(const Duration(days: 800));
      expect(relativeTimeLabel(date), '2년 전');
    });
  });
}
