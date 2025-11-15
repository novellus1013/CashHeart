enum GiftDirection {
  given,
  received,
}

enum GiftCategory {
  wedding, // 결혼
  funeral, // 장례
  birthBaby, // 출산/돌/100일
  school, // 입학/졸업
  job, // 취업/승진/이직
  birthday, // 생일
  holiday, // 명절
  anniversary, // 각종 기념일
  etc, // 기타
}

//extension을 쓰는 이유 - enum은 enum 내
extension GiftDirectionLabels on GiftDirection {
  String get label {
    if (this == GiftDirection.given) {
      return "준 돈";
    } else {
      return "받은 돈";
    }
  }
}

extension GiftCategoryLabel on GiftCategory {
  String get label {
    switch (this) {
      case GiftCategory.wedding:
        return '결혼';
      case GiftCategory.funeral:
        return '장례';
      case GiftCategory.birthBaby:
        return '출산 · 돌';
      case GiftCategory.school:
        return '입학 · 졸업';
      case GiftCategory.job:
        return '취업 · 승진';
      case GiftCategory.birthday:
        return '생일';
      case GiftCategory.holiday:
        return '명절';
      case GiftCategory.anniversary:
        return '기념일';
      case GiftCategory.etc:
        return '기타';
    }
  }
}
