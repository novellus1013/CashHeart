import 'package:cash_heart/models/gift_types.dart';

class Gift {
  int? id;
  int personId;
  int amount;

  GiftDirection direction; //enum -> String 저장 -> int로 변경 -> enum으로
  GiftCategory category; //enum -> String 저장

  int date;
  String? note;
  int? createdAt;

  Gift({
    this.id,
    required this.personId,
    required this.amount,
    required this.direction,
    required this.category,
    required this.date,
    this.note,
    this.createdAt,
  });

  int get signedAmount => amount * direction.dbValue;

  String get directionLabel => direction.label;
  String get categoryLabel => category.label;

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      personId: map['person_id'],
      amount: map['amount'],
      direction: GiftDirectionDb.fromDb(map['direction']),
      category: GiftCategoryDb.fromDb(map['category']),
      date: map['date'],
      note: map['note'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'amount': amount,
      'direction': direction.dbValue,
      'category': category.dbValue,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }
}
