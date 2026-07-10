import 'package:cash_heart/config/app_config.dart';
import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/providers/report_view_model.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:cash_heart/screens/dev_component_gallery_screen.dart';
import 'package:cash_heart/screens/person_detail_screen.dart';
import 'package:cash_heart/screens/report_screen.dart';
import 'package:cash_heart/screens/setting_screen.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/total_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> tabs = ["전체", "가족", "친구", "직장", "지인", "그외"];

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final persons = personVm.persons;

    final totalAmountFormat =
        MoneyFormatter.formatCurrency(personVm.totalAmount, 'ko_KR', '₩ ');
    final totalReceivedFormat =
        MoneyFormatter.formatCurrency(personVm.totalReceived, 'ko_KR', '₩ ');
    final totalGivenFormat =
        MoneyFormatter.formatCurrency(personVm.totalGiven, 'ko_KR', '₩ ');

    final isPlus = personVm.totalAmount > 0;

    // Filter persons by category
    List<Person> filteredPersons;
    if (selectedIndex == 0) {
      filteredPersons = persons;
    } else {
      final selectedCategory = tabs[selectedIndex];
      filteredPersons =
          persons.where((p) => p.category == selectedCategory).toList();
    }

    if (personVm.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('CashHeart'),
        backgroundColor: Colors.transparent,
        actions: [
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
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => ReportViewModel(
                      GiftRepository.instance,
                      PersonRepository.instance,
                    )..loadReportData(),
                    child: const ReportScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.bar_chart,
              size: 28.0,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              size: 28.0,
            ),
          ),
        ],
      ),
      floatingActionButton: persons.isEmpty
          ? null
          : FloatingActionButton(
              heroTag: null,
              backgroundColor: const Color(0xffFF6258),
              shape: const CircleBorder(),
              tooltip: 'Add Person',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddEditPersonScreen(),
                ));
              },
              child: const Icon(
                Icons.person_add_alt_1,
                size: 28.0,
                color: Colors.white,
              ),
            ),
      body: persons.isEmpty
          ? _EmptyPersonBox()
          : _BuildBody(
              isPlus: isPlus,
              totalAmountFormat: totalAmountFormat,
              totalReceivedFormat: totalReceivedFormat,
              totalGivenFormat: totalGivenFormat,
              tabs: tabs,
              selectedIndex: selectedIndex,
              onTabChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              filteredPersons: filteredPersons,
            ),
    );
  }
}

class _BuildBody extends StatelessWidget {
  final bool isPlus;
  final String totalAmountFormat;
  final String totalReceivedFormat;
  final String totalGivenFormat;
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<Person> filteredPersons;

  const _BuildBody({
    required this.isPlus,
    required this.totalAmountFormat,
    required this.totalReceivedFormat,
    required this.totalGivenFormat,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.filteredPersons,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
      child: Column(
        children: [
          Gaps.v10,
          TotalCard(
            isPlus: isPlus,
            totalAmountFormat: totalAmountFormat,
            totalReceivedFormat: totalReceivedFormat,
            totalGivenFormat: totalGivenFormat,
          ),
          Gaps.v20,
          // Category chips
          Container(
            padding: EdgeInsets.all(Sizes.size4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(Sizes.size20),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: Sizes.size10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).cardColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Sizes.size16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: Sizes.size14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Gaps.v16,
          // Person List
          Expanded(
            child: _PersonList(filteredPersons: filteredPersons),
          ),
        ],
      ),
    );
  }
}

class _PersonList extends StatelessWidget {
  final List<Person> filteredPersons;

  const _PersonList({required this.filteredPersons});

  @override
  Widget build(BuildContext context) {
    if (filteredPersons.isEmpty) {
      return Center(
        child: Text(
          '해당 카테고리에 등록된 인연이 없습니다.',
          style: TextStyle(
            fontSize: Sizes.size14,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: Sizes.size56 + Sizes.size52),
      itemCount: filteredPersons.length,
      separatorBuilder: (context, index) => Gaps.v12,
      itemBuilder: (context, index) {
        final person = filteredPersons[index];
        return _PersonListItem(person: person);
      },
    );
  }
}

class _PersonListItem extends StatelessWidget {
  final Person person;

  const _PersonListItem({required this.person});

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final totalAmount = personVm.getTotalAmountByPerson(person.id!);
    final lastGift = personVm.getLastGift(person.id!);
    final isPlus = totalAmount >= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalAmountFormat =
        MoneyFormatter.formatCurrency(totalAmount, 'ko_KR', '₩');

    return GestureDetector(
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
      child: Container(
        padding: EdgeInsets.all(Sizes.size16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Sizes.size16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name, category, total amount
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        person.name,
                        style: TextStyle(
                          fontSize: Sizes.size18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (person.category != null) ...[
                        Gaps.h8,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Sizes.size8,
                            vertical: Sizes.size2,
                          ),
                          decoration: BoxDecoration(
                            color: getCategoryColor(person.category),
                            borderRadius: BorderRadius.circular(Sizes.size10),
                          ),
                          child: Text(
                            person.category!,
                            style: TextStyle(
                              fontSize: Sizes.size12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  totalAmountFormat,
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.bold,
                    color: isPlus ? primaryColor : secondaryColor,
                  ),
                ),
              ],
            ),
            // Memo
            if (person.note != null && person.note!.isNotEmpty) ...[
              Gaps.v4,
              Text(
                person.note!,
                style: TextStyle(
                  fontSize: Sizes.size12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Last gift info
            if (lastGift != null) ...[
              Gaps.v8,
              _LastGiftInfo(gift: lastGift),
            ],
          ],
        ),
      ),
    );
  }
}

class _LastGiftInfo extends StatelessWidget {
  final Gift gift;

  const _LastGiftInfo({required this.gift});

  @override
  Widget build(BuildContext context) {
    final isReceived = gift.direction == GiftDirection.received;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = DateFormat('yyyy.MM.dd')
        .format(DateTime.fromMillisecondsSinceEpoch(gift.date));
    final amountFormat =
        MoneyFormatter.formatCurrency(gift.amount, 'ko_KR', '₩');

    return Container(
      padding: EdgeInsets.all(Sizes.size10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(Sizes.size10),
      ),
      child: Row(
        children: [
          Icon(
            isReceived ? Icons.arrow_downward : Icons.arrow_upward,
            size: Sizes.size14,
            color: isReceived ? primaryColor : secondaryColor,
          ),
          Gaps.h4,
          Text(
            isReceived ? '받음' : '보냄',
            style: TextStyle(
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
              color: isReceived ? primaryColor : secondaryColor,
            ),
          ),
          Gaps.h8,
          Expanded(
            child: Text(
              gift.note,
              style: TextStyle(
                fontSize: Sizes.size12,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Gaps.h8,
          Text(
            amountFormat,
            style: TextStyle(
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Gaps.h8,
          Text(
            dateText,
            style: TextStyle(
              fontSize: Sizes.size12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPersonBox extends StatelessWidget {
  const _EmptyPersonBox();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          Gaps.v10,
          Text(
            "아직 등록된 인연이 없습니다.\n첫 번째 지인을 등록하고 관리를 시작하세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size14,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
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
