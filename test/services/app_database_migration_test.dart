// DB v2 -> v3 마이그레이션(gifts(person_id, date) 복합 인덱스 추가) 검증 테스트.
//
// AppDatabase는 싱글턴이며 실제 디바이스 경로(getDatabasesPath)를 사용하므로
// 여기서는 AppDatabase 인스턴스를 직접 쓰지 않고, AppDatabase.onCreate / onUpgrade
// (@visibleForTesting static 함수)를 sqflite_common_ffi에 그대로 재사용해
// 스키마 로직만 검증한다.
//
// "닫았다가 다시 열어 오래된 데이터가 남아있는지" 검증해야 하므로, 진짜
// in-memory 경로(':memory:')는 쓰지 않는다. sqlite3의 ':memory:'는 연결을
// close하는 순간 내용이 사라지므로 "기존 파일을 새 버전으로 재오픈"하는 실제
// 업그레이드 시나리오를 재현할 수 없다. 대신 OS 임시 디렉토리에 실제 sqlite
// 파일을 만들어 open -> close -> 재open 흐름을 그대로 재현한다.
//
// 주의: 실 기기(App Store/Play Store 배포 중, v1.1 사용자)의 데이터 보존 검증은
// Sprint 1 "사람 게이트" 항목이다. 이 자동 테스트는 스키마/DDL 로직의 회귀를
// 막을 뿐, 실 기기 업그레이드 시 데이터 보존을 대체 증명하지 않는다.

import 'dart:io';

import 'package:cash_heart/services/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 테스트별로 격리된 임시 sqlite 파일 경로를 만든다. 파일 자체는 생성하지
/// 않고 경로만 반환하며, 실제 파일은 `openDatabase`가 만든다.
String _tempDbPath(String name) {
  final dir = Directory.systemTemp.createTempSync('cash_heart_db_test_');
  return p.join(dir.path, name);
}

