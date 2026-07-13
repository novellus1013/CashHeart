// CsvDataService(사용자 노출 CSV 내보내기/가져오기, Sprint 5)의 왕복(round-trip)
// 정확성과 병합(merge) 동작, 손상된 행에 대한 부분 실패 처리를 검증한다.
//
// GiftRepository.forTesting / PersonRepository.forTesting으로 in-memory
// sqflite_common_ffi Database를 두 Repository가 공유하도록 주입해, FK 관계가
// 실제 스키마(AppDatabase.onCreate)와 어긋나지 않게 한다.

import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:cash_heart/services/csv_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late PersonRepository personRepository;
  late GiftRepository giftRepository;
  late CsvDataService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 3,
      onCreate: AppDatabase.onCreate,
    );
    personRepository = PersonRepository.forTesting(db);
    giftRepository = GiftRepository.forTesting(db);
    service = CsvDataService(
      personRepository: personRepository,
      giftRepository: giftRepository,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('CsvDataService.exportToCsvString', () {
    test('헤더만 있고 거래가 없으면 헤더 행만 반환한다', () async {
      final csvString = await service.exportToCsvString();
      expect(csvString.trim(), '이름,인물분류,금액,구분,항목,날짜,메모');
    });

    test('person 이름을 조인해 거래 1건당 1행으로 직렬화한다', () async {
      final personId = await personRepository.insertPerson(
        Person(name: '김민준', category: '친구'),
      );
      await giftRepository.insertGift(Gift(
        personId: personId,
        amount: 50000,
        direction: GiftDirection.received,
        category: GiftCategory.wedding,
        date: DateTime(2026, 1, 15).millisecondsSinceEpoch,
        note: '축하해요',
      ));

      final csvString = await service.exportToCsvString();
      expect(csvString, contains('김민준'));
      expect(csvString, contains('친구'));
      expect(csvString, contains('50000'));
      expect(csvString, contains('받은 돈'));
      expect(csvString, contains('결혼'));
      expect(csvString, contains('2026-01-15'));
      expect(csvString, contains('축하해요'));
    });
  });

  group('CsvDataService.importFromCsvString', () {
    test('새 이름은 인물을 새로 만들고 거래를 병합한다', () async {
      const content = '이름,인물분류,금액,구분,항목,날짜,메모\r\n'
          '이서연,가족,30000,준 돈,생일,2026-03-01,생일 축하\r\n';

      final result = await service.importFromCsvString(content);

      expect(result.importedGifts, 1);
      expect(result.failedRows, 0);

      final persons = await personRepository.getAllPersons();
      expect(persons, hasLength(1));
      expect(persons.first.name, '이서연');
      expect(persons.first.category, '가족');

      final gifts = await giftRepository.getAllGifts();
      expect(gifts, hasLength(1));
      expect(gifts.first.amount, 30000);
      expect(gifts.first.direction, GiftDirection.given);
      expect(gifts.first.category, GiftCategory.birthday);
    });

    test('기존 이름과 같으면 인물을 새로 만들지 않고 재사용한다', () async {
      final existingId = await personRepository.insertPerson(
        Person(name: '박지훈', category: '직장'),
      );

      const content = '이름,인물분류,금액,구분,항목,날짜,메모\r\n'
          '박지훈,직장,100000,받은 돈,결혼,2026-05-05,\r\n';

      final result = await service.importFromCsvString(content);
      expect(result.importedGifts, 1);

      final persons = await personRepository.getAllPersons();
      expect(persons, hasLength(1)); // 신규 생성 없이 재사용

      final gifts = await giftRepository.getGiftsListByPersonId(existingId);
      expect(gifts, hasLength(1));
    });

    test('손상된 행은 건너뛰고 나머지는 정상적으로 가져온다', () async {
      const content = '이름,인물분류,금액,구분,항목,날짜,메모\r\n'
          '정상인물,친구,10000,준 돈,생일,2026-02-02,\r\n'
          ',가족,10000,준 돈,생일,2026-02-02,\r\n' // 이름 없음
          '금액깨짐,가족,abc,준 돈,생일,2026-02-02,\r\n' // 금액이 숫자가 아님
          '구분깨짐,가족,10000,모름,생일,2026-02-02,\r\n'; // 알 수 없는 구분 라벨

      final result = await service.importFromCsvString(content);

      expect(result.importedGifts, 1);
      expect(result.failedRows, 3);

      final gifts = await giftRepository.getAllGifts();
      expect(gifts, hasLength(1));
    });

    test('내보낸 CSV를 그대로 가져오면 동일한 거래가 복원된다(왕복)', () async {
      final personId = await personRepository.insertPerson(
        Person(name: '최수아', category: '지인'),
      );
      await giftRepository.insertGift(Gift(
        personId: personId,
        amount: 77000,
        direction: GiftDirection.given,
        category: GiftCategory.funeral,
        date: DateTime(2025, 11, 20).millisecondsSinceEpoch,
        note: '삼가 고인의 명복을 빕니다',
      ));

      final exported = await service.exportToCsvString();

      // 같은 DB에 다시 가져오면 이름이 이미 존재하므로 거래만 추가된다(병합).
      final result = await service.importFromCsvString(exported);
      expect(result.importedGifts, 1);
      expect(result.failedRows, 0);

      final gifts = await giftRepository.getAllGifts();
      expect(gifts, hasLength(2)); // 원본 1건 + 재가져오기 1건
      expect(gifts.every((g) => g.amount == 77000), isTrue);

      final persons = await personRepository.getAllPersons();
      expect(persons, hasLength(1)); // 병합되어 인물은 늘지 않음
    });
  });
}
