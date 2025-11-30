import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/screens/add_edit_gift_screen.dart';
import 'package:cash_heart/utils/money_formatter.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final giftVm = context.watch<GiftViewModel>();

    final personName = personVm.getPersonById(widget.personId)!.name;

    final allGifts = giftVm.gifts;
    final givenGifts = giftVm.giftGivenList;
    final receivedGifts = giftVm.giftReceivedList;
    final isHappy = giftVm.totalAmount > 0 ? true : false;

    // final randomEventMessage = getRandomEventMessage(giftVm.totalAmount);

    final totalAmountFormat =
        MoneyFormatter.formatCurrency(giftVm.totalAmount, 'ko_KR', '₩ ');
    final totalReceivedFormat =
        MoneyFormatter.formatCurrency(giftVm.totalReceived, 'ko_KR', '₩ ');
    final totalGivenFormat =
        MoneyFormatter.formatCurrency(giftVm.totalGiven, 'ko_KR', '₩ ');

    final Gradient backgroundGradient = isHappy
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, Color(0xFFFB9F35)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cashBlueColor, Color(0xFF36D1DC)],
          );

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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          personName,
        ),
        //TODO: card 또는 screen 샷을 다른 유저들에게 공유할 수 있도록 하기
        // actions: [
        //   ElevatedButton(
        //     onPressed: () {
        //       Navigator.of(context)
        //           .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        //     },
        //     child: Text(
        //       'Share',
        //     ),
        //   ),
        //   Gaps.h10,
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffFF6258),
        shape: CircleBorder(),
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
          Icons.add,
          size: 28.0,
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
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Sizes.size20, vertical: Sizes.size24),
                decoration: BoxDecoration(
                    gradient: backgroundGradient,
                    borderRadius: BorderRadius.circular(Sizes.size20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총액',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Sizes.size16,
                            letterSpacing: 1.4,
                          ),
                        ),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Gaps.v10,
                    Text(
                      totalAmountFormat,
                      style: TextStyle(
                        fontSize: Sizes.size36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Gaps.v20,
                    Row(
                      children: [
                        Expanded(
                          child: _AmountTypeBox(
                              received: true, amount: totalReceivedFormat),
                        ),
                        Container(
                          color: Colors.white,
                          width: Sizes.size1,
                          height: Sizes.size48,
                        ),
                        Expanded(
                          child: _AmountTypeBox(
                              received: false, amount: totalGivenFormat),
                        ),
                      ],
                    ),
                    // Gaps.v10,
                    // Text(
                    //   randomEventMessage,
                    //   style: TextStyle(
                    //     fontSize: Sizes.size14,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Gaps.v20,

              // 탭 필터
              Container(
                padding: EdgeInsets.all(Sizes.size4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
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
                            color:
                                isSelected ? Colors.white : Colors.transparent,
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
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Gaps.v20,

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
    final personName =
        context.read<PersonViewModel>().getPersonById(gift.personId)!.name;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: giftVm,
          child: AddEditGiftScreen(
            personName: personName,
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
                    backgroundColor: cashBlueColor,
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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
                      // 제목 및 날짜
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.note,
                              style: TextStyle(
                                fontSize: Sizes.size16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Gaps.v4,
                            Text(
                              dateText,
                              style: TextStyle(
                                fontSize: Sizes.size12,
                                color: Colors.grey.shade500,
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
                          color: isReceived ? primaryColor : cashBlueColor,
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

class _AmountTypeBox extends StatelessWidget {
  final bool received;
  final String amount;

  const _AmountTypeBox({
    required this.received,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              received ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Icon(
                received
                    ? Icons.arrow_upward_outlined
                    : Icons.arrow_downward_outlined,
                size: Sizes.size14,
                color: Colors.white),
            Gaps.h4,
            Text(
              received ? '받은 돈' : '준 돈',
              style: TextStyle(
                color: Colors.white,
                fontSize: Sizes.size14,
              ),
            ),
          ],
        ),
        Gaps.v4,
        Align(
          alignment: received ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w700,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }
}
