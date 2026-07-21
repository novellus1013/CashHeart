import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('determineShareCardCase — 일방통행(A)', () {
    test('한 방향 70% 이상 AND 3회 이상이면 우세한 방향에 맞는 케이스를 반환한다', () {
      const givenDominant =
          RelationshipStats(received: 300000, given: 700000, count: 3);
      const receivedDominant =
          RelationshipStats(received: 700000, given: 300000, count: 3);

      expect(
        determineShareCardCase(
            stats: givenDominant, rank: 1, totalPersonsWithRecords: 1),
        ShareCardCase.oneWayGiven,
      );
      expect(
        determineShareCardCase(
            stats: receivedDominant, rank: 1, totalPersonsWithRecords: 1),
        ShareCardCase.oneWayReceived,
      );
    });

    test('69%는 미달로 none, 70%는 충족한다(경계값)', () {
      const below =
          RelationshipStats(received: 310000, given: 690000, count: 3);
      const at = RelationshipStats(received: 300000, given: 700000, count: 3);

      expect(below.dominantPercent, 69);
      expect(at.dominantPercent, 70);
      expect(
        determineShareCardCase(
            stats: below, rank: 1, totalPersonsWithRecords: 1),
        ShareCardCase.none,
      );
      expect(
        determineShareCardCase(stats: at, rank: 1, totalPersonsWithRecords: 1),
        ShareCardCase.oneWayGiven,
      );
    });

    test('비율은 충족해도 횟수(3회)가 미달이면 none', () {
      const twice =
          RelationshipStats(received: 100000, given: 900000, count: 2);

      expect(
        determineShareCardCase(
            stats: twice, rank: 1, totalPersonsWithRecords: 1),
        ShareCardCase.none,
      );
    });
  });

  group('determineShareCardCase — 영혼의 동반자(E)', () {
    RelationshipStats mutual({int count = 6}) => RelationshipStats(
          received: 300000,
          given: 300000,
          count: count,
        );

    test('양방향 존재 AND 6회 이상 AND 상위 20% 이내면 soulmate', () {
      expect(
        determineShareCardCase(
            stats: mutual(), rank: 2, totalPersonsWithRecords: 10),
        ShareCardCase.soulmate,
      );
    });

    test('한쪽 방향이 0이면(양방향 아님) soulmate가 될 수 없다', () {
      const oneSided =
          RelationshipStats(received: 600000, given: 0, count: 6);

      // 100% 편중이라 A 조건(70%+3회)은 만족하지만 mutual이 아니므로 E는 아님.
      expect(
        determineShareCardCase(
            stats: oneSided, rank: 1, totalPersonsWithRecords: 10),
        ShareCardCase.oneWayReceived,
      );
    });

    test('횟수(6회) 미달이면 상위권이어도 none', () {
      expect(
        determineShareCardCase(
            stats: mutual(count: 5), rank: 1, totalPersonsWithRecords: 10),
        ShareCardCase.none,
      );
    });

    test('상위 20% 경계값: totalPersonsWithRecords=10이면 rank<=2까지 통과, 3부터 탈락', () {
      expect(
        determineShareCardCase(
            stats: mutual(), rank: 2, totalPersonsWithRecords: 10),
        ShareCardCase.soulmate,
      );
      expect(
        determineShareCardCase(
            stats: mutual(), rank: 3, totalPersonsWithRecords: 10),
        ShareCardCase.none,
      );
    });

    test('지인이 5명 미만이면 상위권 게이트를 건너뛴다(mutual+6회만 충족하면 통과)', () {
      expect(
        determineShareCardCase(
            stats: mutual(), rank: 4, totalPersonsWithRecords: 4),
        ShareCardCase.soulmate,
      );
    });

    test('A/E 동시 충족 시 E가 우선한다', () {
      // 총액 100만원 중 70만원이 received(70% → A 조건 충족)이면서
      // given도 30만원 있어 mutual, count 6, 상위권까지 만족.
      const both =
          RelationshipStats(received: 700000, given: 300000, count: 6);

      expect(
        determineShareCardCase(
            stats: both, rank: 1, totalPersonsWithRecords: 10),
        ShareCardCase.soulmate,
      );
    });
  });

  group('determineShareCardCase — 미달', () {
    test('아무 조건도 만족하지 않으면 none', () {
      const balanced =
          RelationshipStats(received: 550000, given: 450000, count: 2);

      expect(
        determineShareCardCase(
            stats: balanced, rank: 5, totalPersonsWithRecords: 10),
        ShareCardCase.none,
      );
    });
  });
}
