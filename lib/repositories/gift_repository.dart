import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_totals.dart';
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

  //getTotalsByPerosn을 총액이 아닌 준 돈, 받은 돈 나눠서 얻어올 수 있도록 로직 변경.
  Future<Map<int, GiftTotals>> getTotalsByPerson() async {
    try {
      final db = await _db;

      final result = await db.rawQuery('''
      SELECT 
        person_id, 
        SUM(CASE WHEN direction = 1 THEN amount ELSE 0 END) AS total_received,
        SUM(CASE WHEN direction = -1 THEN amount ELSE 0 END) AS total_given
      FROM gifts
      GROUP BY person_id
    ''');

      final Map<int, GiftTotals> totals = {};

      for (final raw in result) {
        final personId = raw['person_id'] as int;
        final totalsReceived = raw['total_received'];
        final totalsGiven = raw['total_given'];

        final totalRecived =
            totalsReceived == null ? 0 : (totalsReceived as num).toInt();
        final totalGiven =
            totalsGiven == null ? 0 : (totalsGiven as num).toInt();
        totals[personId] = GiftTotals(
          personId: personId,
          totalGivenAmount: totalGiven,
          totalReceivedAmount: totalRecived,
        );
      }

      return totals;
    } catch (e, st) {
      debugPrint('getTotalsByPerson error: $e');
      await Sentry.captureException(e, stackTrace: st);
      rethrow;
    }
  }
}
