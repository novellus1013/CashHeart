import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class GiftRepository {
  GiftRepository._internal();
  static final GiftRepository instance = GiftRepository._internal();

  Future<Database> get _db async => AppDatabase.instance.database;

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

  //모든 Person의 total 합계를 불러오는 로직 - gifts table에 접근하기 때문에
  //person_repository가 아닌 여기에 작성
  Future<Map<int, int>> getTotalsByPerson() async {
    try {
      final db = await _db;

      final result = await db.rawQuery('''
      SELECT person_id, SUM(amount * direction) AS total
      FROM gifts
      GROUP BY person_id
    ''');

      final Map<int, int> totals = {};

      for (final raw in result) {
        final personId = raw['person_id'] as int;
        final rawTotal = raw['total'];
        final total = rawTotal == null ? 0 : (rawTotal as num).toInt();
        totals[personId] = total;
      }

      return totals;
    } catch (e, st) {
      debugPrint('getTotalsByPerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }
}
