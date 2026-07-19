import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:flutter/material.dart';

class PersonViewModel extends ChangeNotifier {
  final PersonRepository _repository;

  final GiftRepository _giftRepository = GiftRepository.instance;

  //의존성 주입(DI): PersonViewModel은 _repository에 어떤 class가 들어오는지, 해당 class는 어떤 인스턴스를 가지는지 등을 알 수 없다 (강결합 x)
  PersonViewModel(this._repository);

  List<Person> _persons = [];
  List<Person> get persons => _persons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<int, RelationshipStats> _statsByPerson = {};
  Map<int, RelationshipStats> get statsByPerson => _statsByPerson;
  RelationshipStats? getStats(int personId) => _statsByPerson[personId];

  int getTotalReceived(int personId) =>
      _statsByPerson[personId]?.received ?? 0;
  int getTotalGiven(int personId) => _statsByPerson[personId]?.given ?? 0;
  int getTotalAmountByPerson(int personId) =>
      _statsByPerson[personId]?.net ?? 0;

  int _totalAmount = 0;
  int get totalAmount => _totalAmount;

  int _totalGiven = 0;
  int get totalGiven => _totalGiven;

  int _totalReceived = 0;
  int get totalReceived => _totalReceived;

  /// 앱 시작 시 마이그레이션 안내 화면(Sprint 5) 노출 여부 판단용.
  /// DB가 아직 열리지 않았다면 여는 것까지 보장한다.
  Future<bool> checkMigrationOccurred() =>
      _repository.ensureOpenedAndCheckMigration();

  Future<void> loadPersons() async {
    _isLoading = true;
    notifyListeners();

    _persons = await _repository.getAllPersons();

    _statsByPerson = await _giftRepository.getStatsByPerson();
    _totalGiven = await _giftRepository.getTotalGiven();
    _totalReceived = await _giftRepository.getTotalReceived();
    _totalAmount = await _giftRepository.getTotalAmount();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshTotals() async {
    _statsByPerson = await _giftRepository.getStatsByPerson();
    _totalGiven = await _giftRepository.getTotalGiven();
    _totalReceived = await _giftRepository.getTotalReceived();
    _totalAmount = await _giftRepository.getTotalAmount();
    notifyListeners();
  }

  /// Home hero 카드의 기간 필터용 — [sinceMs]가 null이면 전체 기간.
  Future<({int given, int received})> getTotalsForPeriod(int? sinceMs) {
    return _giftRepository.getTotalsSince(sinceMs);
  }

  Person? getPersonById(int id) {
    try {
      return _persons.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> addPerson(Person person) async {
    final personId = await _repository.insertPerson(person);
    await loadPersons();

    return personId;
  }

  Future<void> updatePerson(Person person) async {
    await _repository.updatePerson(person);
    await loadPersons();
  }

  Future<void> deletePerson(int id) async {
    await _repository.deletePerson(id);
    await loadPersons();
  }
}
