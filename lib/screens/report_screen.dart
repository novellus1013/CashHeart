import 'dart:math' as math;

import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/report_view_model.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
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
          style: TextStyle(
            fontSize: Sizes.size18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Total Given / Total Received Section
                  _TotalCardsSection(
                    totalGiven: vm.totalGiven,
                    totalReceived: vm.totalReceived,
                  ),
                  // Trend Analysis Section
                  _TrendAnalysisSection(monthlyData: vm.monthlyData),
                  // Top Categories Section
                  _TopCategoriesSection(
                    categoryData: vm.categoryData,
                    topCategory: vm.topCategory,
                  ),
                  // Top Gratitude Section
                  _TopGratitudeSection(topGratitude: vm.topGratitude),
                  // Top Generosity Section
                  _TopGenerositySection(topGenerosity: vm.topGenerosity),
                  Gaps.v32,
                ],
              ),
            ),
    );
  }
}

// 총액 카드 화면
class _TotalCardsSection extends StatelessWidget {
  final int totalGiven;
  final int totalReceived;

  const _TotalCardsSection({
    required this.totalGiven,
    required this.totalReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.size20),
      child: Row(
        children: [
          Expanded(
            child: _TotalCard(
              title: '보낸 금액',
              amount: totalGiven,
              icon: Icons.output,
              color: secondaryColor,
              borderColor: const Color(0xFFDBEAFE),
              iconBgColor: const Color(0xFFDBEAFE),
            ),
          ),
          Gaps.h16,
          Expanded(
            child: _TotalCard(
              title: '받은 금액',
              amount: totalReceived,
              icon: Icons.input,
              color: primaryColor,
              borderColor: const Color(0xFFFEE2E2),
              iconBgColor: const Color(0xFFFEE2E2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final Color iconBgColor;

  const _TotalCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount =
        MoneyFormatter.formatCurrency(amount, 'ko_KR', '\u20A9');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Sizes.size20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Sizes.size16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Sizes.size6),
                decoration: BoxDecoration(
                  color: isDark ? color.withValues(alpha: 0.2) : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: Sizes.size20, color: color),
              ),
              Gaps.h8,
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gaps.v12,
          Text(
            formattedAmount,
            style: const TextStyle(
              fontSize: Sizes.size20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

//막대 차트 화면
class _TrendAnalysisSection extends StatelessWidget {
  final List<MonthlyData> monthlyData;

  const _TrendAnalysisSection({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.size20),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Sizes.size16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '추세 분석',
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _LegendItem(color: secondaryColor, label: '보냄'),
                    Gaps.h12,
                    _LegendItem(color: primaryColor, label: '받음'),
                  ],
                ),
              ],
            ),
            Gaps.v16,
            // Bar Chart
            SizedBox(
              height: 192,
              child: _BarChart(monthlyData: monthlyData),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Gaps.h4,
        Text(
          label,
          style: TextStyle(
            fontSize: Sizes.size12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<MonthlyData> monthlyData;

  const _BarChart({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (monthlyData.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      );
    }

    // 최대값 계산
    int maxValue = 0;
    for (final data in monthlyData) {
      maxValue = math.max(maxValue, math.max(data.given, data.received));
    }
    if (maxValue == 0) maxValue = 1;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: monthlyData.map((data) {
              final givenHeight = (data.given / maxValue) * 100;
              final receivedHeight = (data.received / maxValue) * 100;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bar(
                          height: givenHeight,
                          color: secondaryColor,
                        ),
                        Gaps.h2,
                        _Bar(
                          height: receivedHeight,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    Gaps.v8,
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: Sizes.size12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Container(
          height: 1,
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;

  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: math.max(height, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }
}

//도넛 차트 화면
class _TopCategoriesSection extends StatelessWidget {
  final List<CategoryData> categoryData;
  final String? topCategory;

  const _TopCategoriesSection({
    required this.categoryData,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.size20),
      child: Container(
        padding: const EdgeInsets.all(Sizes.size24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Sizes.size16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 통계',
              style: TextStyle(
                fontSize: Sizes.size18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gaps.v16,
            Row(
              children: [
                // Donut Chart
                _DonutChart(
                  categoryData: categoryData,
                  topCategory: topCategory,
                ),
                Gaps.h32,
                // Legend
                Expanded(
                  child: Column(
                    children: categoryData
                        .take(4)
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

class _DonutChart extends StatelessWidget {
  final List<CategoryData> categoryData;
  final String? topCategory;

  const _DonutChart({
    required this.categoryData,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(128, 128),
            painter:
                _DonutChartPainter(categoryData: categoryData, isDark: isDark),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '최다',
                  style: TextStyle(
                    fontSize: Sizes.size12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  topCategory ?? '-',
                  style: const TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryData> categoryData;
  final bool isDark;

  _DonutChartPainter({required this.categoryData, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 16.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -math.pi / 2;

    if (categoryData.isEmpty) {
      paint.color = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    for (final data in categoryData) {
      final sweepAngle = (data.percentage / 100) * 2 * math.pi;
      paint.color = data.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CategoryLegendItem extends StatelessWidget {
  final CategoryData data;

  const _CategoryLegendItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.size6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          Gaps.h8,
          Expanded(
            child: Text(
              data.category,
              style: TextStyle(
                fontSize: Sizes.size14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${data.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: Sizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//가장 많이 받은 사람
class _TopGratitudeSection extends StatelessWidget {
  final List<PersonBalance> topGratitude;

  const _TopGratitudeSection({required this.topGratitude});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.size20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size4),
            child: Row(
              children: [
                const Icon(Icons.diversity_1, color: primaryColor, size: 20),
                Gaps.h8,
                const Text(
                  '가장 많이 받은 분',
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '받은 금액 기준',
                  style: TextStyle(
                    fontSize: Sizes.size12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Gaps.v12,
          if (topGratitude.isEmpty)
            _EmptyCard(message: '데이터가 없습니다')
          else
            ...topGratitude.map(
              (pb) => _PersonBalanceCard(
                personBalance: pb,
                isGratitude: true,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Top Generosity Section
// ============================================================================
class _TopGenerositySection extends StatelessWidget {
  final List<PersonBalance> topGenerosity;

  const _TopGenerositySection({required this.topGenerosity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Sizes.size20, Sizes.size16, Sizes.size20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size4),
            child: Row(
              children: [
                const Icon(Icons.volunteer_activism,
                    color: secondaryColor, size: 20),
                Gaps.h8,
                const Text(
                  '가장 많이 보낸 분',
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '보낸 금액 기준',
                  style: TextStyle(
                    fontSize: Sizes.size12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Gaps.v12,
          if (topGenerosity.isEmpty)
            _EmptyCard(message: '데이터가 없습니다')
          else
            ...topGenerosity.map(
              (pb) => _PersonBalanceCard(
                personBalance: pb,
                isGratitude: false,
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonBalanceCard extends StatelessWidget {
  final PersonBalance personBalance;
  final bool isGratitude;

  const _PersonBalanceCard({
    required this.personBalance,
    required this.isGratitude,
  });

  @override
  Widget build(BuildContext context) {
    final person = personBalance.person;
    final netBalance = personBalance.netBalance;
    final color = isGratitude ? primaryColor : secondaryColor;
    final initials = _getInitials(person.category ?? person.name);
    final formattedBalance = MoneyFormatter.formatCurrency(
      netBalance.abs(),
      'ko_KR',
      isGratitude ? '+\u20A9' : '-\u20A9',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.size12),
      padding: const EdgeInsets.all(Sizes.size16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Sizes.size12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? color.withValues(alpha: 0.2)
                  : (isGratitude
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFFEE2E2)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: Sizes.size14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          Gaps.h12,
          // Name and Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (person.note != null)
                  Text(
                    person.note!,
                    style: TextStyle(
                      fontSize: Sizes.size12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          // Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedBalance,
                style: TextStyle(
                  fontSize: Sizes.size14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sizes.size24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Sizes.size12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: Sizes.size14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
