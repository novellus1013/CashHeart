import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/screens/add_edit_gift_screen.dart';
import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/total_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  int selectedIndex = 0;

  Future<void> _onDeletePerson(
      BuildContext context, PersonViewModel personVm) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '정말 삭제하시겠습니까?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.size20,
          ),
        ),
        content: Text(
          '이 사람과 관련된 모든 거래 내역이 함께 삭제됩니다. 한 번 삭제하면 돌이킬 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: Text(
              '취소',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              '삭제하기',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await personVm.deletePerson(widget.personId);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final giftVm = context.watch<GiftViewModel>();

    final person = personVm.getPersonById(widget.personId);

    // 삭제 후 rebuild 시 person이 null일 수 있음
    if (person == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final personName = person.name;

    final allGifts = giftVm.gifts;
    final givenGifts = giftVm.giftGivenList;
    final receivedGifts = giftVm.giftReceivedList;
    final isPlus = giftVm.totalAmountById > 0 ? true : false;

    final totalAmountFormat =
        MoneyFormatter.formatCurrency(giftVm.totalAmountById, 'ko_KR', '₩ ');
    final totalReceivedFormat =
        MoneyFormatter.formatCurrency(giftVm.totalReceivedById, 'ko_KR', '₩ ');
    final totalGivenFormat =
        MoneyFormatter.formatCurrency(giftVm.totalGivenById, 'ko_KR', '₩ ');

    final List<String> tabs = ["총액", "받은 돈", "준 돈"];

    // 현재 탭에 따라 표시할 리스트 선택
    List<Gift> filteredList;
    if (selectedIndex == 0) {
      filteredList = allGifts;
    } else if (selectedIndex == 1) {
      filteredList = receivedGifts;
    } else {
      filteredList = givenGifts;
    }

    //list를 복사하여 날짜 내리차순으로 정리
    final sortedList = [...filteredList]
      ..sort((a, b) => b.date.compareTo(a.date));

    //로딩 중
    if (giftVm.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          personName,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditPersonScreen(
                    personId: widget.personId,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.edit,
              color: secondaryColor,
            ),
            tooltip: '수정하기',
          ),
          IconButton(
            onPressed: () => _onDeletePerson(context, personVm),
            icon: Icon(
              Icons.delete,
              color: primaryColor,
            ),
            tooltip: '삭제하기',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // FAB의 Hero 위젯 충돌 오류 방지
        heroTag: null,
        backgroundColor: primaryColor,
        shape: CircleBorder(),
        tooltip: 'Add Transaction',
        onPressed: () {
          final giftVm = context.read<GiftViewModel>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: giftVm,
                child: AddEditGiftScreen(
                  personId: widget.personId,
                  personName: personName,
                ),
              ),
            ),
          );
        },
        child: Icon(
          Icons.playlist_add,
          size: 32.0,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: Sizes.size20,
        ),
        child: Center(
          child: Column(
            children: [
              Gaps.v10,
              TotalCard(
                  isPlus: isPlus,
                  totalAmountFormat: totalAmountFormat,
                  totalReceivedFormat: totalReceivedFormat,
                  totalGivenFormat: totalGivenFormat),
              Gaps.v20,

              // 탭 필터
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
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
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
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
                                          color:
                                              Colors.black.withValues(alpha: 0.05),
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
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black)
                                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              Gaps.v8,
              Text(
                '내역을 오른쪽으로 당기면 수정이나 삭제가 가능해요!',
                style: TextStyle(
                  fontSize: Sizes.size12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              Gaps.v10,

              //무한 스크롤 리스트
              _DetailList(filteredList: sortedList),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailList extends StatelessWidget {
  final List<Gift> filteredList;

  const _DetailList({
    required this.filteredList,
  });

  void _onEditGift(BuildContext context, Gift gift) {
    final giftVm = context.read<GiftViewModel>();
    final person = context.read<PersonViewModel>().getPersonById(gift.personId);
    if (person == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: giftVm,
          child: AddEditGiftScreen(
            personName: person.name,
            personId: gift.personId,
            giftId: gift.id,
          ),
        ),
      ),
    );
  }

  Future<bool?> _onWarningDelteGift(BuildContext context, Gift gift) async {
    final giftVm = context.read<GiftViewModel>();

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                '정말 삭제하시겠습니까?',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: Sizes.size20,
                ),
              ),
              content: Text(
                '한 번 삭제하면 돌이킬 수 없습니다.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    giftVm.deleteGift(gift.id!);
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    '삭제하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: ListView.separated(
        //최하단의 list_item이 floating_action_bar에 가리지 않도록 패딩 추가
        padding: EdgeInsets.only(bottom: Sizes.size56 + Sizes.size52),
        itemCount: filteredList.length, // 무한 스크롤 시뮬레이션 (데이터 반복)
        separatorBuilder: (context, index) => Gaps.v12,
        itemBuilder: (context, index) {
          final data = filteredList[index];

          final isReceived = data.direction == GiftDirection.received;
          final meta = giftCategoryMeta[data.category];
          final dateText = DateFormat('yyyy년 MM월 dd일')
              .format(DateTime.fromMillisecondsSinceEpoch(data.date));
          final oneGiftAmount =
              MoneyFormatter.formatCurrency(data.amount, 'ko_KR', '₩');

          return ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Sizes.size20),
              bottomRight: Radius.circular(Sizes.size20),
            ),
            child: Slidable(
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _onWarningDelteGift(context, data),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: '삭제하기',
                  ),
                  SlidableAction(
                    onPressed: (_) => _onEditGift(context, data),
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: '수정하기',
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Sizes.size20),
                  bottomLeft: Radius.circular(Sizes.size20),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.size16,
                    horizontal: Sizes.size16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // 아이콘
                      Container(
                        width: Sizes.size48,
                        height: Sizes.size48,
                        decoration: BoxDecoration(
                          color: meta!.bgColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          meta.emoji,
                          style: TextStyle(fontSize: Sizes.size24),
                        ),
                      ),
                      Gaps.h12,
                      // 노트 및 날짜
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.note,
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Gaps.v4,
                            Text(
                              dateText,
                              style: TextStyle(
                                fontSize: Sizes.size12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 금액
                      Text(
                        isReceived ? oneGiftAmount : oneGiftAmount,
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.1,
                          color: isReceived ? primaryColor : secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
