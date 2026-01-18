import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:flutter/material.dart';

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

/// 인물별 잔액 모델 (Top Gratitude / Top Generosity)
class PersonBalance {
  final Person person;
  final int netBalance; // positive = 받은게 더 많음, negative = 준게 더 많음

  PersonBalance({required this.person, required this.netBalance});
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

  List<PersonBalance> _topGratitude = [];
  List<PersonBalance> get topGratitude => _topGratitude;

  List<PersonBalance> _topGenerosity = [];
  List<PersonBalance> get topGenerosity => _topGenerosity;

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

      // 카테고리 데이터 조회
      await _loadCategoryData();

      // Top Gratitude/Generosity 조회
      await _loadTopPersons();
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

  Future<void> _loadCategoryData() async {
    final persons = await _personRepository.getAllPersons();
    final totalsByPerson = await _giftRepository.getTotalsByPerson();

    // 카테고리별 총액 계산
    final Map<String, int> categoryTotals = {};
    int grandTotal = 0;

    for (final person in persons) {
      final category = person.category ?? '그외';
      final totals = totalsByPerson[person.id];
      if (totals != null) {
        final personTotal =
            totals.totalGivenAmount + totals.totalReceivedAmount;
        categoryTotals[category] =
            (categoryTotals[category] ?? 0) + personTotal;
        grandTotal += personTotal;
      }
    }

    // 퍼센티지 계산 및 정렬
    final List<CategoryData> data = [];
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedCategories) {
      final percentage =
          grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0.0;
      data.add(CategoryData(
        category: entry.key,
        totalAmount: entry.value,
        percentage: percentage,
        color: getCategoryColor(entry.key),
      ));
    }

    _categoryData = data;
    _topCategory = data.isNotEmpty ? data.first.category : null;
  }

  Future<void> _loadTopPersons() async {
    final persons = await _personRepository.getAllPersons();
    final totalsByPerson = await _giftRepository.getTotalsByPerson();

    final List<PersonBalance> balances = [];

    for (final person in persons) {
      final totals = totalsByPerson[person.id];
      if (totals != null) {
        // netBalance = 받은 돈 - 준 돈
        // positive = 받은게 더 많음 (gratitude)
        // negative = 준게 더 많음 (generosity)
        final netBalance = totals.totalReceivedAmount - totals.totalGivenAmount;
        balances.add(PersonBalance(person: person, netBalance: netBalance));
      }
    }

    // Top Gratitude: 받은 돈이 많은 사람 (netBalance > 0)
    final gratitudeList = balances.where((b) => b.netBalance > 0).toList()
      ..sort((a, b) => b.netBalance.compareTo(a.netBalance));
    _topGratitude = gratitudeList.take(3).toList();

    // Top Generosity: 준 돈이 많은 사람 (netBalance < 0)
    final generosityList = balances.where((b) => b.netBalance < 0).toList()
      ..sort((a, b) => a.netBalance.compareTo(b.netBalance));
    _topGenerosity = generosityList.take(3).toList();
  }
}
