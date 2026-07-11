import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/providers/report_view_model.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:cash_heart/widgets/donut_chart.dart';
import 'package:cash_heart/widgets/trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().loadReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '리포트',
          style: TextStyle(fontSize: Sizes.size18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // 하단 floating PillNav(MainShellScreen)에 가리지 않도록 여백 확보.
              padding: EdgeInsets.only(bottom: Sizes.size96 + Sizes.size24),
              child: Column(
                children: [
                  _NetSummaryCard(
                    totalGiven: vm.totalGiven,
                    totalReceived: vm.totalReceived,
                  ),
                  _TrendAnalysisSection(monthlyData: vm.monthlyData),
                  _TopCategoriesSection(
                    categoryData: vm.categoryData,
                    topCategory: vm.topCategory,
                  ),
                  _GiveTakeSection(
                    topGivers: vm.topGivers,
                    topReceivers: vm.topReceivers,
                  ),
                  _LeaningSection(
                    givenLeaning: vm.givenLeaning,
                    receivedLeaning: vm.receivedLeaning,
                  ),
                  _InsightSection(
                    icon: Icons.favorite_border,
                    iconColor:
                        Theme.of(context).extension<AppColors>()!.secondary,
                    title: '가장 많이 나눈 사람',
                    rows: vm.mostFrequent,
                    noteOf: (stats) => frequencyNote(stats.count),
                  ),
                  _SeasonalitySection(
                    monthlyTotals: vm.monthlyHistoryTotals,
                    peakMonths: vm.peakMonths,
                  ),
                  _YoyComparisonSection(changePercent: vm.yoyChangePercent),
                  const _CardShareTeaser(),
                  Gaps.v32,
                ],
              ),
            ),
    );
  }
}

/// 전체 기간 순잔액 통합 카드 — 받은/준 마음을 세로 구분선으로 나란히 보여준다
/// (2026-07-11 검수: 기존 2개 분리 카드 대신 하나로 통합).
class _NetSummaryCard extends StatelessWidget {
  final int totalGiven;
  final int totalReceived;

  const _NetSummaryCard({
    required this.totalGiven,
    required this.totalReceived,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final net = totalReceived - totalGiven;
    final netColor = net >= 0 ? colors.received : colors.given;

    return Padding(
      padding: const EdgeInsets.all(Sizes.size20),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 기간 순잔액',
              style: TextStyle(fontSize: Sizes.size14, color: colors.text2),
            ),
            Gaps.v8,
            Text(
              MoneyFormatter.formatCurrency(net, 'ko_KR', '₩'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: netColor,
              ),
            ),
            Gaps.v20,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _AmountColumn(
                      label: '받은 마음',
                      amount: totalReceived,
                      color: colors.received,
                    ),
                  ),
                  Container(width: 1, color: colors.borderSoft),
                  Gaps.h20,
                  Expanded(
                    child: _AmountColumn(
                      label: '준 마음',
                      amount: totalGiven,
                      color: colors.given,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final bool alignEnd;

  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Sizes.size12, color: colors.text2),
        ),
        Gaps.v4,
        Text(
          MoneyFormatter.formatCurrency(amount, 'ko_KR', '₩'),
          style: TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TrendAnalysisSection extends StatelessWidget {
  final List<MonthlyData> monthlyData;

  const _TrendAnalysisSection({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.size20),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 6개월 거래 내역',
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                Row(
                  children: [
                    _LegendItem(color: colors.given, label: '준 마음'),
                    Gaps.h12,
                    _LegendItem(color: colors.received, label: '받은 마음'),
                  ],
                ),
              ],
            ),
            Gaps.v16,
            if (monthlyData.isEmpty)
              SizedBox(
                height: 130,
                child: Center(
                  child:
                      Text('데이터가 없습니다', style: TextStyle(color: colors.text3)),
                ),
              )
            else
              TrendChart(
                months: monthlyData
                    .map((m) => TrendChartPoint(
                          label: m.label,
                          given: m.given,
                          received: m.received,
                        ))
                    .toList(),
                receivedColor: colors.received,
                givenColor: colors.given,
                gridColor: colors.borderSoft,
                labelColor: colors.text3,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Gaps.h4,
        Text(label,
            style: TextStyle(fontSize: Sizes.size12, color: colors.text3)),
      ],
    );
  }
}

// 도넛 차트 화면
class _TopCategoriesSection extends StatelessWidget {
  final List<CategoryData> categoryData;
  final String? topCategory;

