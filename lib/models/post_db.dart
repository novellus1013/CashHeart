//id, name, total, heart(give, take), events, price, date, memo,
enum Heart { give, take }

enum Events { wedding, funeral, birthday, etc }

class Post {
  int id;
  String name;
  double total;
  Heart heart;
  Events events;
  int price;
  DateTime date;
  String memo;

  Post({
    required this.id,
    required this.name,
    required this.heart,
    required this.events,
    required this.price,
    required this.date,
    this.total = 0,
    this.memo = '',
  });
}
