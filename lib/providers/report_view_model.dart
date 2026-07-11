import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:flutter/material.dart';

/// design_handoff `CAT_PALETTE` 이식 — 경조사 분포 도넛/범례 색상 순서.
/// 카테고리 자체의 고유색이 아니라 "이번 리포트에서 금액이 큰 순서"에 매기는
/// 색이라 person 카테고리 색(constants/colors.dart)과는 별개다.
const List<Color> _categoryPalette = [
  Color(0xFFFF6258),
  Color(0xFF027DFD),
  Color(0xFF4CAF50),
  Color(0xFFFFA726),
  Color(0xFF8B6CD6),
  Color(0xFF1B8A8F),
];

/// 월별 데이터 모델
class MonthlyData {
  final String month; // 'yyyy-MM' 형식
  final String label; // 화면에 표시할 라벨 (e.g., 'Jan')
  final int given;
  final int received;

  MonthlyData({
    required this.month,
    required this.label,
    required this.given,
    required this.received,
  });
}

/// 카테고리별 통계 모델
class CategoryData {
  final String category;
  final int totalAmount;
  final double percentage;
  final Color color;

  CategoryData({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.color,
  });
}

/// person + 그 person의 [RelationshipStats] — Report 인사이트(균형/치우침) 소비용.
class PersonRelationshipStats {
  final Person person;
  final RelationshipStats stats;

  const PersonRelationshipStats({required this.person, required this.stats});
}

class ReportViewModel extends ChangeNotifier {
  final GiftRepository _giftRepository;
  final PersonRepository _personRepository;

  ReportViewModel(this._giftRepository, this._personRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalGiven = 0;
  int get totalGiven => _totalGiven;

  int _totalReceived = 0;
  int get totalReceived => _totalReceived;

  List<MonthlyData> _monthlyData = [];
  List<MonthlyData> get monthlyData => _monthlyData;

  List<CategoryData> _categoryData = [];
  List<CategoryData> get categoryData => _categoryData;

  /// 거래 건수(count) 가장 많은 순 top3 — "이 기간 균형/치우침" 인사이트가
  /// 유저에게 궁금하지 않은 정보라는 피드백(2026-07-11)으로 교체됐다.
  List<PersonRelationshipStats> _mostFrequent = [];
  List<PersonRelationshipStats> get mostFrequent => _mostFrequent;

  /// 오간 마음 총액(given+received) 큰 순 top3 — 준/받은 금액을 한 줄에 함께
  /// 보여준다. 원래는 "가장 많이 준 사람"/"가장 많이 받은 사람"/"마음이 향한
  /// 방향" 3개 섹션으로 나뉘어 있었으나, 같은 사람이 서로 다른 랭킹에 다르게
  /// 나타나 혼란스럽다는 피드백(2026-07-11)으로 하나의 목록으로 통합했다.
  List<PersonRelationshipStats> _topInteractions = [];
  List<PersonRelationshipStats> get topInteractions => _topInteractions;

  /// 월(1~12월, index 0=1월) 기준 전체 기간 누적 총액 — 계절성 파악용.
  List<int> _monthlyHistoryTotals = List.filled(12, 0);
  List<int> get monthlyHistoryTotals => _monthlyHistoryTotals;

  /// 누적 총액이 가장 큰 달 1~2개(동률/데이터 없음 처리 포함). 화면 문구 조합용.
  List<int> _peakMonths = [];
  List<int> get peakMonths => _peakMonths;

  /// 올해 누적(1/1~오늘) vs 작년 동기간 대비 증감률. 작년 동기간 기록이 없으면 null.
  double? _yoyChangePercent;
  double? get yoyChangePercent => _yoyChangePercent;

  String? _topCategory;
  String? get topCategory => _topCategory;

  Future<void> loadReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 총액 조회
      _totalGiven = await _giftRepository.getTotalGiven();
      _totalReceived = await _giftRepository.getTotalReceived();

      // 월별 데이터 조회
      await _loadMonthlyData();

      // person별 stats는 균형/치우침 인사이트가 소비한다.
      final persons = await _personRepository.getAllPersons();
      final statsByPerson = await _giftRepository.getStatsByPerson();

      // 경조사 분포는 person 관계 카테고리가 아니라 gift의 이벤트 카테고리
      // (결혼/장례/출산 등) 기준으로 집계한다 — 이전에는 person.category로 잘못
      // 집계되던 버그(2026-07-11 검수에서 발견).
      final gifts = await _giftRepository.getAllGifts();
      _loadCategoryData(gifts);
      _loadPersonInsights(persons, statsByPerson);
      _loadSeasonality(gifts);
      _loadYoyComparison(gifts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMonthlyData() async {
    final monthlyTotals = await _giftRepository.getMonthlyTotals();
    final monthLabels = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월'
    ];

    // 최근 6개월 데이터 생성
    final now = DateTime.now();
    final List<MonthlyData> data = [];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final totals = monthlyTotals[key];

      data.add(MonthlyData(
        month: key,
        label: monthLabels[date.month - 1],
        given: totals?.given ?? 0,
        received: totals?.received ?? 0,
      ));
    }

    _monthlyData = data;
  }

