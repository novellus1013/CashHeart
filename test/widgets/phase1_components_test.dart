import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/app_chip.dart';
import 'package:cash_heart/widgets/category_bars.dart';
import 'package:cash_heart/widgets/confirm_dialog.dart';
import 'package:cash_heart/widgets/donut_chart.dart';
import 'package:cash_heart/widgets/stream_chart.dart';
import 'package:cash_heart/widgets/trend_chart.dart';
import 'package:cash_heart/widgets/txn_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  group('AppChip / ChipRow', () {
    testWidgets('active 상태는 굵게, 탭하면 onTap이 호출된다', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(AppChip(
        label: '친구',
        active: true,
        onTap: () => tapped = true,
      )));

      expect(find.text('친구'), findsOneWidget);
      await tester.tap(find.text('친구'));
      expect(tapped, isTrue);
    });

    testWidgets('ChipRow는 선택된 value만 active로 렌더된다', (tester) async {
      String selected = '가족';
      await tester.pumpWidget(wrap(ChipRow<String>(
        items: const ['가족', '친구', '직장'],
        value: selected,
        onChanged: (v) => selected = v,
        labelOf: (v) => v,
      )));

      expect(find.text('가족'), findsOneWidget);
      expect(find.text('친구'), findsOneWidget);
      expect(find.text('직장'), findsOneWidget);
    });
  });

  group('TxnRow', () {
    testWidgets('받음/줌에 따라 부호와 카테고리 라벨이 렌더된다', (tester) async {
      final gift = Gift(
        personId: 1,
        amount: 50000,
        direction: GiftDirection.received,
        category: GiftCategory.wedding,
        date: DateTime(2024, 3, 1).millisecondsSinceEpoch,
        note: '축하 인사',
      );

      await tester.pumpWidget(wrap(TxnRow(gift: gift)));

      expect(find.text('결혼'), findsOneWidget);
      expect(find.text('받음'), findsOneWidget);
      expect(find.textContaining('+'), findsOneWidget);
    });
  });

  group('StreamChart', () {
    testWidgets('기록이 2건 미만이면 안내 문구를 보여준다', (tester) async {
      final gift = Gift(
        personId: 1,
        amount: 10000,
        direction: GiftDirection.given,
        category: GiftCategory.etc,
        date: DateTime.now().millisecondsSinceEpoch,
        note: '',
      );

      await tester.pumpWidget(wrap(StreamChart(gifts: [gift])));

      expect(find.text('흐름을 그리려면 기록이 더 필요해요'), findsOneWidget);
    });

    testWidgets('기록이 2건 이상이면 CustomPaint로 렌더된다', (tester) async {
      final gifts = [
        Gift(
          personId: 1,
          amount: 10000,
          direction: GiftDirection.given,
          category: GiftCategory.etc,
          date: DateTime(2023, 1, 1).millisecondsSinceEpoch,
          note: '',
        ),
        Gift(
          personId: 1,
          amount: 20000,
          direction: GiftDirection.received,
          category: GiftCategory.etc,
          date: DateTime(2024, 1, 1).millisecondsSinceEpoch,
          note: '',
        ),
      ];

      await tester.pumpWidget(wrap(StreamChart(gifts: gifts)));

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('흐름을 그리려면 기록이 더 필요해요'), findsNothing);
    });
  });

  testWidgets('DonutChart는 슬라이스 없이도 예외 없이 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(const DonutChart(slices: [])));
    expect(find.byType(DonutChart), findsOneWidget);
  });

  testWidgets('TrendChart는 단일 포인트에서도 예외 없이 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(TrendChart(
      months: const [TrendChartPoint(label: '1월', given: 0, received: 0)],
      receivedColor: Colors.blue,
      givenColor: Colors.red,
      gridColor: Colors.grey,
    )));

    expect(find.byType(TrendChart), findsOneWidget);
  });

  testWidgets('CategoryBars는 카테고리별 라벨과 합계를 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(const CategoryBars(byCategory: [
      CategoryBarData(
        label: '결혼',
        icon: Icons.favorite,
        received: 100000,
        given: 0,
      ),
    ])));

    expect(find.text('결혼'), findsOneWidget);
  });

  group('ConfirmDialog', () {
    testWidgets('확인을 누르면 true를 반환한다', (tester) async {
      bool? result;
      await tester.pumpWidget(wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            result = await showConfirmDialog(context, title: '삭제하시겠습니까?');
          },
          child: const Text('열기'),
        );
      })));

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('취소를 누르면 false를 반환한다', (tester) async {
      bool? result;
      await tester.pumpWidget(wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            result = await showConfirmDialog(context, title: '삭제하시겠습니까?');
          },
          child: const Text('열기'),
        );
      })));

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
