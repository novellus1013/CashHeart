class ContactModel {
  final String id;
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final DateTime createdAt;

  ContactModel({
    required this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  // JSON 데이터를 ContactModel 객체로 변환하는 팩토리 메서드
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // ContactModel 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
