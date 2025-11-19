import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:flutter/material.dart';

class PersonViewModel extends ChangeNotifier {
  final PersonRepository _repository;

  //의존성 주입(DI): PersonViewModel은 _repository에 어떤 class가 들어오는지, 해당 class는 어떤 인스턴스를 가지는지 등을 알 수 없다 (강결합 x)
  PersonViewModel(this._repository);

  List<Person> _persons = [];
  List<Person> get persons => _persons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPersons() async {
    _isLoading = true;
    notifyListeners();

    _persons = await _repository.getAllPersons();

    _isLoading = false;
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

  //   Future<void> deletePerson(Person person) async {
  //   await _repository.deletePerson(person);
  //   await loadPersons();
  // }
}
