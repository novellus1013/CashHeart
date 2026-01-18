import 'dart:math';

import 'package:cash_heart/config/app_config.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:flutter/foundation.dart';

class MockDataService {
  static final MockDataService instance = MockDataService._internal();
  MockDataService._internal();

  final _personRepository = PersonRepository.instance;
  final _giftRepository = GiftRepository.instance;
  final _random = Random();

  /// 목 데이터가 이미 존재하는지 확인하고, 없으면 생성
  /// AppConfig.useMockData가 true일 때만 동작
  Future<void> ensureMockData() async {
    if (!AppConfig.useMockData) return;

    final persons = await _personRepository.getAllPersons();
    if (persons.isNotEmpty) {
      debugPrint('MockDataService: 이미 데이터가 존재합니다.');
      return;
    }

    debugPrint('MockDataService: 목 데이터 생성 시작...');
    await _generateMockData();
    debugPrint('MockDataService: 목 데이터 생성 완료!');
  }

  Future<void> _generateMockData() async {
    // 10명의 인물 데이터
    final mockPersons = [
      Person(name: '김민준', category: '가족', note: '아버지'),
      Person(name: '이서연', category: '가족', note: '어머니'),
      Person(name: '박지훈', category: '친구', note: '대학 동기'),
      Person(name: '최수아', category: '친구', note: '고등학교 친구'),
      Person(name: '정우진', category: '직장', note: '팀장님'),
      Person(name: '강하늘', category: '직장', note: '동료'),
      Person(name: '윤서준', category: '지인', note: '동네 이웃'),
      Person(name: '임지민', category: '지인', note: '동호회 회원'),
      Person(name: '한예린', category: '그외', note: '지인 소개'),
      Person(name: '오현우', category: '가족', note: '삼촌'),
      Person(name: '송민서', category: '친구', note: '직장 동료였던 친구'),
      Person(name: '신유나', category: '직장', note: '후배'),
    ];

    // 각 인물에 대해 ID를 받아서 선물 생성
    for (final person in mockPersons) {
      final personId = await _personRepository.insertPerson(person);
      await _generateGiftsForPerson(personId, person.category ?? '그외');
    }
  }

  Future<void> _generateGiftsForPerson(int personId, String category) async {
    // 각 인물당 5~8개의 선물 생성
    final giftCount = 5 + _random.nextInt(4);

    final now = DateTime.now();

    for (int i = 0; i < giftCount; i++) {
      // 최근 12개월 내의 랜덤 날짜
      final monthsAgo = _random.nextInt(12);
      final daysAgo = _random.nextInt(28);
      final giftDate = DateTime(now.year, now.month - monthsAgo, now.day - daysAgo);

      // 금액 (10,000 ~ 500,000 원, 만원 단위)
      final amount = (1 + _random.nextInt(50)) * 10000;

      // 방향 (받음/보냄) - 카테고리별로 약간 다르게
      final GiftDirection direction;
      if (category == '가족') {
        // 가족은 받는 경우가 더 많음
        direction = _random.nextDouble() < 0.6
            ? GiftDirection.received
            : GiftDirection.given;
      } else if (category == '직장') {
        // 직장은 주는 경우가 더 많음
        direction = _random.nextDouble() < 0.4
            ? GiftDirection.received
            : GiftDirection.given;
      } else {
        // 나머지는 반반
        direction = _random.nextBool()
            ? GiftDirection.received
            : GiftDirection.given;
      }

      // 선물 카테고리
      final giftCategory = _getRandomGiftCategory();

      // 메모
      final note = _getGiftNote(giftCategory, direction);

      final gift = Gift(
        personId: personId,
        amount: amount,
        direction: direction,
        category: giftCategory,
        date: giftDate.millisecondsSinceEpoch,
        note: note,
      );

      await _giftRepository.insertGift(gift);
    }
  }

  GiftCategory _getRandomGiftCategory() {
    final categories = GiftCategory.values;
    return categories[_random.nextInt(categories.length)];
  }

  String _getGiftNote(GiftCategory category, GiftDirection direction) {
    final action = direction == GiftDirection.received ? '받음' : '보냄';

    switch (category) {
      case GiftCategory.wedding:
        return '결혼식 축의금 $action';
      case GiftCategory.funeral:
        return '장례식 조의금 $action';
      case GiftCategory.birthBaby:
        return '출산 축하금 $action';
      case GiftCategory.school:
        return '입학/졸업 축하금 $action';
      case GiftCategory.job:
        return '취업/승진 축하금 $action';
      case GiftCategory.birthday:
        return '생일 선물 $action';
      case GiftCategory.holiday:
        return '명절 용돈 $action';
      case GiftCategory.anniversary:
        return '기념일 선물 $action';
      case GiftCategory.etc:
        return '기타 $action';
    }
  }
}
