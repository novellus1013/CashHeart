class TransactionModel {
  final String id;
  final String userId;
  final String contactId;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String? location;
  final String? memo;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.contactId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.location,
    this.memo,
    required this.createdAt,
  });

  // JSON 데이터를 TransactionModel 객체로 변환하는 팩토리 메서드
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      contactId: json['contact_id'],
      type: json['type'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      location: json['location'],
      memo: json['memo'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // TransactionModel 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_id': contactId,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'location': location,
      'memo': memo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
