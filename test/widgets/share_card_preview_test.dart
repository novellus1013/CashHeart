import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:cash_heart/widgets/share_card_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  const stats = RelationshipStats(received: 700000, given: 300000, count: 6);

  testWidgets('기본값(showAmount=false)은 총 거래 횟수만 보여주고 비율(%)·실제 금액은 노출하지 않는다',
      (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
    )));

    // useHonorific 기본값(true)이라 이름 뒤에 "님"이 붙는다.
    expect(find.text('김민준님'), findsOneWidget);
    expect(find.text('영혼의 동반자'), findsOneWidget);
    expect(find.textContaining('경조사비 주고받은 기록이에요'), findsOneWidget);
    expect(find.text('총 6번의 거래'), findsOneWidget);
    expect(find.textContaining('700000'), findsNothing);
    expect(find.textContaining('300000'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('useHonorific=false면 이름 뒤에 "님"을 붙이지 않는다', (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
      useHonorific: false,
    )));

    expect(find.text('김민준'), findsOneWidget);
    expect(find.text('김민준님'), findsNothing);
  });

  testWidgets('showAmount=true면 지인 이름을 주어로 한 "받은/주신 마음" 두 줄로 금액을 표시한다',
      (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
      showAmount: true,
    )));

    expect(find.textContaining('300,000'), findsOneWidget);
    expect(find.textContaining('700,000'), findsOneWidget);
    // given(내가 줌) = 상대가 "받은" 쪽, received(내가 받음) = 상대가 "주신" 쪽.
    expect(find.text('김민준님이 받은 마음'), findsOneWidget);
    expect(find.text('김민준님이 주신 마음'), findsOneWidget);
  });

  testWidgets('받침 없는 이름 + honorific 꺼짐이면 "가" 조사를 쓴다', (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '이서하',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
      showAmount: true,
      useHonorific: false,
    )));

    expect(find.text('이서하가 받은 마음'), findsOneWidget);
    expect(find.text('이서하가 주신 마음'), findsOneWidget);
  });

  testWidgets('로고와 브랜드 문구가 카드 안에서 한 번만 렌더된다', (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
    )));

    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('CashHeart'), findsOneWidget);
  });

  testWidgets('QR이 카드 이미지에 포함된다(카톡 등에서 caption 텍스트가 전달 안 되는 문제 대응)',
      (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
    )));

    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('아바타(이니셜 원)를 쓰지 않는다(사진이 없어 낯선 수신자에게 혼란만 준다는 지적)',
      (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.soulmate,
      cardTitle: '영혼의 동반자',
    )));

    // 로고 이미지 1개 외에는 원형 아바타(이니셜) 컨테이너가 없어야 한다.
    final circles = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle &&
            (c.constraints?.maxWidth ?? 0) > 20);
    expect(circles, isEmpty);
  });

  testWidgets('화살표 아이콘을 사용하지 않는다', (tester) async {
    await tester.pumpWidget(wrap(const ShareCardPreview(
      personName: '김민준',
      stats: stats,
      message: '테스트 메시지',
      caseType: ShareCardCase.oneWayGiven,
      cardTitle: '기부천사',
    )));

    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
  });
}
