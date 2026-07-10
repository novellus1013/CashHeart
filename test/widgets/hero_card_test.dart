import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('10자리 이상 순잔액은 억 단위로 축약되어 렌더된다 (부록 A 버그 회귀)',
      (tester) async {
    await tester.pumpWidget(wrap(const HeroCard(
      label: '오고 간 정(情) · 순잔액',
      netAmount: 1234567890,
      givenAmount: 100000000,
      receivedAmount: 1334567890,
    )));

    expect(find.text('12.3억원'), findsOneWidget);
    expect(find.textContaining('1,234,567,890'), findsNothing);
  });

  testWidgets('9자리 이하 금액은 기존 통화 포맷 그대로 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(const HeroCard(
      label: '오고 간 정(情) · 순잔액',
      netAmount: 320000,
      givenAmount: 540000,
      receivedAmount: 860000,
    )));

    expect(find.textContaining('320,000'), findsOneWidget);
    expect(find.textContaining('억원'), findsNothing);
  });

  testWidgets('준 마음은 given(파랑) 색, 받은 마음은 received(빨강) 색으로 렌더된다 (색 매핑 회귀)',
      (tester) async {
    await tester.pumpWidget(wrap(const HeroCard(
      label: '오고 간 정(情) · 순잔액',
      netAmount: 320000,
      givenAmount: 540000,
      receivedAmount: 860000,
    )));

    final givenText = tester.widget<Text>(find.textContaining('540,000'));
    final receivedText = tester.widget<Text>(find.textContaining('860,000'));

    expect(givenText.style!.color, AppColors.light.given);
    expect(receivedText.style!.color, AppColors.light.received);
  });
}
