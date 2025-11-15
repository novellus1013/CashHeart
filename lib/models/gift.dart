import 'package:cash_heart/models/gift_types.dart';

class Gift {
  int? id;
  int personId;
  int amount;
  String direction; //enum -> String 저장
  String category; //enum -> String 저장
  int date;
  String memo;
  int createdAt;

  //String으로 변환된 direction을 가져와 Enum으로 변경해준는 getter
  GiftDirection get directionEnum {
    // ~.values.byName(String) -> enum type이 제공해주는 메서드
    return GiftDirection.values.byName(direction);
  }

  GiftCategory get categoryEnum {
    return GiftCategory.values.byName(category);
  }

  Gift({
    this.id,
    required this.personId,
    required this.amount,
    required this.direction,
    required this.category,
    required this.date,
    required this.memo,
    required this.createdAt,
  });

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      personId: map['person_id'],
      amount: map['amount'],
      direction: map['direction'],
      category: map['category'],
      date: map['date'],
      memo: map['memo'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'amount': amount,
      'direction': direction,
      'category': category,
      'date': date,
      'memo': memo,
      'created_at': createdAt,
    };
  }
}
