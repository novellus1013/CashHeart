import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/pill_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  const items = [
    PillNavItem(icon: Icons.home_outlined, label: '홈'),
    PillNavItem(icon: Icons.bar_chart_outlined, label: '리포트'),
    PillNavItem(icon: Icons.settings_outlined, label: '설정'),
  ];

  testWidgets('선택된 아이템만 라벨이 보인다', (tester) async {
    await tester.pumpWidget(wrap(PillNav(
      items: items,
      selectedIndex: 0,
      onTap: (_) {},
    )));

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('리포트'), findsNothing);
    expect(find.text('설정'), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
  });

  testWidgets('아이템을 탭하면 해당 index로 onTap이 호출된다', (tester) async {
    int? tappedIndex;
    await tester.pumpWidget(wrap(PillNav(
      items: items,
      selectedIndex: 0,
      onTap: (index) => tappedIndex = index,
    )));

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    expect(tappedIndex, 1);
  });
}
