import 'package:cash_heart/config/app_config.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:cash_heart/screens/dev_component_gallery_screen.dart';
import 'package:cash_heart/screens/person_detail_screen.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/app_bottom_sheet.dart';
import 'package:cash_heart/widgets/app_chip.dart';
import 'package:cash_heart/widgets/hero_card.dart';
import 'package:cash_heart/widgets/pill_nav.dart';
import 'package:cash_heart/widgets/relationship_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const List<String> _periods = ['1개월', '3개월', '6개월', '1년', '전체'];
const Map<String, int> _periodCutoffDays = {
  '1개월': 30,
  '3개월': 91,
  '6개월': 182,
  '1년': 365,
};

String _periodLabel(String period) => period == '전체' ? '전체 기간' : '최근 $period';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  String _period = _periods.first;
  int? _periodGiven;
  int? _periodReceived;
  bool _periodInitialized = false;
  PersonViewModel? _personVm;

  final List<String> tabs = ["전체", "가족", "친구", "직장", "지인", "그외"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 다른 화면(지인 항목 등)에서 거래를 추가/수정해도 히어로 카드의 기간별
    // 캐시(_periodGiven/_periodReceived)가 갱신되지 않던 버그(2026-07-11 검수)
    // 픽스 — PersonViewModel이 notifyListeners()할 때마다 현재 선택된 기간
    // 기준으로 다시 불러온다.
    final personVm = context.read<PersonViewModel>();
    if (_personVm != personVm) {
      _personVm?.removeListener(_onPersonVmChanged);
      _personVm = personVm;
      _personVm!.addListener(_onPersonVmChanged);
    }

    if (_periodInitialized) return;
    _periodInitialized = true;
    _loadPeriodTotals();
  }

  void _onPersonVmChanged() {
    if (!mounted) return;
    _loadPeriodTotals();
  }

  @override
  void dispose() {
    _personVm?.removeListener(_onPersonVmChanged);
    super.dispose();
  }

  int? _cutoffSinceMs() {
    final cutoffDays = _periodCutoffDays[_period];
    if (cutoffDays == null) return null;
    return DateTime.now()
        .subtract(Duration(days: cutoffDays))
        .millisecondsSinceEpoch;
  }

  Future<void> _loadPeriodTotals() async {
    final personVm = context.read<PersonViewModel>();
    final totals = await personVm.getTotalsForPeriod(_cutoffSinceMs());
    if (!mounted) return;
    setState(() {
      _periodGiven = totals.given;
      _periodReceived = totals.received;
    });
  }

  Future<void> _onPeriodSheetOpen() async {
    final selected = await showAppBottomSheet<String>(
      context,
      title: '기간 선택',
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final period in _periods)
              ListTile(
                title: Text(_periodLabel(period)),
                trailing: period == _period
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).extension<AppColors>()!.primary,
                      )
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(period),
              ),
          ],
        );
      },
    );

    if (selected != null && selected != _period) {
      setState(() => _period = selected);
      await _loadPeriodTotals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final persons = personVm.persons;

    List<Person> filteredPersons;
    if (selectedIndex == 0) {
      filteredPersons = persons;
    } else {
      final selectedCategory = tabs[selectedIndex];
      filteredPersons =
          persons.where((p) => p.category == selectedCategory).toList();
    }

    if (personVm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        // AppBar(backgroundColor: Colors.transparent)를 쓰면 Flutter가 상태바
        // 아이콘 밝기를 배경색 밝기로 자동 계산하는 로직이 깨져(투명 = 배경
        // 없음으로 오판) 라이트 테마에서도 흰색(light) 아이콘이 선택되는 문제가
        // 실기기에서 확인됐다(2026-07-16, 다른 화면은 불투명 AppBar라 문제 없음).
        // 테마 밝기로 명시 지정해 실제 배경(colors.bg)과 맞춘다.
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 앱 전용 아이콘(하트+$ 글자) — 배경 채움 없이 아이콘 자체만 브랜드 색으로.
            ColorFiltered(
              colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/icon-black-512.png',
                width: Sizes.size28,
                height: Sizes.size28,
              ),
            ),
            Gaps.h8,
            Text(
              'CashHeart',
              style: TextStyle(
                fontSize: Sizes.size20,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          // "지인 추가"를 floating 버튼으로 리스트 위에 띄우던 방식은 스크롤
          // 위치와 무관하게 화면 고정 좌표에 떠 있어, 리스트 카드가 그 자리에
          // 놓이기만 하면(스크롤 여부 상관없이) 항상 겹치는 구조적 문제였다
          // (2026-07-16 실기기에서 반복 확인 — bottom padding을 더 주는 걸로는
          // 근본 해결이 안 됨, 스크롤 안 된 초기 화면에서도 두 번째 카드가
          // 이미 FAB 위치에 걸쳐 있었음). AppBar(고정 영역, 스크롤과 무관)로
          // 옮겨 겹침 자체가 구조적으로 불가능하게 만든다.
          if (persons.isNotEmpty)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddEditPersonScreen(),
                ));
              },
              tooltip: '지인 추가',
              icon: Icon(Icons.person_add_alt_1, color: colors.primary),
            ),
          if (AppConfig.isDev)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DevComponentGalleryScreen(),
                  ),
                );
              },
              tooltip: '컴포넌트 갤러리 (dev)',
              icon: const Icon(Icons.palette_outlined),
            ),
        ],
      ),
      body: persons.isEmpty
          ? const _EmptyPersonBox()
          : _HomeBody(
              tabs: tabs,
              selectedIndex: selectedIndex,
              onTabChanged: (index) => setState(() => selectedIndex = index),
              filteredPersons: filteredPersons,
              statsByPerson: personVm.statsByPerson,
              personVm: personVm,
              periodLabel: _periodLabel(_period),
              periodGiven: _periodGiven ?? personVm.totalGiven,
              periodReceived: _periodReceived ?? personVm.totalReceived,
              onPeriodTap: _onPeriodSheetOpen,
            ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<Person> filteredPersons;
  final Map<int, RelationshipStats> statsByPerson;
  final PersonViewModel personVm;
  final String periodLabel;
  final int periodGiven;
  final int periodReceived;
  final VoidCallback onPeriodTap;

  const _HomeBody({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.filteredPersons,
    required this.statsByPerson,
    required this.personVm,
    required this.periodLabel,
    required this.periodGiven,
    required this.periodReceived,
    required this.onPeriodTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.v10,
          HeroCard(
            label: '오고 간 정(情) · 순잔액',
            netAmount: periodReceived - periodGiven,
            givenAmount: periodGiven,
            receivedAmount: periodReceived,
            trailing: GestureDetector(
              onTap: onPeriodTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.size11,
                  vertical: Sizes.size7,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.borderSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      periodLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    Icon(Icons.expand_more, size: 18, color: colors.text3),
                  ],
                ),
              ),
            ),
          ),
          Gaps.v20,
          ChipRow<String>(
            items: tabs,
            value: tabs[selectedIndex],
            onChanged: (label) => onTabChanged(tabs.indexOf(label)),
            labelOf: (label) => label,
          ),
          Gaps.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '지인',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
              Text(
                '${filteredPersons.length}명',
                style: TextStyle(fontSize: 13, color: colors.text3),
              ),
            ],
          ),
          Gaps.v10,
          Expanded(
            child: _PersonList(
              filteredPersons: filteredPersons,
              statsByPerson: statsByPerson,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonList extends StatelessWidget {
  final List<Person> filteredPersons;
  final Map<int, RelationshipStats> statsByPerson;

  const _PersonList({
    required this.filteredPersons,
    required this.statsByPerson,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (filteredPersons.isEmpty) {
      return Center(
        child: Text(
          '해당 카테고리에 등록된 인연이 없습니다.',
          style: TextStyle(fontSize: Sizes.size14, color: colors.text3),
        ),
      );
    }

    return ListView.separated(
      // 하단 floating PillNav(MainShellScreen)에 목록이 가리지 않도록 여백 확보.
      // "지인 추가"는 더 이상 리스트 위에 뜨는 FAB가 아니라 AppBar 액션이라
      // (2026-07-16, 겹침 문제로 구조 변경) 이 여백 외에 별도로 고려할 floating
      // 요소가 없다.
      padding: EdgeInsets.only(bottom: PillNav.bottomClearance(context)),
      itemCount: filteredPersons.length,
      separatorBuilder: (context, index) => Gaps.v12,
      itemBuilder: (context, index) {
        final person = filteredPersons[index];
        final stats = statsByPerson[person.id] ?? RelationshipStats.empty;
        final hasRecords = stats.count > 0;

        return RelationshipRow(
          name: person.name,
          tintSeed: person.id ?? 0,
          categoryLabel: person.category ?? '그외',
          metaText: hasRecords
              ? '${stats.years > 0 ? '${stats.years}년간 ' : ''}'
                  '${stats.count}번의 마음 · ${relativeTimeLabel(stats.lastDate!)}'
              : '기록 없음',
          netAmountText: hasRecords
              ? MoneyFormatter.formatCurrency(stats.net, 'ko_KR', '₩')
              : '–',
          netAmountColor: hasRecords
              ? (stats.net >= 0 ? colors.received : colors.given)
              : colors.text3,
          hasRecords: hasRecords,
          tilt: stats.tilt,
          stateLabel: hasRecords ? balanceStateLabel(stats.state) : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) =>
                      GiftViewModel(GiftRepository.instance, person.id!)
                        ..loadGifts(),
                  child: PersonDetailScreen(personId: person.id!),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyPersonBox extends StatelessWidget {
  const _EmptyPersonBox();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/icon-black-512.png',
            width: MediaQuery.of(context).size.width / 2,
          ),
          Gaps.v10,
          Text(
            "소중한 마음을 기록해보세요",
            style: TextStyle(
              fontSize: Sizes.size20,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          Gaps.v10,
          Text(
            "아직 등록된 인연이 없습니다.\n첫 번째 지인을 등록하고 관리를 시작하세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size14,
              color: colors.text2,
              height: 2.0,
            ),
          ),
          Gaps.v40,
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddEditPersonScreen(),
              ));
            },
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
              horizontal: Sizes.size32,
              vertical: Sizes.size14,
            )),
            icon: const Icon(Icons.add),
            label: const Text("첫 인연 등록"),
          )
        ],
      ),
    );
  }
}
