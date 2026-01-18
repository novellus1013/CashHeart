import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_totals.dart';
import 'package:cash_heart/models/person.dart';
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

  Map<int, GiftTotals> _totalsByPerson = {};
  Map<int, GiftTotals> get totalsByPerson => _totalsByPerson;

  Map<int, Gift> _lastGiftByPerson = {};
  Map<int, Gift> get lastGiftByPerson => _lastGiftByPerson;

  int getTotalReceived(int personId) =>
      _totalsByPerson[personId]?.totalReceivedAmount ?? 0;
  int getTotalGiven(int personId) =>
      _totalsByPerson[personId]?.totalGivenAmount ?? 0;
  int getTotalAmountByPerson(int personId) =>
      _totalsByPerson[personId]?.totalAmount ?? 0;
  Gift? getLastGift(int personId) => _lastGiftByPerson[personId];

  int _totalAmount = 0;
  int get totalAmount => _totalAmount;

  int _totalGiven = 0;
  int get totalGiven => _totalGiven;

  int _totalReceived = 0;
  int get totalReceived => _totalReceived;

  Future<void> loadPersons() async {
    _isLoading = true;
    notifyListeners();

    _persons = await _repository.getAllPersons();

    _totalsByPerson = await _giftRepository.getTotalsByPerson();
    _lastGiftByPerson = await _giftRepository.getLastGiftByPerson();
    _totalGiven = await _giftRepository.getTotalGiven();
    _totalReceived = await _giftRepository.getTotalReceived();
    _totalAmount = await _giftRepository.getTotalAmount();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshTotals() async {
    _totalsByPerson = await _giftRepository.getTotalsByPerson();
    _lastGiftByPerson = await _giftRepository.getLastGiftByPerson();
    _totalGiven = await _giftRepository.getTotalGiven();
    _totalReceived = await _giftRepository.getTotalReceived();
    _totalAmount = await _giftRepository.getTotalAmount();
    notifyListeners();
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
