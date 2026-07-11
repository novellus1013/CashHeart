// GiftRepository.getStatsByPerson()의 GROUP BY 집계 SQL을 검증한다.
// GiftRepository._db는 AppDatabase.instance(실 기기 경로)에 묶여 있어 직접
// 테스트할 수 없으므로, 테스트 전용 GiftRepository.forTesting(db) 생성자로
// in-memory sqflite_common_ffi Database를 주입한다. 스키마는 AppDatabase.onCreate
// (@visibleForTesting static)를 그대로 재사용해 실제 프로덕션 스키마와 어긋나지 않게 한다.

import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late GiftRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 3, onCreate: AppDatabase.onCreate);
    repository = GiftRepository.forTesting(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertPerson(String name) {
    return db.insert('persons', {
      'name': name,
      'note': null,
      'category': null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> insertGift({
    required int personId,
    required int amount,
    required GiftDirection direction,
    required DateTime date,
  }) async {
    await repository.insertGift(Gift(
      personId: personId,
      amount: amount,
      direction: direction,
      category: GiftCategory.etc,
      date: date.millisecondsSinceEpoch,
      note: '',
    ));
  }

  group('GiftRepository.getStatsByPerson', () {
    test('기록이 없으면 빈 맵을 반환한다', () async {
      final stats = await repository.getStatsByPerson();
      expect(stats, isEmpty);
    });

    test('person별 received/given/count를 정확히 합산한다', () async {
      final person1 = await insertPerson('김민준');
      final person2 = await insertPerson('이서연');

      await insertGift(
        personId: person1,
        amount: 100000,
        direction: GiftDirection.received,
        date: DateTime(2024, 1, 1),
      );
      await insertGift(
        personId: person1,
        amount: 50000,
        direction: GiftDirection.given,
        date: DateTime(2024, 6, 1),
      );
      await insertGift(
        personId: person2,
        amount: 30000,
        direction: GiftDirection.given,
        date: DateTime(2024, 3, 1),
      );

      final stats = await repository.getStatsByPerson();

      expect(stats[person1]!.received, 100000);
      expect(stats[person1]!.given, 50000);
      expect(stats[person1]!.count, 2);

      expect(stats[person2]!.received, 0);
      expect(stats[person2]!.given, 30000);
      expect(stats[person2]!.count, 1);

      // 다른 person의 gift에 영향을 주지 않는다(교차 오염 없음).
      expect(stats.length, 2);
    });

    test('firstDate/lastDate는 person별 최소/최대 date를 반환한다', () async {
      final person = await insertPerson('박지훈');

      await insertGift(
        personId: person,
        amount: 10000,
        direction: GiftDirection.given,
        date: DateTime(2020, 5, 1),
      );
      await insertGift(
        personId: person,
        amount: 20000,
        direction: GiftDirection.received,
        date: DateTime(2024, 1, 1),
      );
      await insertGift(
        personId: person,
        amount: 15000,
        direction: GiftDirection.given,
        date: DateTime(2022, 8, 15),
      );

      final stats = await repository.getStatsByPerson();
      final entry = stats[person]!;

      expect(entry.firstDate, DateTime(2020, 5, 1));
      expect(entry.lastDate, DateTime(2024, 1, 1));
    });
  });
}
