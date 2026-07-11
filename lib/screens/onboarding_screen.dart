import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/screens/main_shell_screen.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/widgets/avatar.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:cash_heart/widgets/stream_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OnboardingSlide {
  final String title;
  final String description;
  final WidgetBuilder previewBuilder;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.previewBuilder,
  });
}

/// 정적 셸 — 신규 설치 2-슬라이드 온보딩. 각 슬라이드는 실제 앱 화면을 축소한
/// 미니 프리뷰로 보여준다(2026-07-11 검수: 추상 아이콘 대신 실제 화면 느낌).
/// 카드 공유 소개 슬라이드는 실제로 작동하지 않는 기능(공유 액션 미구현, Sprint 4
/// 소유)을 온보딩에서 약속하는 셈이라 제거했다 — 관련 안내는 Report 화면으로 이동.
/// "다음부터 보지 않기"를 체크하지 않으면 다음 실행 때도 다시 노출된다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const _dismissedPrefKey = 'onboarding_dismissed';

  static Future<bool> hasDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dismissedPrefKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;
  bool _dontShowAgain = false;

  late final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: '경조사를 관계별로 정리하세요',
      description: '흩어진 기록을 사람별로 모아\n관계의 흐름을 한곳에서 봐요.',
      previewBuilder: (context) => const _PersonListPreview(),
    ),
    _OnboardingSlide(
      title: '받은 마음, 보낸 마음을 한눈에',
      description: '오고 간 정(情)의 균형을\n관찰자 시점으로 보여드려요.',
      previewBuilder: (context) => const _StreamPreview(),
    ),
  ];

  Future<void> _finish() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OnboardingScreen._dismissedPrefKey, true);
    }

    if (!mounted) return;

    // 매번 하단 SnackBar로 뜨는 게 번거롭다는 피드백(2026-07-11)으로
    // 건너뛰기/시작하기를 누른 시점에 짧게 자동으로 사라지는 팝업으로 교체.
    await _showDismissHint();
    if (!mounted) return;

    // Settings에서 "다시 보기"로 들어온 경우엔 뒤로가기 스택이 있으므로 pop,
    // 최초 실행(뒤로갈 곳 없음)인 경우엔 MainShellScreen으로 교체한다.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  Future<void> _showDismissHint() async {
    final colors = Theme.of(context).extension<AppColors>()!;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.size16),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.size24,
              vertical: Sizes.size18,
            ),
            child: Text(
              '온보딩은 설정에서 언제든 다시 볼 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Sizes.size14, color: colors.text),
            ),
          ),
        );
      },
    );
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
    } else {
      setState(() => _index += 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final slide = _slides[_index];
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 220,
                      child: Center(child: slide.previewBuilder(context)),
                    ),
                    Gaps.v28,
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    Gaps.v12,
                    Text(
                      slide.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, color: colors.text2, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Sizes.size24,
                0,
                Sizes.size24,
                Sizes.size16,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: i == _index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index ? colors.primary : colors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (i != _slides.length - 1) Gaps.h7,
                      ],
                    ],
                  ),
                  Gaps.v12,
                  GestureDetector(
                    onTap: () =>
                        setState(() => _dontShowAgain = !_dontShowAgain),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _dontShowAgain,
                            onChanged: (value) =>
                                setState(() => _dontShowAgain = value ?? false),
                            activeColor: colors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Gaps.h8,
                        Text(
                          '다음부터 보지 않기',
                          style: TextStyle(fontSize: 13, color: colors.text2),
                        ),
                      ],
                    ),
                  ),
                  Gaps.v12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          '건너뛰기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.text3,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _next,
                        child: Text(isLast ? '시작하기' : '다음'),
                      ),
                    ],
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

/// 슬라이드 1 미리보기 — Home 지인 목록의 미니어처.
class _PersonListPreview extends StatelessWidget {
  const _PersonListPreview();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    const rows = [
      (name: '김서연', tint: 0, category: '친구', tilt: 0.1),
      (name: '박준호', tint: 1, category: '직장', tilt: -0.6),
      (name: '이지은', tint: 2, category: '가족', tilt: 0.05),
    ];

    return Container(
      width: 260,
      padding: EdgeInsets.all(Sizes.size14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          for (final row in rows) ...[
            Row(
              children: [
                Avatar(name: row.name, tintSeed: row.tint, size: 32),
                Gaps.h10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      Gaps.v4,
                      SizedBox(
                        width: 56,
                        child:
                            BalanceVisualization(tilt: row.tilt, compact: true),
                      ),
                    ],
                  ),
                ),
                Text(row.category,
                    style: TextStyle(fontSize: 12, color: colors.text3)),
              ],
            ),
            if (row != rows.last) Gaps.v10,
          ],
        ],
      ),
    );
  }
}

/// 슬라이드 2 미리보기 — Person Detail의 StreamChart 미니어처.
class _StreamPreview extends StatelessWidget {
  const _StreamPreview();

  static final List<Gift> _sampleGifts = [
    Gift(
        personId: 0,
        amount: 50000,
        direction: GiftDirection.received,
        category: GiftCategory.wedding,
        date: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        note: ''),
    Gift(
        personId: 0,
        amount: 30000,
        direction: GiftDirection.given,
        category: GiftCategory.birthday,
        date: DateTime(2024, 4, 1).millisecondsSinceEpoch,
        note: ''),
    Gift(
        personId: 0,
        amount: 70000,
        direction: GiftDirection.received,
        category: GiftCategory.anniversary,
        date: DateTime(2024, 8, 1).millisecondsSinceEpoch,
        note: ''),
    Gift(
        personId: 0,
        amount: 20000,
        direction: GiftDirection.given,
        category: GiftCategory.etc,
        date: DateTime(2024, 12, 1).millisecondsSinceEpoch,
        note: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      width: 260,
      padding: EdgeInsets.all(Sizes.size16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '김서연님과의 흐름',
            style: TextStyle(fontSize: 12.5, color: colors.text2),
          ),
          Gaps.v8,
          SizedBox(height: 108, child: StreamChart(gifts: _sampleGifts)),
        ],
      ),
    );
  }
}
