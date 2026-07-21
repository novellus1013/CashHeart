import 'package:cash_heart/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 유저가 form 화면에서 저장 없이 이탈하려 할 경우, 경고창 보여줌.
// 내역/지인 삭제 확인창과 동일한 ConfirmDialog UI를 재사용한다(2026-07-11 검수).
Future<bool> showWarningPopDialog(BuildContext context) {
  return showConfirmDialog(
    context,
    title: '정말 나가시겠습니까?',
    message: '지금까지 입력한 모든 내용이 사라집니다.',
    confirmLabel: '나가기',
  );
}

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

  /// design_handoff `formatWonShort` 이식 — 차트 축/촘촘한 칩 등 좁은 공간용.
  /// 1억 이상은 "1.2억", 1만 이상은 "530만", 그 외엔 콤마 포맷("9,000").
  static String formatWonShort(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted;
    if (absAmount >= 100000000) {
      final eok = absAmount / 100000000;
      formatted =
          '${eok.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')}억';
    } else if (absAmount >= 10000) {
      formatted = '${(absAmount / 10000).round()}만';
    } else {
      formatted = NumberFormat.decimalPattern('ko_KR').format(absAmount);
    }

    return isNegative ? '-$formatted' : formatted;
  }
}
