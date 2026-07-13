// DB 마이그레이션 직전 CSV 백업(BackupService) + AppDatabase 배선 검증 테스트.
//
// BackupService는 path_provider의 getApplicationDocumentsDirectory()로 저장
// 위치를 정하므로, 순수 `flutter test` (VM) 환경에서도 플랫폼 채널 없이 동작
// 하도록 PathProviderPlatform.instance를 임시 디렉토리를 가리키는 fake로
// 교체해 실제 백업 디렉토리/파일 생성까지 검증한다.
//
// sqflite 네이티브 트랜잭션 롤백 보장(onUpgrade 실패 시 DB가 업그레이드 이전
// 상태로 남는지)도 이 파일에서 함께 증명한다 — 커스텀 롤백 로직이 필요 없다는
// 근거가 되는 테스트다.
//
// 주의: 실 기기(App Store/Play Store 배포 중, v1.1 사용자)의 데이터 보존 검증은
// Sprint 1 "사람 게이트" 항목이다. 이 자동 테스트는 스키마/백업 로직의 회귀를
// 막을 뿐, 실 기기 업그레이드 시 데이터 보존을 대체 증명하지 않는다.

import 'dart:io';

import 'package:cash_heart/services/app_database.dart';
import 'package:cash_heart/services/backup_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 테스트 동안 getApplicationDocumentsDirectory()가 격리된 임시 디렉토리를
/// 가리키도록 하는 fake. 실제 디바이스 문서 디렉토리를 건드리지 않는다.
class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProviderPlatform(this.documentsPath);

  final String documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}

/// 재파싱 검증용 CSV 디코더. amount/direction 등 숫자 컬럼을 원본 타입(int)
/// 그대로 비교할 수 있도록 dynamicTyping을 켠다(BackupService 자체는 항상
/// 문자열로 인코딩하며, 이 디코더는 테스트 검증 편의를 위한 것일 뿐이다).
final _dynamicCsv = Csv(dynamicTyping: true);

/// 테스트별로 격리된 임시 디렉토리 경로를 만든다.
Directory _tempDir(String prefix) {
  return Directory.systemTemp.createTempSync(prefix);
}

