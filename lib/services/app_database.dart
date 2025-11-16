import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  //private 생성자 - 외부에서 AppDatabase의 instance를 직접 만들 수 없게 막는다.
  AppDatabase._internal();

  //AppDatabse의 전역 instance - 앱 전체에서 이 instance를 통해서만 db에 접근
  static final AppDatabase instance = AppDatabase._internal();

  static const _dbName = 'cash_heart.db';
  static const _dbVersion = 1;

  Database? _database;

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

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      // onUpgrade: _onUpgarde,
    );
  }

  // DB가 처음 생성될 때 한 번만 호출되는 콜백. -> 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    // person 테이블
    await db.execute('''
      CREATE TABLE persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        note TEXT NOT NULL,
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
        direction TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        memo TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (person_id) REFERENCES persons (id) 
      );
    ''');
  }

  // DB 버전이 올라갈 때 호출되는 콜백.
  // 차후 컬럼 추가 / 테이블 추가 / 데이터 마이그레이션 등을 처리
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 차후 버전이 변경되면 컬럼 추가 / 변경할 경우 사용
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ...');
    }
  }
}
