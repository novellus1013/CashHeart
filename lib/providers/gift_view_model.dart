import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:flutter/material.dart';

class GiftViewModel extends ChangeNotifier {
  final GiftRepository _giftRepository;
  final int personId;

  GiftViewModel(this._giftRepository, this.personId);

  List<Gift> _gifts = [];
  List<Gift> get gifts => _gifts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ShareCardCase _shareCardCase = ShareCardCase.none;

  /// 이 person의 카드 공유 자격 케이스 — `none`이면 person_detail의 공유
  /// 버튼을 숨긴다("둘 다 아니면 공유 버튼 미노출", Sprint 4 스펙).
  ShareCardCase get shareCardCase => _shareCardCase;

  Future<void> loadGifts() async {
    _isLoading = true;
    notifyListeners();

    _gifts = await _giftRepository.getGiftsListByPersonId(personId);
    _shareCardCase = await _loadShareCardCase();

    _isLoading = false;
    notifyListeners();
  }

  Future<ShareCardCase> _loadShareCardCase() async {
    if (_gifts.isEmpty) return ShareCardCase.none;

    final rankInfo = await _giftRepository.getTotalRank(personId);
    return determineShareCardCase(
      stats: stats,
      rank: rankInfo.rank,
      totalPersonsWithRecords: rankInfo.totalPersonsWithRecords,
    );
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
  //personId에 따른 금액
  int get totalAmountById {
    return _gifts.fold(0, (previous, g) => previous + g.signedAmount);
  }

  int get totalReceivedById {
    return _gifts
        .where((g) => g.direction == GiftDirection.received)
        .fold(0, (previous, g) => previous + g.amount);
  }

  int get totalGivenById {
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

  /// 캐시된 [_gifts]로부터 로컬 구성하는 person 1명의 [RelationshipStats].
  /// Person Detail 화면(HeroCard/StreamChart 등)이 소비하는 순수 파생 값.
  RelationshipStats get stats {
    if (_gifts.isEmpty) return RelationshipStats.empty;

    DateTime? first;
    DateTime? last;
    for (final gift in _gifts) {
      final d = DateTime.fromMillisecondsSinceEpoch(gift.date);
      if (first == null || d.isBefore(first)) first = d;
      if (last == null || d.isAfter(last)) last = d;
    }

    return RelationshipStats(
      received: totalReceivedById,
      given: totalGivenById,
      count: _gifts.length,
      firstDate: first,
      lastDate: last,
    );
  }
}
