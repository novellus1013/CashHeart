import 'package:cash_heart/services/backup_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  //private 생성자 - 외부에서 AppDatabase의 instance를 직접 만들 수 없게 막는다.
  AppDatabase._internal();

  //AppDatabse의 전역 instance - 앱 전체에서 이 instance를 통해서만 db에 접근
  static final AppDatabase instance = AppDatabase._internal();

  static const _dbName = 'cash_heart.db';
  static const _dbVersion = 3;

  Database? _database;

  // 이번 앱 실행에서 DB가 열리며 스키마 업그레이드가 실제로 일어났는지 여부
  // (Sprint 5: MigrationScreen 노출 판단에 사용). 신규 설치나 동일 버전
  // 재실행이면 false로 유지된다.
  bool _didMigrateOnLastOpen = false;
  bool get didMigrateOnLastOpen => _didMigrateOnLastOpen;

  //처음 _database는 null -> 처음 getter가 호출될 때 _initDatabase() 생성 -> 이후에는 동일한 인스턴스 재사용
  //Appdatabse.instance.database 형태로 사용
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dpPath = await getDatabasesPath();

    // OS별 디렉토리 경로와 DB 파일 이름을 합친다.
    // ex) `/data/user/.../databases/cash_heart.db`
    final path = join(dpPath, _dbName);

    _didMigrateOnLastOpen = await maybeBackupBeforeUpgrade(
      path: path,
      targetVersion: _dbVersion,
    );

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  // 실제 onUpgrade가 트리거되기 전에, 기존 DB 파일이 있고 그 버전이
  // targetVersion보다 낮을 때만(= 곧 업그레이드가 일어날 때만) CSV 백업을 남긴다.
  // 신규 설치(파일 없음)는 보존할 데이터가 없으므로 건너뛴다.
  //
  // 백업은 onCreate/onUpgrade를 트리거하지 않는 openReadOnlyDatabase로 현재
  // 버전을 확인한 뒤, 데이터 조회를 위해 별도로 다시 열어 BackupService에 넘긴다.
  // 백업 실패는 절대 마이그레이션 진행을 막지 않는다(BackupService가 예외를
  // 삼키고 null을 반환) — 이 메서드 자체(버전 확인 등 사전 점검)가 실패하는
  // 경우도 동일하게 마이그레이션을 막아선 안 되므로 전체를 try/catch로 감싼다.
  //
  // 반환값(Sprint 5 추가): 업그레이드가 실제로 일어날 예정이었는지(=백업을
  // 시도했는지) 여부. 백업 자체의 성공/실패와는 별개 — 백업이 실패해도
  // 업그레이드 대상이었다는 사실은 true로 보고한다(MigrationScreen 노출 여부는
  // 백업 성공 여부와 무관해야 하므로).
  //
  // @visibleForTesting: 실제 디바이스 경로 없이 임시 파일 경로로 테스트에서
  // 동일 로직을 재사용하기 위해 static으로 노출.
  @visibleForTesting
  static Future<bool> maybeBackupBeforeUpgrade({
    required String path,
    required int targetVersion,
  }) async {
    Database? readOnlyDb;
    try {
      final exists = await databaseExists(path);
      if (!exists) return false; // 신규 설치: 보존할 기존 데이터 없음

      readOnlyDb = await openReadOnlyDatabase(path);
      final currentVersion = await readOnlyDb.getVersion();

      if (currentVersion >= targetVersion) {
        return false; // 업그레이드가 일어나지 않음 (동일 버전이거나 다운그레이드)
      }

      await BackupService.instance.backupBeforeMigration(
        db: readOnlyDb,
        oldVersion: currentVersion,
        newVersion: targetVersion,
      );
      return true;
    } catch (e, st) {
      debugPrint('AppDatabase.maybeBackupBeforeUpgrade error: $e');
      await Sentry.captureException(e, stackTrace: st);
      return false;
    } finally {
      await readOnlyDb?.close();
    }
  }

  // DB가 처음 생성될 때 한 번만 호출되는 콜백. -> 테이블 생성
  // @visibleForTesting: sqflite_common_ffi 기반 임시 파일 마이그레이션 테스트에서 동일 로직을 재사용하기 위해 static으로 노출.
  @visibleForTesting
  static Future<void> onCreate(Database db, int version) async {
    // person 테이블
    await db.execute('''
      CREATE TABLE persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        note TEXT,
        category TEXT,
        created_at INTEGER NOT NULL
      );
    ''');

    // gift 테이블
    //FOREIGN KEY(person_id)... - fk person_id와 persons table 사이의 관계
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

    // person_id + date 복합 인덱스 - 관계별 균형 집계(person_id로 조회 후 date 정렬/MAX)를 커버
    // getGiftsListByPersonId, getLastGiftByPerson, getTotalsByPerson 등에서 사용
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_gifts_person_date ON gifts(person_id, date);
    ''');
  }

  // DB 버전이 올라갈 때 호출되는 콜백.
  // 차후 컬럼 추가 / 테이블 추가 / 데이터 마이그레이션 등을 처리
  // @visibleForTesting: sqflite_common_ffi 기반 임시 파일 마이그레이션 테스트에서 동일 로직을 재사용하기 위해 static으로 노출.
  @visibleForTesting
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // 차후 버전이 변경되면 컬럼 추가 / 변경할 경우 사용
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE persons ADD COLUMN category TEXT;');
    }
    if (oldVersion < 3) {
      // person_id + date 복합 인덱스 추가 (균형 집계 쿼리 커버, onCreate와 동일)
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_gifts_person_date ON gifts(person_id, date);
      ''');
    }
  }
}
