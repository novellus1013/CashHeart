import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/amount_keypad_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));
  }

  Future<int?> openAndGetResult(WidgetTester tester, {int? initialAmount}) async {
    int? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await showAmountKeypadSheet(context, initialAmount: initialAmount);
        },
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('숫자를 순서대로 누르면 콤마 포맷으로 표시되고 완료를 누르면 그 값을 반환한다', (tester) async {
    await openAndGetResult(tester);

    await tester.tap(find.text('1'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('00'));
    await tester.pump();

    expect(find.text('15,000원'), findsOneWidget);

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
  });

  testWidgets('백스페이스는 마지막 숫자 하나만 지운다', (tester) async {
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => showAmountKeypadSheet(context),
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.text('123원'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(find.text('12원'), findsOneWidget);
  });

  testWidgets('아무 숫자도 입력하지 않으면 완료 버튼이 비활성화된다', (tester) async {
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => showAmountKeypadSheet(context),
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '완료'));
    expect(button.onPressed, isNull);
  });

  testWidgets('initialAmount이 있으면 콤마 포맷으로 미리 표시된다', (tester) async {
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => showAmountKeypadSheet(context, initialAmount: 320000),
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('320,000원'), findsOneWidget);
  });
}
