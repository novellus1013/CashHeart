import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class GiftRepository {
  GiftRepository._internal() : _testDatabase = null;
  static final GiftRepository instance = GiftRepository._internal();

  /// 테스트 전용 — 실 기기 경로(`AppDatabase.instance`) 대신 주입된 [Database]를 쓴다.
  /// 프로덕션 코드는 항상 싱글턴 `GiftRepository.instance`를 사용해야 한다.
  @visibleForTesting
  GiftRepository.forTesting(Database database) : _testDatabase = database;

  final Database? _testDatabase;

  Future<Database> get _db async => _testDatabase ?? AppDatabase.instance.database;

  Future<int> insertGift(Gift gift) async {
    try {
      final db = await _db;

      final data = gift.toMap();

      data['created_at'] = DateTime.now().millisecondsSinceEpoch;

      return await db.insert(
        'gifts',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, st) {
      debugPrint('insertGift error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> updateGift(Gift gift) async {
    try {
      final db = await _db;
      if (gift.id == null) {
        throw ArgumentError('updateGift: gift.id가 null 입니다.');
      }

      final data = gift.toMap();

      data.remove('created_at');

      return await db.update(
        'gifts',
        data,
        where: 'id = ?',
        whereArgs: [gift.id],
      );
    } catch (e, st) {
      debugPrint('updateGift error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> deleteGift(int id) async {
    try {
      final db = await _db;
      return await db.delete(
        'gifts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      debugPrint('deleteGift error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// 특정 person의 모든 gift를 삭제
  Future<int> deleteGiftsByPersonId(int personId) async {
    try {
      final db = await _db;
      return await db.delete(
        'gifts',
        where: 'person_id = ?',
        whereArgs: [personId],
      );
    } catch (e, st) {
      debugPrint('deleteGiftsByPersonId error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<Gift>> getGiftsListByPersonId(int personId) async {
    try {
      final db = await _db;
      final result = await db.query(
        'gifts',
        where: 'person_id = ?',
        whereArgs: [personId],
        orderBy: 'date DESC',
      );

      return result.map((row) => Gift.fromMap(row)).toList();
    } catch (e, st) {
      debugPrint('getGiftsListByPersonId error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// person별 [RelationshipStats]를 한 번의 GROUP BY로 집계한다.
  /// 과거 `getTotalsByPerson`+`getLastGiftByPerson`을 대체 — Sprint 1의
  /// `idx_gifts_person_date` 인덱스가 이 집계를 커버해 스키마 변경은 필요 없다.
  Future<Map<int, RelationshipStats>> getStatsByPerson() async {
    try {
      final db = await _db;

      final result = await db.rawQuery('''
      SELECT
        person_id,
        SUM(CASE WHEN direction = 1 THEN amount ELSE 0 END) AS received,
        SUM(CASE WHEN direction = -1 THEN amount ELSE 0 END) AS given,
        COUNT(*) AS count,
        MIN(date) AS first_date,
        MAX(date) AS last_date
      FROM gifts
      GROUP BY person_id
    ''');

      final Map<int, RelationshipStats> stats = {};
      for (final row in result) {
        final personId = row['person_id'] as int;
        final firstDateMs = row['first_date'] as int?;
        final lastDateMs = row['last_date'] as int?;

        stats[personId] = RelationshipStats(
          received: (row['received'] as num?)?.toInt() ?? 0,
          given: (row['given'] as num?)?.toInt() ?? 0,
          count: (row['count'] as num?)?.toInt() ?? 0,
          firstDate: firstDateMs == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(firstDateMs),
          lastDate: lastDateMs == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastDateMs),
        );
      }

      return stats;
    } catch (e, st) {
      debugPrint('getStatsByPerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// person 1명의 총액(given+received) 순위 — 카드 공유 "영혼의 동반자" 케이스의
  /// 상위권 판정(share_card_case.dart)에 쓰인다. rank는 총액 내림차순 1-indexed,
  /// totalPersonsWithRecords는 거래 기록이 1건 이상 있는 person 수.
  Future<({int rank, int totalPersonsWithRecords})> getTotalRank(
      int personId) async {
    try {
      final db = await _db;

      final result = await db.rawQuery('''
      WITH totals AS (
        SELECT person_id, SUM(amount) AS total FROM gifts GROUP BY person_id
      )
      SELECT
        (SELECT COUNT(*) FROM totals) AS total_persons,
        (SELECT COUNT(*) FROM totals t2 WHERE t2.total > t1.total) + 1 AS rank
      FROM totals t1 WHERE t1.person_id = ?
    ''', [personId]);

      if (result.isEmpty) {
        final countResult = await db.rawQuery(
            'SELECT COUNT(DISTINCT person_id) AS c FROM gifts');
        final totalPersons = (countResult.first['c'] as num?)?.toInt() ?? 0;
        return (rank: 0, totalPersonsWithRecords: totalPersons);
      }

      final row = result.first;
      return (
        rank: (row['rank'] as num?)?.toInt() ?? 0,
        totalPersonsWithRecords: (row['total_persons'] as num?)?.toInt() ?? 0,
      );
    } catch (e, st) {
      debugPrint('getTotalRank error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// Home hero 카드의 기간 필터(최근 1/3/6개월·1년·전체)용 준/받은 마음 합계.
  /// [sinceMs]가 null이면 전체 기간(필터 없음).
  Future<({int given, int received})> getTotalsSince(int? sinceMs) async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
        SELECT
          SUM(CASE WHEN direction = -1 THEN amount ELSE 0 END) AS given,
          SUM(CASE WHEN direction = 1 THEN amount ELSE 0 END) AS received
        FROM gifts
        ${sinceMs == null ? '' : 'WHERE date >= ?'}
      ''', sinceMs == null ? null : [sinceMs]);

      final given = (result.first['given'] as num?)?.toInt() ?? 0;
      final received = (result.first['received'] as num?)?.toInt() ?? 0;
      return (given: given, received: received);
    } catch (e, st) {
      debugPrint('getTotalsSince error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> getTotalAmount() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
      SELECT SUM(amount * direction) AS total
      FROM gifts
    ''');

      final rawTotal = result.first['total'];
      return rawTotal == null ? 0 : (rawTotal as num).toInt();
    } catch (e, st) {
      debugPrint('getTotalAmount error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> getTotalGiven() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM gifts
      WHERE direction = -1
    ''');

      final rawTotal = result.first['total'];
      return rawTotal == null ? 0 : (rawTotal as num).toInt();
    } catch (e, st) {
      debugPrint('getTotalGiven error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  Future<int> getTotalReceived() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM gifts
      WHERE direction = 1
    ''');

      final rawTotal = result.first['total'];
      return rawTotal == null ? 0 : (rawTotal as num).toInt();
    } catch (e, st) {
      debugPrint('getTotalReceived error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// 월별 given/received 합계를 반환합니다.
  /// 반환값: Map where key is 'yyyy-MM' format
  Future<Map<String, ({int given, int received})>> getMonthlyTotals() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
        SELECT
          strftime('%Y-%m', date / 1000, 'unixepoch') AS month,
          SUM(CASE WHEN direction = -1 THEN amount ELSE 0 END) AS total_given,
          SUM(CASE WHEN direction = 1 THEN amount ELSE 0 END) AS total_received
        FROM gifts
        GROUP BY month
        ORDER BY month DESC
        LIMIT 12
      ''');

      final Map<String, ({int given, int received})> monthlyTotals = {};
      for (final row in result) {
        final month = row['month'] as String;
        final given = (row['total_given'] as num?)?.toInt() ?? 0;
        final received = (row['total_received'] as num?)?.toInt() ?? 0;
        monthlyTotals[month] = (given: given, received: received);
      }

      return monthlyTotals;
    } catch (e, st) {
      debugPrint('getMonthlyTotals error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }

  /// 모든 Gift 목록을 반환합니다.
  Future<List<Gift>> getAllGifts() async {
    try {
      final db = await _db;
      final result = await db.query(
        'gifts',
        orderBy: 'date DESC',
      );
      return result.map((row) => Gift.fromMap(row)).toList();
    } catch (e, st) {
      debugPrint('getAllGifts error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }
}
