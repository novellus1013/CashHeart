import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/gift_date_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));
  }

  testWidgets('제목/닫기 버튼 없이 연월 헤더와 캘린더만 렌더된다', (tester) async {
    final today = DateTime(2026, 7, 10);

    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => showGiftDatePickerBottomSheet(
          context: context,
          initialDate: today,
          firstDate: DateTime(1990),
          lastDate: today,
        ),
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('날짜 선택'), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.text('2026년 7월'), findsOneWidget);
    expect(find.text('오늘'), findsNothing);
    expect(find.text('취소'), findsNothing);
  });

  testWidgets('날짜를 탭하면 별도 확인 버튼 없이 바로 값을 반환한다', (tester) async {
    final today = DateTime(2026, 7, 10);
    DateTime? result;

    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await showGiftDatePickerBottomSheet(
            context: context,
            initialDate: today,
            firstDate: DateTime(1990),
            lastDate: today,
          );
        },
        child: const Text('열기'),
      );
    })));
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('5').first);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.day, 5);
  });
}
