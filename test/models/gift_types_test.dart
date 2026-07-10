import 'package:cash_heart/models/gift_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GiftCategoryDb.fromDb', () {
    test('알려진 값은 해당 enum으로 매핑된다', () {
      expect(GiftCategoryDb.fromDb('wedding'), GiftCategory.wedding);
      expect(GiftCategoryDb.fromDb('funeral'), GiftCategory.funeral);
      expect(GiftCategoryDb.fromDb('etc'), GiftCategory.etc);
    });

    test('모든 enum 값에 대해 dbValue 왕복(round-trip)이 보존된다', () {
      for (final category in GiftCategory.values) {
        expect(GiftCategoryDb.fromDb(category.dbValue), category);
      }
    });

    test('알 수 없는 값은 크래시 대신 etc로 폴백한다 (P1: DB 손상 방어)', () {
      expect(GiftCategoryDb.fromDb('unknown_garbage'), GiftCategory.etc);
      expect(GiftCategoryDb.fromDb(''), GiftCategory.etc);
      expect(GiftCategoryDb.fromDb('Wedding'), GiftCategory.etc); // 대소문자 불일치
    });
  });

  group('GiftDirectionDb.fromDb', () {
    test('1은 received, -1은 given으로 매핑된다', () {
      expect(GiftDirectionDb.fromDb(1), GiftDirection.received);
      expect(GiftDirectionDb.fromDb(-1), GiftDirection.given);
    });

    test('예상 밖 값(0 등)은 given으로 폴백한다', () {
      expect(GiftDirectionDb.fromDb(0), GiftDirection.given);
      expect(GiftDirectionDb.fromDb(99), GiftDirection.given);
    });
  });

  group('dbValue', () {
    test('received=1, given=-1', () {
      expect(GiftDirection.received.dbValue, 1);
      expect(GiftDirection.given.dbValue, -1);
    });
  });
}
