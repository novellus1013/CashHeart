import 'package:cash_heart/theme/balance_state.dart';

/// 한쪽이 다른 쪽보다 확연히 자주/많이 주고받았는지(참고용, 판단 카피에는 쓰지 않음).
enum RelationshipDirection { received, given, even }

/// design_handoff `personStats(p)` 이식 — person 1명의 준/받은 마음 집계.
/// 순수 계산 값 객체. Repository의 GROUP BY 집계 또는 GiftViewModel의 캐시된
/// gift 목록으로부터 구성되며, 위젯은 이 객체(또는 프리미티브)만 받는 순수 프레젠테이션이어야 한다.
class RelationshipStats {
  final int received;
  final int given;
  final int count;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const RelationshipStats({
    required this.received,
    required this.given,
    required this.count,
    this.firstDate,
    this.lastDate,
  });

  static const empty = RelationshipStats(received: 0, given: 0, count: 0);

  int get net => received - given;
  int get total => received + given;

  /// -1(전부 줌) ~ 0(균형) ~ +1(전부 받음).
  double get tilt => total == 0 ? 0 : (received - given) / total;

  BalanceState get state => BalanceState.fromTilt(tilt);

  RelationshipDirection get direction {
    if (tilt > 0.04) return RelationshipDirection.received;
    if (tilt < -0.04) return RelationshipDirection.given;
    return RelationshipDirection.even;
  }

  /// 관계가 이어져 온 연수. 기록이 있으면 최소 1년.
  int get years {
    if (firstDate == null || lastDate == null) return 0;
    final days = lastDate!.difference(firstDate!).inDays;
    final rounded = (days / 365.25).round();
    return rounded < 1 ? 1 : rounded;
  }
}
