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

  group('Detail 변형(statePill/quoteMessage/extra)', () {
    for (final entry in {
      'balanced': 0.1,
      'tilted': 0.35,
      'severe': 0.8,
    }.entries) {
      testWidgets('${entry.key} 상태에서도 statePill/quoteMessage/extra가 함께 렌더된다',
          (tester) async {
        final tilt = entry.value;
        final received = ((1 + tilt) * 500000).round();
        final given = 1000000 - received;

        await tester.pumpWidget(wrap(HeroCard(
          label: '오고 간 정(情) · 순잔액',
          netAmount: received - given,
          givenAmount: given,
          receivedAmount: received,
          statePill: const Text('상태 pill'),
          quoteMessage: '관찰자 톤 메시지',
          extra: const Text('추가 콘텐츠'),
        )));

        expect(find.text('상태 pill'), findsOneWidget);
        expect(find.text('관찰자 톤 메시지'), findsOneWidget);
        expect(find.text('추가 콘텐츠'), findsOneWidget);
      });
    }

    testWidgets('amountStyle을 넘기면 기본 heroAmount 대신 그 스타일을 쓴다', (tester) async {
      const customStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

      await tester.pumpWidget(wrap(const HeroCard(
        label: '오고 간 정(情) · 순잔액',
        netAmount: 320000,
        givenAmount: 540000,
        receivedAmount: 860000,
        amountStyle: customStyle,
      )));

      final amountText = tester.widget<Text>(find.textContaining('320,000'));
      expect(amountText.style!.fontSize, 30);
      expect(amountText.style!.fontWeight, FontWeight.w600);
    });
  });
}
