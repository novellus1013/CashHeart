import 'package:cash_heart/config/app_version.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/providers/report_view_model.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/home_screen.dart';
import 'package:cash_heart/screens/onboarding_screen.dart';
import 'package:cash_heart/screens/report_screen.dart';
import 'package:cash_heart/screens/setting_screen.dart';
import 'package:cash_heart/widgets/pill_nav.dart';
import 'package:cash_heart/widgets/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈/리포트/설정 하단 PillNav 셸. main.dart의 진입점이 이 화면으로 바뀐다.
/// Report 탭의 [ReportViewModel]은 셸 범위(셸이 살아있는 동안 유지)로 scoping해
/// 탭을 오갈 때마다 다시 로드하지 않는다(GiftViewModel처럼 페이지 단위가 아니라
/// 셸 단위 scoping — CLAUDE.md의 "페이지 범위 scoping" 원칙을 셸 단위로 확장).
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;
  late final ReportViewModel _reportVm;
  PersonViewModel? _personVm;

  static const _items = [
    PillNavItem(icon: Icons.home_outlined, label: '홈'),
    PillNavItem(icon: Icons.bar_chart_outlined, label: '통계'),
    PillNavItem(icon: Icons.settings_outlined, label: '설정'),
  ];

  @override
  void initState() {
    super.initState();
    _reportVm = ReportViewModel(
      GiftRepository.instance,
      PersonRepository.instance,
    )..loadReportData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 리포트 숫자가 실시간으로 반영되지 않던 버그(2026-07-11 검수) 픽스 —
    // Home의 기존 해법(PersonViewModel 리스너)과 동일한 패턴. Provider 자체의
    // 한계가 아니라 리포트가 탭 최초 진입 시 한 번만 로드되고 이후 다른 화면의
    // 변경을 구독하지 않던 배선 누락이 원인이었다(Riverpod 전환 불필요).
    final personVm = context.read<PersonViewModel>();
    if (_personVm != personVm) {
      _personVm?.removeListener(_onPersonVmChanged);
      _personVm = personVm;
      _personVm!.addListener(_onPersonVmChanged);
    }
  }

  void _onPersonVmChanged() {
    _reportVm.loadReportData();
  }

  // 최초 실행(또는 "다음부터 보지 않기" 미체크 상태)이면 온보딩을 먼저 보여주고,
  // 온보딩이 끝난 뒤에 업데이트 안내를 확인한다(동시에 두 다이얼로그/화면이
  // 겹치지 않도록 순차 진행).
  Future<void> _maybeShowOnboarding() async {
    final dismissed = await OnboardingScreen.hasDismissed();
    if (!mounted) return;

    if (!dismissed) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      if (!mounted) return;
    }

    await _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted || info.version == AppVersion.latest) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(
        variant: UpdateDialogVariant.recommended,
        onUpdate: () async {
          await launchUrl(
            Uri.parse(AppVersion.playStoreUrl),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _personVm?.removeListener(_onPersonVmChanged);
    _reportVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 시스템 네비게이션 바 색 지정은 main.dart의 MaterialApp.builder에서
    // 전역으로 처리한다(push된 화면까지 일괄 적용하기 위해, 2026-07-11).
    return ChangeNotifierProvider.value(
      value: _reportVm,
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                ReportScreen(),
                SettingScreen(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              // 시스템 네비게이션 바 인셋(제스처 바/3버튼 바 높이)을 더하지
              // 않으면 PillNav 하단이 시스템 바에 가려 반쯤 잘려 보인다
              // (2026-07-11 실기기 피드백).
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: Center(
                child: PillNav(
                  items: _items,
                  selectedIndex: _index,
                  onTap: (index) => setState(() => _index = index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
