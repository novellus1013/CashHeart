import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/services/app_database.dart';
import 'package:sqflite/sqflite.dart';

class GiftRepository {
  GiftRepository._internal();
  static final GiftRepository instance = GiftRepository._internal();

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insertGift(Gift gift) async {
    final db = await _db;
    return await db.insert(
      'gifts',
      gift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGift(Gift gift) async {
    final db = await _db;
    if (gift.id == null) {
      throw ArgumentError('updateGift: gift.id가 null 입니다.');
    }
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<int> deleteGift(int id) async {
    final db = await _db;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Gift>> getGiftsByPersonId(int personId) async {
    final db = await _db;
    final result = await db.query(
      'gifts',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'date DESC',
    );

    return result.map((row) => Gift.fromMap(row)).toList();
  }

  // Future<List<Gift>> getAllGifts() async {
  //   final db = await _db;
  //   final result = await db.query(
  //     'gifts',
  //     orderBy: 'date DESC',
  //   );

  //   return result.map((row) => Gift.fromMap(row)).toList();
  // }
}
