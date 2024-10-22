class UserModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;

  UserModel(
    this.id,
    this.email,
    this.username,
    this.createdAt,
  );

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        username = json['username'],
        createdAt = DateTime.parse(json['createdAt']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