  const _TopCategoriesSection({
    required this.categoryData,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.all(Sizes.size20),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '경조사 분포',
              style: TextStyle(
                fontSize: Sizes.size18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Gaps.v16,
            Row(
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      DonutChart(
                        size: 128,
                        thickness: 16,
                        trackColor: colors.borderSoft,
                        slices: categoryData
                            .map((d) =>
                                DonutSlice(value: d.percentage, color: d.color))
                            .toList(),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                            color: colors.surface, shape: BoxShape.circle),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '최다',
                              style: TextStyle(
                                fontSize: Sizes.size12,
                                color: colors.text3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              topCategory ?? '-',
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.h32,
                Expanded(
                  child: Column(
                    children: categoryData
                        .map((data) => _CategoryLegendItem(data: data))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final CategoryData data;

  const _CategoryLegendItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.size6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: data.color, shape: BoxShape.circle),
          ),
          Gaps.h8,
          Expanded(
            child: Text(
              data.category,
              style: TextStyle(
                fontSize: Sizes.size14,
                color: colors.text2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            MoneyFormatter.formatWonShort(data.totalAmount),
            style: TextStyle(
              fontSize: Sizes.size14,
              fontWeight: FontWeight.bold,
              color: colors.text3,
            ),
          ),
        ],
      ),
    );
  }
}

/// "기브 앤 테이크" 랭킹 — 준/받은 마음 절대 금액 top3를 나란히 보여준다
/// (2026-07-11 추가, AI 추천 리포트 항목 반영).
class _GiveTakeSection extends StatelessWidget {
  final List<PersonRelationshipStats> topGivers;
  final List<PersonRelationshipStats> topReceivers;

  const _GiveTakeSection({required this.topGivers, required this.topReceivers});

  @override
  Widget build(BuildContext context) {
    if (topGivers.isEmpty && topReceivers.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '많이 나눈 마음 순위',
              style: TextStyle(
                fontSize: Sizes.size18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Gaps.v16,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _RankColumn(
                      label: '가장 많이 전한 사람',
                      color: colors.given,
                      rows: topGivers,
                      amountOf: (s) => s.given,
                    ),
                  ),
                  Gaps.h16,
                  Container(width: 1, color: colors.borderSoft),
                  Gaps.h16,
                  Expanded(
                    child: _RankColumn(
                      label: '가장 많이 받은 사람',
                      color: colors.received,
                      rows: topReceivers,
                      amountOf: (s) => s.received,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<PersonRelationshipStats> rows;
  final int Function(RelationshipStats stats) amountOf;

  const _RankColumn({
    required this.label,
    required this.color,
    required this.rows,
    required this.amountOf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: colors.text3),
        ),
        Gaps.v10,
        if (rows.isEmpty)
          Text('아직 기록이 없어요',
              style: TextStyle(fontSize: 12, color: colors.text3))
        else
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              children: [
                SizedBox(
                  width: Sizes.size16,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.text3),
                  ),
                ),
                Avatar(
                    name: rows[i].person.name,
                    tintSeed: rows[i].person.id ?? 0,
                    size: 24),
                Gaps.h8,
                Expanded(
                  child: Text(
                    rows[i].person.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text),
                  ),
                ),
              ],
            ),
            Gaps.v4,
            Text(
              MoneyFormatter.formatWonShort(amountOf(rows[i].stats)),
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
            if (i != rows.length - 1) Gaps.v10,
          ],
      ],
    );
  }
}

/// 마음이 어느 방향으로 더 흘렀는지 — tilt 기준 상위 관계(2026-07-11 추가).
/// copy-tone.md 준수: "적자/흑자" 같은 판단적 표현 대신 방향 사실만 전달.
class _LeaningSection extends StatelessWidget {
  final List<PersonRelationshipStats> givenLeaning;
  final List<PersonRelationshipStats> receivedLeaning;

  const _LeaningSection({
    required this.givenLeaning,
    required this.receivedLeaning,
  });

  @override
  Widget build(BuildContext context) {
    if (givenLeaning.isEmpty && receivedLeaning.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '마음이 향한 방향',
              style: TextStyle(
                fontSize: Sizes.size18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Gaps.v4,
            Text('흐름의 방향만 보여드려요.',
                style: TextStyle(fontSize: 12, color: colors.text3)),
            Gaps.v16,
            if (givenLeaning.isNotEmpty) ...[
              _LeaningGroup(label: '내가 더 많이 전한 관계', rows: givenLeaning),
              if (receivedLeaning.isNotEmpty) Gaps.v16,
            ],
            if (receivedLeaning.isNotEmpty)
              _LeaningGroup(label: '내가 더 많이 받은 관계', rows: receivedLeaning),
          ],
        ),
      ),
    );
  }
}

class _LeaningGroup extends StatelessWidget {
  final String label;
  final List<PersonRelationshipStats> rows;