void _deletePathQuietly(String path) {
  final file = File(path);
  if (file.existsSync()) {
    file.deleteSync();
  }
  final dir = Directory(p.dirname(path));
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

/// v2 시점의 실제 스키마(persons.category 컬럼 포함, 인덱스 없음)를
/// 그대로 재현하는 헬퍼. AppDatabase.onCreate는 항상 "최신" 스키마를 만들기
/// 때문에, 구버전에서 온 사용자를 재현하려면 v2 스키마를 별도로 인라인해야 한다.
Future<Database> _createV2Database(String path) {
  return openDatabase(
    path,
    version: 2,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE persons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          note TEXT,
          category TEXT,
          created_at INTEGER NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE gifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          person_id INTEGER NOT NULL,
          amount INTEGER NOT NULL,
          direction INTEGER NOT NULL,
          category TEXT NOT NULL,
          date INTEGER NOT NULL,
          note TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (person_id) REFERENCES persons (id)
        );
      ''');
    },
  );
}

Future<List<String>> _indexNames(Database db, String table) async {
  final rows = await db.rawQuery("PRAGMA index_list('$table')");
  return rows.map((r) => r['name'] as String).toList();
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('fresh install (onCreate)', () {
    test('v3 fresh create에 idx_gifts_person_date 인덱스가 존재한다', () async {
      final path = _tempDbPath('fresh_v3.db');
      final db = await openDatabase(
        path,
        version: 3,
        onCreate: AppDatabase.onCreate,
      );

      final indexNames = await _indexNames(db, 'gifts');
      expect(indexNames, contains('idx_gifts_person_date'));

      await db.close();
      _deletePathQuietly(path);
    });
  });

  group('upgrade path (v2 -> v3)', () {
    test('업그레이드 시 기존 데이터가 보존되고 인덱스가 생성된다', () async {
      final path = _tempDbPath('upgrade_v2_to_v3.db');

      // 1. v2 스키마로 DB 생성 + 데이터 삽입
      var db = await _createV2Database(path);

      final now = DateTime.now().millisecondsSinceEpoch;
      final personId = await db.insert('persons', {
        'name': '홍길동',
        'note': '대학 동기',
        'category': '친구',
        'created_at': now,
      });

      await db.insert('gifts', {
        'person_id': personId,
        'amount': 50000,
        'direction': 1,
        'category': '결혼',
        'date': now,
        'note': '축하金',
        'created_at': now,
      });
      await db.insert('gifts', {
        'person_id': personId,
        'amount': 30000,
        'direction': -1,
        'category': '조의',
        'date': now + 1000,
        'note': '',
        'created_at': now + 1000,
      });

      // 업그레이드 전 인덱스가 없음을 확인 (전제 검증)
      expect(
        await _indexNames(db, 'gifts'),
        isNot(contains('idx_gifts_person_date')),
      );

      await db.close();

      // 2. 동일 DB 파일을 v3로 재오픈 -> onUpgrade(oldVersion=2, newVersion=3) 호출됨
      db = await openDatabase(
        path,
        version: 3,
        onCreate: AppDatabase.onCreate,
        onUpgrade: AppDatabase.onUpgrade,
      );

      // 인덱스 생성 확인
      expect(await _indexNames(db, 'gifts'), contains('idx_gifts_person_date'));

      // 기존 데이터 보존 확인 (행 수 + 값)
      final persons = await db.query('persons');
      expect(persons, hasLength(1));
      expect(persons.first['name'], '홍길동');
      expect(persons.first['category'], '친구');

      final gifts = await db.query('gifts', orderBy: 'date ASC');
      expect(gifts, hasLength(2));
      expect(gifts[0]['amount'], 50000);
      expect(gifts[0]['direction'], 1);
      expect(gifts[1]['amount'], 30000);
      expect(gifts[1]['direction'], -1);

      await db.close();
      _deletePathQuietly(path);
    });

    test('onUpgrade는 idempotent하다 (재실행해도 에러 없음)', () async {
      final path = _tempDbPath('idempotent.db');
      final db = await _createV2Database(path);

      // 같은 db 커넥션에 대해 onUpgrade를 두 번 호출해도 예외가 발생하지 않아야 한다
      // (CREATE INDEX IF NOT EXISTS 덕분에 idempotent).
      await AppDatabase.onUpgrade(db, 2, 3);
      await AppDatabase.onUpgrade(db, 2, 3);

      expect(await _indexNames(db, 'gifts'), contains('idx_gifts_person_date'));

      await db.close();
      _deletePathQuietly(path);
    });
  });

  group('스키마 수렴성', () {
    test('onCreate로 만든 v3와 onUpgrade로 올라온 v3의 스키마가 동일하다', () async {
      final createdPath = _tempDbPath('converge_created.db');
      final upgradedPath = _tempDbPath('converge_upgraded.db');

      // onCreate 경로
      final createdDb = await openDatabase(
        createdPath,
        version: 3,
        onCreate: AppDatabase.onCreate,
      );

      // onUpgrade 경로: v2로 만든 뒤 v3로 업그레이드
      final upgradedDb = await _createV2Database(upgradedPath);
      await AppDatabase.onUpgrade(upgradedDb, 2, 3);

      for (final table in ['persons', 'gifts']) {
        final createdInfo = await createdDb.rawQuery(
          "PRAGMA table_info('$table')",
        );
        final upgradedInfo = await upgradedDb.rawQuery(
          "PRAGMA table_info('$table')",
        );

        // 컬럼명 집합 비교(순서 무관하게 동일 컬럼 구성인지)
        final createdCols = createdInfo.map((c) => c['name']).toSet();
        final upgradedCols = upgradedInfo.map((c) => c['name']).toSet();
        expect(
          upgradedCols,
          equals(createdCols),
          reason: '$table 테이블의 컬럼 구성이 onCreate/onUpgrade 경로에서 달라짐',
        );

        final createdIndexes = (await _indexNames(createdDb, table)).toSet();
        final upgradedIndexes =
            (await _indexNames(upgradedDb, table)).toSet();
        expect(
          upgradedIndexes,
          equals(createdIndexes),
          reason: '$table 테이블의 인덱스 구성이 onCreate/onUpgrade 경로에서 달라짐',
        );
      }

      await createdDb.close();
      await upgradedDb.close();
      _deletePathQuietly(createdPath);
      _deletePathQuietly(upgradedPath);
    });
  });
}
