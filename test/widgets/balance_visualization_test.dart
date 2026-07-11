import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SizedBox(width: 300, child: child),
      ),
    );
  }

  Color markerColor(WidgetTester tester) {
    final containers = tester.widgetList<Container>(find.byType(Container));
    final marker = containers.firstWhere(
      (c) => c.decoration is BoxDecoration &&
          (c.decoration as BoxDecoration).shape == BoxShape.circle,
    );
    return ((marker.decoration as BoxDecoration).color)!;
  }

  testWidgets('tilt 0.1은 balanced 마커 색으로 표시된다', (tester) async {
    await tester.pumpWidget(wrap(const BalanceVisualization(tilt: 0.1)));
    expect(markerColor(tester), AppColors.light.balanced);
  });

  testWidgets('tilt 0.35는 tilted 마커 색으로 표시된다', (tester) async {
    await tester.pumpWidget(wrap(const BalanceVisualization(tilt: 0.35)));
    expect(markerColor(tester), AppColors.light.tilted);
  });

  testWidgets('tilt 0.7은 severe 마커 색으로 표시된다', (tester) async {
    await tester.pumpWidget(wrap(const BalanceVisualization(tilt: 0.7)));
    expect(markerColor(tester), AppColors.light.severe);
  });

  testWidgets('준/받음 막대 색은 colors.given/colors.received를 따른다', (tester) async {
    await tester.pumpWidget(wrap(const BalanceVisualization(tilt: 0.0)));

    final colors = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.color)
        .whereType<Color>();

    expect(colors, contains(AppColors.light.given));
    expect(colors, contains(AppColors.light.received));
  });

  testWidgets('compact 모드에서도 상태 마커가 렌더된다', (tester) async {
    await tester.pumpWidget(
        wrap(const BalanceVisualization(tilt: 0.7, compact: true)));

    expect(markerColor(tester), AppColors.light.severe);
  });

  testWidgets('compact 모드는 트랙에 given/received 색을 쓰지 않는다(마커만 색상)',
      (tester) async {
    await tester.pumpWidget(
        wrap(const BalanceVisualization(tilt: 0.6, compact: true)));

    final colors = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.color)
        .whereType<Color>();

    expect(colors, isNot(contains(AppColors.light.given)));
    expect(colors, isNot(contains(AppColors.light.received)));
    expect(colors, contains(AppColors.light.borderSoft));
  });

  testWidgets('화살표 아이콘을 사용하지 않는다', (tester) async {
    await tester.pumpWidget(wrap(const BalanceVisualization(tilt: 0.5)));

    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    expect(find.byIcon(Icons.arrow_upward_outlined), findsNothing);
    expect(find.byIcon(Icons.arrow_downward_outlined), findsNothing);
  });
}