  const _LeaningGroup({required this.label, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: colors.text3),
        ),
        Gaps.v8,
        for (final row in rows) ...[
          _InsightRow(entry: row, note: tiltDirectionNote(row.stats.tilt)),
          Gaps.v8,
        ],
      ],
    );
  }
}

/// 월별(연도 무관) 누적 총액 막대 + 피크 시즌 문구(2026-07-11 추가).
class _SeasonalitySection extends StatelessWidget {
  final List<int> monthlyTotals;
  final List<int> peakMonths;

  const _SeasonalitySection({
    required this.monthlyTotals,
    required this.peakMonths,
  });

  @override
  Widget build(BuildContext context) {
    if (!monthlyTotals.any((v) => v > 0)) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<AppColors>()!;
    final note = peakSeasonNote(peakMonths);
    final maxV = monthlyTotals.fold<int>(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '경조사가 몰리는 시기',
              style: TextStyle(
                fontSize: Sizes.size18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Gaps.v4,
            Text(
              '지금까지 기록된 모든 내역을 월별로 합산한 기준이에요.',
              style: TextStyle(fontSize: 12, color: colors.text3),
            ),
            if (note != null) ...[
              Gaps.v6,
              Text(note, style: TextStyle(fontSize: 13, color: colors.text2)),
            ],
            Gaps.v16,
            SizedBox(
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 12; i++) ...[
                    Expanded(
                      child: Container(
                        height: maxV == 0
                            ? 4.0
                            : (monthlyTotals[i] / maxV) * 64 + 4,
                        decoration: BoxDecoration(
                          color: peakMonths.contains(i + 1)
                              ? colors.secondary
                              : colors.borderSoft,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i != 11) Gaps.h2,
                  ],
                ],
              ),
            ),
            Gaps.v6,
            Row(
              children: [
                for (var m = 1; m <= 12; m++)
                  Expanded(
                    child: Center(
                      child: Text('$m',
                          style: TextStyle(fontSize: 9, color: colors.text3)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 올해 누적 vs 작년 동기간 비교(2026-07-11 추가).
class _YoyComparisonSection extends StatelessWidget {
  final double? changePercent;

  const _YoyComparisonSection({required this.changePercent});

  @override
  Widget build(BuildContext context) {
    final percent = changePercent;
    if (percent == null) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Sizes.size16),
          border: Border.all(color: colors.borderSoft),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                color: colors.secondary, size: 22),
            Gaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '작년과 비교하면',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.text3),
                  ),
                  Gaps.v4,
                  Text(
                    yoyNote(percent),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// design_handoff `InsightGroup` 이식 — person별 인사이트 리스트 공용 렌더러.
class _InsightSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<PersonRelationshipStats> rows;
  final String Function(RelationshipStats stats) noteOf;

  const _InsightSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.rows,
    required this.noteOf,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              Gaps.h8,
              Text(
                title,
                style: TextStyle(
                  fontSize: Sizes.size18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          Gaps.v12,
          for (final row in rows) ...[
            _InsightRow(entry: row, note: noteOf(row.stats)),
            Gaps.v10,
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final PersonRelationshipStats entry;
  final String note;

  const _InsightRow({required this.entry, required this.note});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = entry.stats.state;

    return Container(
      padding: const EdgeInsets.all(Sizes.size14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Sizes.size12),
        border: Border.all(color: colors.borderSoft),
      ),
      child: Row(
        children: [
          Avatar(
              name: entry.person.name,
              tintSeed: entry.person.id ?? 0,
              size: 36),
          Gaps.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.person.name,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                Gaps.v4,
                SizedBox(
                  width: 80,
                  child: BalanceVisualization(
                      tilt: entry.stats.tilt, compact: true),
                ),
              ],
            ),
          ),
          Text(
            note,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: state.color(colors),
            ),
          ),
        ],
      ),
    );
  }
}

/// 온보딩 슬라이드에 있던 카드 공유 소개를 대신하는 안내 배너(2026-07-11).
/// 실제 공유 액션은 아직 스텁이라(person_detail_screen._onCardShare와 동일 문구),
/// 여기서도 "다음 업데이트" 안내만 보여준다 — 과장 없이 준비 중임을 알린다.
class _CardShareTeaser extends StatelessWidget {
  const _CardShareTeaser();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Material(
        color: colors.secondarySoft,
        borderRadius: BorderRadius.circular(Sizes.size16),
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.size16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('카드 공유는 다음 업데이트에서 만나요.')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(Sizes.size16),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: colors.secondary),
                Gaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '함께한 시간을 카드로 나눠보세요',
                        style: TextStyle(
                          fontSize: Sizes.size14,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      Gaps.v2,
                      Text(
                        '준비 중이에요. 곧 만나요.',
                        style: TextStyle(
                            fontSize: Sizes.size12, color: colors.text3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: Sizes.size20, color: colors.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
