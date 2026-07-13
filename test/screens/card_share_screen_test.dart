import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/screens/card_share_screen.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stats = RelationshipStats(received: 700000, given: 300000, count: 6);

  Widget buildScreen() {
    return MaterialApp(
      theme: AppTheme.light(),
      home: const CardShareScreen(
        personName: '김민준',
        stats: stats,
        caseType: ShareCardCase.soulmate,
      ),
    );
  }

  // 실제 금액 토글(SwitchListTile) 추가로 콘텐츠가 길어져 기본 테스트 뷰포트에서는
  // TextFormField가 화면 밖으로 밀려 ListView의 sliver가 마운트하지 않는다 —
  // 뷰포트를 키워 모든 콘텐츠가 한 화면에 들어오게 한다.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('템플릿 로드 후 칭호와 초기 메시지가 채워진 TextFormField를 보여준다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('영혼의 동반자'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, isNotEmpty);
  });

  testWidgets('"다른 문구" 버튼을 누르면 메시지가 바뀐다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    final before =
        tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text;

    // 후보가 20개라 재시도 몇 번으로도 충분히 바뀜을 확인한다(같은 값이 다시 뽑힐 수 있는
    // pickRandomMessage의 exclude 보장과 별개로, 실제 위젯 파이프라인 상 상태 갱신 검증).
    await tester.tap(find.text('다른 문구'));
    await tester.pumpAndSettle();

    final after =
        tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text;

    expect(after, isNot(before));
  });

  testWidgets('TextFormField를 직접 편집하면 카드 미리보기 메시지도 바뀐다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '직접 쓴 메시지');
    await tester.pumpAndSettle();

    expect(find.text('직접 쓴 메시지'), findsWidgets);
  });

  testWidgets('실제 금액 표시 토글은 기본 켜짐이고, 끄면 카드에서 금액이 사라진다',
      (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('300,000'), findsOneWidget);
    expect(find.textContaining('700,000'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, '실제 금액 표시'));
    await tester.pumpAndSettle();

    expect(find.textContaining('300,000'), findsNothing);
    expect(find.textContaining('700,000'), findsNothing);
  });

  testWidgets('존칭 토글은 기본 켜짐(님)이고, 끄면 이름에서 "님"이 빠진다', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('김민준님'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, '존칭 사용 (이름 뒤 "님")'));
    await tester.pumpAndSettle();

    expect(find.text('김민준님'), findsNothing);
    expect(find.text('김민준'), findsOneWidget);
  });
}
