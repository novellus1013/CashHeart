import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RelationshipStats', () {
    test('net/total/tilt은 받은/준 마음으로 계산된다', () {
      const stats = RelationshipStats(received: 800000, given: 200000, count: 3);

      expect(stats.net, 600000);
      expect(stats.total, 1000000);
      expect(stats.tilt, 0.6);
    });

    test('기록이 없으면(total=0) tilt은 0, direction은 even', () {
      expect(RelationshipStats.empty.tilt, 0.0);
      expect(RelationshipStats.empty.direction, RelationshipDirection.even);
      expect(RelationshipStats.empty.years, 0);
    });

    test('tilt 크기에 따라 balanced/tilted/severe 상태가 BalanceState.fromTilt와 일치한다', () {
      const balanced = RelationshipStats(received: 550000, given: 450000, count: 2);
      const tilted = RelationshipStats(received: 700000, given: 300000, count: 2);
      const severe = RelationshipStats(received: 900000, given: 100000, count: 2);

      expect(balanced.state, BalanceState.balanced);
      expect(tilted.state, BalanceState.tilted);
      expect(severe.state, BalanceState.severe);
    });

    test('direction은 tilt 완만 구간(|tilt|<=0.04)에서 even, 그 외엔 치우친 방향', () {
      const even = RelationshipStats(received: 510000, given: 490000, count: 2);
      const received = RelationshipStats(received: 600000, given: 400000, count: 2);
      const given = RelationshipStats(received: 400000, given: 600000, count: 2);

      expect(even.direction, RelationshipDirection.even);
      expect(received.direction, RelationshipDirection.received);
      expect(given.direction, RelationshipDirection.given);
    });

    test('years는 첫/마지막 기록 간격을 365.25일로 나눈 반올림값이되 최소 1년', () {
      final sameDay = RelationshipStats(
        received: 100000,
        given: 0,
        count: 1,
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime(2024, 1, 1),
      );
      final fiveYears = RelationshipStats(
        received: 100000,
        given: 0,
        count: 9,
        firstDate: DateTime(2019, 1, 1),
        lastDate: DateTime(2024, 1, 1),
      );

      expect(sameDay.years, 1);
      expect(fiveYears.years, 5);
    });
  });
}
