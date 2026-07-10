import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//유저가 form 화면에서 저장 없이 이탈하려 할 경우, 경고창 보여줌.
Future<bool?> showWarningPopDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              '정말 나가시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.size20,
              ),
            ),
            content: const Text(
              '지금까지 입력한 모든 내용이 사라집니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  '나가기',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ));
}

//person_detail_screen에서 gift ctegory 별로 보여 줄 이모지와 컬러
class GiftCategoryMeta {
  final String emoji;
  final Color bgColor;

  const GiftCategoryMeta(this.emoji, this.bgColor);
}

const Map<GiftCategory, GiftCategoryMeta> giftCategoryMeta = {
  GiftCategory.wedding: GiftCategoryMeta('💍', Color(0xFFFFE4E0)),
  GiftCategory.funeral: GiftCategoryMeta('💐', Color(0xFFE9ECF1)),
  GiftCategory.birthBaby: GiftCategoryMeta('👶', Color(0xFFFFF2CC)),
  GiftCategory.school: GiftCategoryMeta('🎓', Color(0xFFE9F3FF)),
  GiftCategory.job: GiftCategoryMeta('💼', Color(0xFFE4F5EE)),
  GiftCategory.birthday: GiftCategoryMeta('🎂', Color(0xFFFFE8F6)),
  GiftCategory.holiday: GiftCategoryMeta('🧧', Color(0xFFFFF0E0)),
  GiftCategory.anniversary: GiftCategoryMeta('🎉', Color(0xFFFDE7E7)),
  GiftCategory.etc: GiftCategoryMeta('🎁', Color(0xFFECECEC)),
};

//itnl 패키지를 이용한 통화 표기 방식용 함수
class MoneyFormatter {
  static String formatCurrency(num amount, String locale, String symbol) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
    ).format(amount);
  }

  /// 10자리 이상(≥ 10억) 금액은 "1.2억원" 형태로 축약.
  /// 상단 카드 총액이 자릿수 때문에 2줄로 깨지거나 말줄임되는 문제(부록 A) 방지용.
  static String formatAbbreviated(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    if (absAmount < 1000000000) {
      return formatCurrency(amount, 'ko_KR', '₩ ');
    }

    final eok = absAmount / 100000000;
    final formatted = eok.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    return '${isNegative ? '-' : ''}$formatted억원';
  }
}