void _deleteDirQuietly(Directory dir) {
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

/// v2 시점의 실제 스키마(persons.category 컬럼 포함, 인덱스 없음)를 재현.
/// (app_database_migration_test.dart의 헬퍼와 동일한 스키마를 이 파일에서도
/// 독립적으로 정의해 파일 간 의존을 만들지 않는다.)
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory fakeDocumentsDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    fakeDocumentsDir = _tempDir('cash_heart_fake_documents_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      fakeDocumentsDir.path,
    );
  });

  tearDown(() {
    _deleteDirQuietly(fakeDocumentsDir);
  });

  group('BackupService.backupBeforeMigration', () {
    test(
      'persons/gifts를 CSV로 내보내고, 재파싱 시 행 수·값이 원본과 일치한다 (쉼표/따옴표/개행 포함)',
      () async {
        final dbDir = _tempDir('cash_heart_backup_db_');
        final dbPath = p.join(dbDir.path, 'v2_fixture.db');
        final db = await _createV2Database(dbPath);

        final now = DateTime.now().millisecondsSinceEpoch;
        final personId = await db.insert('persons', {
          'name': '홍길동',
          'note': '대학 동기',
          'category': '친구',
          'created_at': now,
        });

        // CSV 이스케이핑 검증용: 쉼표, 따옴표, 개행이 섞인 note.
        const trickyNote = '축하金, "정말" 축하해\n다음에 또 봐요';

        await db.insert('gifts', {
          'person_id': personId,
          'amount': 50000,
          'direction': 1,
          'category': '결혼',
          'date': now,
          'note': trickyNote,
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

        final backupDir = await BackupService.instance.backupBeforeMigration(
          db: db,
          oldVersion: 2,
          newVersion: 3,
        );

        expect(backupDir, isNotNull);
        expect(backupDir!.existsSync(), isTrue);

        final personsCsvFile = File(p.join(backupDir.path, 'persons.csv'));
        final giftsCsvFile = File(p.join(backupDir.path, 'gifts.csv'));
        expect(personsCsvFile.existsSync(), isTrue);
        expect(giftsCsvFile.existsSync(), isTrue);

        // persons.csv 재파싱 검증
        final personsRows = _dynamicCsv.decode(await personsCsvFile.readAsString());
        final personsHeader =
            personsRows.first.map((e) => e.toString()).toList();
        expect(
          personsHeader,
          containsAll(['id', 'name', 'note', 'category', 'created_at']),
        );
        expect(personsRows.length, 2); // header + 1 row
        final nameIdx = personsHeader.indexOf('name');
        final categoryIdx = personsHeader.indexOf('category');
        expect(personsRows[1][nameIdx], '홍길동');
        expect(personsRows[1][categoryIdx], '친구');

        // gifts.csv 재파싱 검증
        final giftsRows = _dynamicCsv.decode(await giftsCsvFile.readAsString());
        final giftsHeader = giftsRows.first.map((e) => e.toString()).toList();
        expect(giftsRows.length, 3); // header + 2 rows
        final amountIdx = giftsHeader.indexOf('amount');
        final noteIdx = giftsHeader.indexOf('note');
        final directionIdx = giftsHeader.indexOf('direction');

        final amounts = giftsRows.skip(1).map((r) => r[amountIdx]).toSet();
        expect(amounts, {50000, 30000});

        // 쉼표/따옴표/개행이 온전히 보존되는지 확인
        final notes = giftsRows.skip(1).map((r) => r[noteIdx]).toList();
        expect(notes, contains(trickyNote));
        expect(notes, contains(''));

        final directions =
            giftsRows.skip(1).map((r) => r[directionIdx]).toSet();
        expect(directions, {1, -1});

        await db.close();
        _deleteDirQuietly(dbDir);
        _deleteDirQuietly(backupDir);
      },
    );

    test('디렉토리 이름이 <oldVersion>_to_<newVersion>_<epochMs> 규약을 따른다', () async {
      final dbDir = _tempDir('cash_heart_backup_naming_');
      final dbPath = p.join(dbDir.path, 'v2_fixture.db');
      final db = await _createV2Database(dbPath);

      final backupDir = await BackupService.instance.backupBeforeMigration(
        db: db,
        oldVersion: 2,
        newVersion: 3,
      );

      expect(backupDir, isNotNull);
      final dirName = p.basename(backupDir!.path);
      expect(dirName, matches(RegExp(r'^2_to_3_\d+$')));
      expect(p.basename(p.dirname(backupDir.path)), 'backups');

      await db.close();
      _deleteDirQuietly(dbDir);
      _deleteDirQuietly(backupDir.parent);
    });
  });

  group('AppDatabase.maybeBackupBeforeUpgrade', () {
    test('기존 DB 파일이 있고 버전이 낮으면 백업 디렉토리가 생성된다', () async {
      final dbDir = _tempDir('cash_heart_migration_trigger_');
      final dbPath = p.join(dbDir.path, 'existing.db');
      final db = await _createV2Database(dbPath);
      await db.insert('persons', {
        'name': '김철수',
        'note': null,
        'category': '가족',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      await db.close();

      final migrated = await AppDatabase.maybeBackupBeforeUpgrade(
        path: dbPath,
        targetVersion: 3,
      );
      // Sprint 5: 업그레이드가 실제로 일어날 예정이었음을 true로 보고해야
      // MainShellScreen이 MigrationScreen을 노출할 수 있다.
      expect(migrated, isTrue);

      // fake path_provider가 가리키는 documents 디렉토리 하위에 실제로
      // backups/2_to_3_<epochMs>/persons.csv, gifts.csv가 생성되어야 한다.
      final backupsRoot = Directory(p.join(fakeDocumentsDir.path, 'backups'));
      expect(backupsRoot.existsSync(), isTrue);

      final migrationDirs = backupsRoot
          .listSync()
          .whereType<Directory>()
          .where((d) => p.basename(d.path).startsWith('2_to_3_'))
          .toList();
      expect(migrationDirs, hasLength(1));

      final personsCsv = File(p.join(migrationDirs.first.path, 'persons.csv'));
      final giftsCsv = File(p.join(migrationDirs.first.path, 'gifts.csv'));
      expect(personsCsv.existsSync(), isTrue);
      expect(giftsCsv.existsSync(), isTrue);

      final personsRows = _dynamicCsv.decode(await personsCsv.readAsString());
      expect(personsRows.length, 2); // header + 1 row
      final header = personsRows.first.map((e) => e.toString()).toList();
      expect(personsRows[1][header.indexOf('name')], '김철수');

      _deleteDirQuietly(dbDir);
    });

    test('DB 파일이 없으면(신규 설치) 백업이 트리거되지 않는다', () async {
      final dbDir = _tempDir('cash_heart_fresh_install_');
      final dbPath = p.join(dbDir.path, 'does_not_exist.db');

      // 예외 없이 즉시 반환되어야 한다 (databaseExists == false 분기).
      final migrated = await AppDatabase.maybeBackupBeforeUpgrade(
        path: dbPath,
        targetVersion: 3,
      );
      expect(migrated, isFalse);

      // 백업 대상 파일 자체가 없었으므로 새로 생성된 것도 없어야 한다.
      expect(File(dbPath).existsSync(), isFalse);
      final backupsRoot = Directory(p.join(fakeDocumentsDir.path, 'backups'));
      expect(backupsRoot.existsSync(), isFalse);

      _deleteDirQuietly(dbDir);
    });

    test('버전이 이미 targetVersion 이상이면 백업을 건너뛴다', () async {
      final dbDir = _tempDir('cash_heart_already_current_');
      final dbPath = p.join(dbDir.path, 'already_v3.db');

      final db = await openDatabase(
        dbPath,
        version: 3,
        onCreate: AppDatabase.onCreate,
      );
      await db.close();

      // 예외 없이 완료되어야 한다 (currentVersion(3) >= targetVersion(3)).
      final migrated = await AppDatabase.maybeBackupBeforeUpgrade(
        path: dbPath,
        targetVersion: 3,
      );
      expect(migrated, isFalse);

      final backupsRoot = Directory(p.join(fakeDocumentsDir.path, 'backups'));
      expect(backupsRoot.existsSync(), isFalse);

      _deleteDirQuietly(dbDir);
    });
  });

  group('sqflite 네이티브 트랜잭션 롤백 보장', () {
    test(
      'onUpgrade 도중 예외가 발생하면 스키마 변경이 롤백되고 DB는 이전 버전 상태로 남는다',
      () async {
        final dbDir = _tempDir('cash_heart_rollback_proof_');
        final dbPath = p.join(dbDir.path, 'rollback.db');

        // 1. v2 스키마로 DB 생성 + 데이터 삽입
        var db = await _createV2Database(dbPath);
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.insert('persons', {
          'name': '이영희',
          'note': '고등학교 동창',
          'category': '친구',
          'created_at': now,
        });
        await db.close();

        // 2. 유효한 statement를 실행한 뒤 강제로 예외를 던지는 onUpgrade로 v3 open 시도
        Object? caughtError;
        try {
          db = await openDatabase(
            dbPath,
            version: 3,
            onCreate: AppDatabase.onCreate,
            onUpgrade: (db, oldVersion, newVersion) async {
              // 실제로 스키마를 변경하는 유효한 statement (커밋되면 안 됨)
              await db.execute(
                'ALTER TABLE persons ADD COLUMN should_not_persist TEXT;',
              );
              // 트랜잭션 도중 강제 예외 발생
              throw Exception('강제 실패 - 롤백 검증용');
            },
          );
        } catch (e) {
          caughtError = e;
        }

        expect(caughtError, isNotNull);

        // 3. DB를 다시 열어(onUpgrade/onCreate 없이, 버전 지정 없이) 검증
        final reopened = await openDatabase(dbPath);

        // 버전이 여전히 2 (업그레이드 이전) 여야 한다.
        expect(await reopened.getVersion(), 2);

        // 실패한 onUpgrade 안에서 추가하려던 컬럼이 존재하지 않아야 한다.
        final columns = (await reopened.rawQuery(
          "PRAGMA table_info('persons')",
        )).map((c) => c['name']).toSet();
        expect(columns, isNot(contains('should_not_persist')));

        // 기존 데이터는 그대로 보존되어야 한다.
        final persons = await reopened.query('persons');
        expect(persons, hasLength(1));
        expect(persons.first['name'], '이영희');

        await reopened.close();
        _deleteDirQuietly(dbDir);
      },
    );
  });
}
