import 'package:cash_heart/models/gift_types.dart';
import 'package:flutter/material.dart';

//유저가 form 화면에서 저장 없이 이탈하려 할 경우, 경고창 보여줌.
Future<bool?> showWarningPopDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('정말 나가시겠습니까?'),
            content: Text('지금까지 입력한 모든 내용이 사라집니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('나가기'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('취소'),
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
