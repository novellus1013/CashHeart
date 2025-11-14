import 'package:intl/intl.dart';

//itnl 패키지를 이용한 통화 표기 방식용 함수
class MoneyFormatter {
  static String formatCurrency(num amount, String locale, String symbol) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
    ).format(amount);
  }
}