  void _loadCategoryData(List<Gift> gifts) {
    // 경조사(이벤트) 카테고리별 총액 계산 — 준/받은 마음 구분 없이 오고 간 마음 전체.
    final Map<GiftCategory, int> categoryTotals = {};
    int grandTotal = 0;

    for (final gift in gifts) {
      categoryTotals[gift.category] =
          (categoryTotals[gift.category] ?? 0) + gift.amount;
      grandTotal += gift.amount;
    }

    final List<CategoryData> data = [];
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      final percentage =
          grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0.0;
      data.add(CategoryData(
        category: entry.key.label,
        totalAmount: entry.value,
        percentage: percentage,
        color: _categoryPalette[i % _categoryPalette.length],
      ));
    }

    _categoryData = data;
    _topCategory = data.isNotEmpty ? data.first.category : null;
  }

  void _loadPersonInsights(
    List<Person> persons,
    Map<int, RelationshipStats> statsByPerson,
  ) {
    final withRecords = <PersonRelationshipStats>[];
    for (final person in persons) {
      final stats = statsByPerson[person.id];
      if (stats != null && stats.count > 0) {
        withRecords.add(PersonRelationshipStats(person: person, stats: stats));
      }
    }

    final frequent = [...withRecords]
      ..sort((a, b) => b.stats.count.compareTo(a.stats.count));
    _mostFrequent = frequent.take(3).toList();

    final interactions = [...withRecords]
      ..sort((a, b) => b.stats.total.compareTo(a.stats.total));
    _topInteractions = interactions.take(3).toList();
  }

  /// 월(1~12) 기준 전체 기간 누적 총액 — "N월/M월에 마음을 나누는 일이 많아요" 같은
  /// 계절성 인사이트용. 연도 구분 없이 달만 묶는다(2026-07-11 추가).
  void _loadSeasonality(List<Gift> gifts) {
    final totals = List.filled(12, 0);
    for (final gift in gifts) {
      final month = DateTime.fromMillisecondsSinceEpoch(gift.date).month;
      totals[month - 1] += gift.amount;
    }
    _monthlyHistoryTotals = totals;

    final maxTotal = totals.fold<int>(0, (a, b) => a > b ? a : b);
    if (maxTotal == 0) {
      _peakMonths = [];
      return;
    }
    // 최댓값의 80% 이상인 달까지 "피크"로 함께 언급(단일 달로 몰리지 않는 케이스 대응).
    final ranked = [
      for (var i = 0; i < 12; i++)
        if (totals[i] >= maxTotal * 0.8 && totals[i] > 0) i + 1,
    ]..sort((a, b) => totals[b - 1].compareTo(totals[a - 1]));
    _peakMonths = ranked.take(2).toList();
  }

  /// 올해 1/1~오늘 누적 vs 작년 같은 기간 누적 증감률.
  void _loadYoyComparison(List<Gift> gifts) {
    final now = DateTime.now();
    final thisYearStart = DateTime(now.year, 1, 1);
    final lastYearStart = DateTime(now.year - 1, 1, 1);
    final lastYearSamePeriodEnd = DateTime(now.year - 1, now.month, now.day);

    int thisYearTotal = 0;
    int lastYearTotal = 0;
    for (final gift in gifts) {
      final date = DateTime.fromMillisecondsSinceEpoch(gift.date);
      if (!date.isBefore(thisYearStart) && !date.isAfter(now)) {
        thisYearTotal += gift.amount;
      } else if (!date.isBefore(lastYearStart) &&
          !date.isAfter(lastYearSamePeriodEnd)) {
        lastYearTotal += gift.amount;
      }
    }

    _yoyChangePercent = lastYearTotal == 0
        ? null
        : ((thisYearTotal - lastYearTotal) / lastYearTotal) * 100;
  }
}
