import 'package:cash_heart/models/gift.dart';
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

  Future<void> _loadGifts() async {
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
    await _loadGifts();
  }

  Future<void> updateGift(Gift gift) async {
    await _giftRepository.updateGift(gift);
    await _loadGifts();
  }

  Future<void> deleteGift(int giftId) async {
    await _giftRepository.deleteGift(giftId);
    await _loadGifts();
  }
}
