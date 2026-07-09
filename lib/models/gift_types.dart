import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

//ui용 label 생성
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

// db 계산용
extension GiftDirectionDb on GiftDirection {
  int get dbValue => this == GiftDirection.received ? 1 : -1;

  static GiftDirection fromDb(int value) {
    if (value == 1) {
      return GiftDirection.received;
    } else {
      return GiftDirection.given;
    }
  }
}

extension GiftCategoryDb on GiftCategory {
  String get dbValue => name;

  static GiftCategory fromDb(String value) {
    for (final category in GiftCategory.values) {
      if (category.name == value) return category;
    }
    // DB 손상, 또는 미래 버전에서 제거·리네임된 category 값 등
    // 알 수 없는 값은 byName처럼 ArgumentError로 크래시시키지 않고 '기타'로 폴백한다.
    // (Gift.fromMap이 모든 행 읽기마다 호출하므로, 한 행만 손상돼도 목록 로딩 전체가 죽는 걸 막는다.)
    // 예외를 던지지 않으므로 Repository의 try/catch → Sentry 경로를 안 타서,
    // 여기서 직접 captureMessage로 보고한다(prod에서만 전송되고, Sentry 미초기화인
    // dev에서는 no-op). fromDb는 동기 함수라 fire-and-forget으로 호출한다.
    debugPrint('GiftCategoryDb.fromDb: 알 수 없는 category "$value" → etc 폴백');
    Sentry.captureMessage(
      'GiftCategoryDb.fromDb: 알 수 없는 category 값 "$value" → etc 폴백',
      level: SentryLevel.warning,
    );
    return GiftCategory.etc;
  }
}
