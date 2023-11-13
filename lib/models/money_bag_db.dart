//id, name, phone, memo, total

class MoneyBag {
  int id;
  String name;
  int total;
  String phone;
  String memo;

  MoneyBag({
    required this.id,
    required this.name,
    this.total = 0,
    this.phone = '',
    this.memo = '',
  });
}
