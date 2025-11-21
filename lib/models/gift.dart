import 'package:cash_heart/models/gift_types.dart';

class Gift {
  int? id;
  int personId;
  int amount;

  GiftDirection direction; //model에서는 enum. db에는 int로 저장.
  GiftCategory category; //model에서는 enum. db에는 String으로 저장.

  int date;
  String note;
  int? createdAt;

  Gift({
    this.id,
    required this.personId,
    required this.amount,
    required this.direction,
    required this.category,
    required this.date,
    required this.note,
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
