import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

/// persons 테이블에 대한 CRUD(생성/조회/수정/삭제)를 담당하는 계층.
/// ViewModel/UI를 오직 이 Repository의 메서드만 사용하도록 만들면 차후 DB를 변경해도 ViewModel 코드 수정을 최소화 할 수 있다.
class PersonRepository {
  //싱글턴인 이유 : 여러개의 인스턴스를 만들 필요 없는 일종의 함수 모음 이기 때문에
  PersonRepository._internal() : _testDatabase = null;
  static final PersonRepository instance = PersonRepository._internal();

  /// 테스트 전용 — 실 기기 경로(`AppDatabase.instance`) 대신 주입된 [Database]를 쓴다.
  /// 프로덕션 코드는 항상 싱글턴 `PersonRepository.instance`를 사용해야 한다.
  @visibleForTesting
  PersonRepository.forTesting(Database database) : _testDatabase = database;

  final Database? _testDatabase;

  // getter에서 await AppDatabase.instance.database를 안쓰고 Future<Database>를 반환받는 이유
  // 메서드들에서 어차피 Future를 사용하기 때문에
  Future<Database> get _db async {
    return _testDatabase ?? AppDatabase.instance.database;
  }

  // db.insert는 삽입된 row의 id를 반환
  Future<int> insertPerson(Person person) async {
    try {
      final db = await _db;

      final data = person.toMap();

      data['created_at'] = DateTime.now().millisecondsSinceEpoch;

      return await db.insert(
        'persons',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace, // !definition 살펴보기
      );
    } catch (e, st) {
      debugPrint('insertPerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> updatePerson(Person person) async {
    try {
      final db = await _db;
      if (person.id == null) {
        throw ArgumentError('updatePerson: person.id가 null 입니다.');
      }

      final data = person.toMap();

      data.remove('created_at');

      return await db.update(
        'persons',
        data,
        where: 'id = ?', //WHERE id = ?
        whereArgs: [person.id], // ? 에 들어갈 값
      );
    } catch (e, st) {
      debugPrint('updatePerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> deletePerson(int id) async {
    try {
      final db = await _db;

      // 먼저 해당 person의 모든 gift를 삭제
      await GiftRepository.instance.deleteGiftsByPersonId(id);

      // 그 다음 person 삭제
      return await db.delete(
        'persons',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      debugPrint('deletePerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<Person?> getPersonById(int id) async {
    try {
      final db = await _db;
      final result = await db.query(
        'persons',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return Person.fromMap(result.first);
    } catch (e, st) {
      debugPrint('getPersonById error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<Person>> getAllPersons() async {
    try {
      final db = await _db;
      final result = await db.query(
        'persons',
        orderBy: 'created_at DESC', // 생성 시간 내림 차순
      );
      //
      return result.map((row) => Person.fromMap(row)).toList();
    } catch (e, st) {
      debugPrint('getAllPersons error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// DB가 열려 있음을 보장하고, 이번 앱 실행에서 그 오픈 과정에 스키마
  /// 업그레이드가 실제로 일어났는지 반환한다(Sprint 5: MigrationScreen 노출 판단용).
  Future<bool> ensureOpenedAndCheckMigration() async {
    await _db;
    return AppDatabase.instance.didMigrateOnLastOpen;
  }
}
