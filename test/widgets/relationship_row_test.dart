import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/relationship_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('이름/카테고리/메타/금액 텍스트가 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(RelationshipRow(
      name: '김민준',
      categoryLabel: '친구',
      categoryColor: Colors.blue,
      metaText: '5년간 9번의 마음 · 1주 전',
      netAmountText: '+ ₩ 320,000',
      tilt: 0.1,
    )));

    expect(find.text('김민준'), findsOneWidget);
    expect(find.text('친구'), findsOneWidget);
    expect(find.text('5년간 9번의 마음 · 1주 전'), findsOneWidget);
    expect(find.text('+ ₩ 320,000'), findsOneWidget);
  });

  testWidgets('탭하면 onTap 콜백이 호출된다', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(RelationshipRow(
      name: '김민준',
      categoryLabel: '친구',
      categoryColor: Colors.blue,
      metaText: '5년간 9번의 마음 · 1주 전',
      netAmountText: '+ ₩ 320,000',
      tilt: 0.1,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.text('김민준'));
    expect(tapped, isTrue);
  });
}
