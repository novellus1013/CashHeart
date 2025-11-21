import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:flutter/material.dart';

class GiftViewModel extends ChangeNotifier {
  final GiftRepository _giftRepository;
  final int personId;

  GiftViewModel(this._giftRepository, this.personId);

  List<Gift> _gifts = [];
  List<Gift> get gifts => _gifts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadGifts() async {
    _isLoading = true;
    notifyListeners();

    _gifts = await _giftRepository.getGiftsListByPersonId(personId);

    _isLoading = false;
    notifyListeners();
  }

  Gift? getOneGiftByGiftId(int giftId) {
    try {
      return _gifts.firstWhere((e) => e.id == giftId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addGift(Gift gift) async {
    await _giftRepository.insertGift(gift);
    await loadGifts();
  }

  Future<void> updateGift(Gift gift) async {
    await _giftRepository.updateGift(gift);
    await loadGifts();
  }

  Future<void> deleteGift(int giftId) async {
    await _giftRepository.deleteGift(giftId);
    await loadGifts();
  }

  //filter 및 ui 반영을 위한 getter 정의
  int get totalAmount {
    return _gifts.fold(0, (previous, g) => previous + g.signedAmount);
  }

  int get totalReceived {
    return _gifts
        .where((g) => g.direction == GiftDirection.received)
        .fold(0, (previous, g) => previous + g.amount);
  }

  int get totalGiven {
    return _gifts
        .where((g) => g.direction == GiftDirection.given)
        .fold(0, (previous, g) => previous + g.amount);
  }

  List<Gift> get giftReceivedList {
    return _gifts.where((g) => g.direction == GiftDirection.received).toList();
  }

  List<Gift> get giftGivenList {
    return _gifts.where((g) => g.direction == GiftDirection.given).toList();
  }
}
