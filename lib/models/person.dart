class Person {
  int? id; //id 가 auto increment 인 경우 db가 자동 생성해주기 때문에 id가 null일수 있음
  String name;
  String? note;
  String? category;
  int? createdAt;

  Person({
    this.id,
    required this.name,
    this.note,
    this.category,
    this.createdAt,
  });

  //Person 객체를 반환
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
        id: map['id'],
        name: map['name'],
        note: map['note'],
        category: map['category'],
        createdAt: map['created_at']);
  }

  //sqflite가 db row 형태로 변환하기 쉽게, Person 객체를 key - value 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'category': category,
      'created_at': createdAt,
    };
  }
}
