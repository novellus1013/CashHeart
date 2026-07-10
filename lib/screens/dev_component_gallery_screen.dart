import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:cash_heart/widgets/hero_card.dart';
import 'package:cash_heart/widgets/pill_nav.dart';
import 'package:cash_heart/widgets/relationship_row.dart';
import 'package:flutter/material.dart';

/// Sprint 2 Phase B 시안 검수용 — AppConfig.isDev에서만 접근 가능.
/// 4개 신규 컴포넌트를 라이트/다크(현재 테마 따름) × balanced/tilted/severe × 큰 금액 케이스로 모아 보여준다.
class DevComponentGalleryScreen extends StatefulWidget {
  const DevComponentGalleryScreen({super.key});

  @override
  State<DevComponentGalleryScreen> createState() =>
      _DevComponentGalleryScreenState();
}

class _DevComponentGalleryScreenState
    extends State<DevComponentGalleryScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('컴포넌트 갤러리 (dev)')),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(Sizes.size20).copyWith(bottom: Sizes.size96),
            children: [
              _SectionTitle('HeroCard'),
              Gaps.v12,
              HeroCard(
                label: '오고 간 정(情) · 순잔액',
                netAmount: 320000,
                givenAmount: 540000,
                receivedAmount: 860000,
              ),
              Gaps.v16,
              Text(
                '10자리 이상 금액 (부록 A 축약 확인)',
                style: AppTextStyles.caption.copyWith(color: colors.text3),
              ),
              Gaps.v8,
              HeroCard(
                label: '오고 간 정(情) · 순잔액',
                netAmount: 1234567890,
                givenAmount: 500000000,
                receivedAmount: 1734567890,
              ),
              Gaps.v32,
              _SectionTitle('BalanceVisualization'),
              Gaps.v12,
              _BalanceStateSample(tilt: 0.1, expected: 'balanced'),
              Gaps.v16,
              _BalanceStateSample(tilt: 0.35, expected: 'tilted'),
              Gaps.v16,
              _BalanceStateSample(tilt: 0.7, expected: 'severe'),
              Gaps.v32,
              _SectionTitle('RelationshipRow'),
              Gaps.v12,
              RelationshipRow(
                name: '김민준',
                categoryLabel: '친구',
                categoryColor: getCategoryColor('친구'),
                metaText: '5년간 9번의 마음 · 1주 전',
                netAmountText: '+ ₩ 320,000',
                tilt: 0.1,
              ),
              Gaps.v12,
              RelationshipRow(
                name: '이서연',
                categoryLabel: '가족',
                categoryColor: getCategoryColor('가족'),
                metaText: '3년간 4번의 마음 · 2개월 전',
                netAmountText: '- ₩ 150,000',
                tilt: 0.35,
              ),
              Gaps.v12,
              RelationshipRow(
                name: '박지훈',
                categoryLabel: '직장',
                categoryColor: getCategoryColor('직장'),
                metaText: '1년간 2번의 마음 · 6개월 전',
                netAmountText: '- ₩ 1,234,567,890',
                tilt: -0.8,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Sizes.size24,
            child: Column(
              children: [
                // PillNav는 순수 표시 컴포넌트라 실제 화면 전환은 Sprint 3에서 연결된다.
                // 탭이 눌렸는지 갤러리에서 바로 확인할 수 있도록 선택 상태만 표시.
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.size12,
                    vertical: Sizes.size4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(Sizes.size10),
                  ),
                  child: Text(
                    '선택된 탭: ${const ["홈", "리포트", "설정"][_navIndex]} '
                    '(실제 화면 전환은 Sprint 3에서 연결)',
                    style:
                        AppTextStyles.caption.copyWith(color: colors.text3),
                  ),
                ),
                Gaps.v8,
                PillNav(
                  items: const [
                    PillNavItem(icon: Icons.home_outlined, label: '홈'),
                    PillNavItem(icon: Icons.bar_chart_outlined, label: '리포트'),
                    PillNavItem(icon: Icons.settings_outlined, label: '설정'),
                  ],
                  selectedIndex: _navIndex,
                  onTap: (index) => setState(() => _navIndex = index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStateSample extends StatelessWidget {
  final double tilt;
  final String expected;

  const _BalanceStateSample({required this.tilt, required this.expected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tilt=$tilt (예상: $expected)',
          style: AppTextStyles.caption.copyWith(color: colors.text3),
        ),
        Gaps.v4,
        BalanceVisualization(tilt: tilt),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(color: colors.text),
    );
  }
}
