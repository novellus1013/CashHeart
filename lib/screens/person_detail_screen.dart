import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/gift.dart';
import 'package:cash_heart/models/gift_types.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/screens/add_edit_gift_screen.dart';
import 'package:cash_heart/screens/share_card_screen.dart';
import 'package:cash_heart/utils/event_message_handler.dart';
import 'package:cash_heart/utils/money_formatter.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
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

    final totalAmount = giftVm.totalAmount;
    final totalReceived = giftVm.totalReceived;
    final totalGiven = giftVm.totalGiven;

    final randomEventMessage = getRandomEventMessage(totalAmount);

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

    // 현재 탭에 따라 ui용 합계 계산 (int 값이 아닌 formatter를 거친 String 값)
    late final int currentTotal;
    if (selectedIndex == 0) {
      currentTotal = totalAmount;
    } else if (selectedIndex == 1) {
      currentTotal = totalReceived;
    } else {
      currentTotal = totalGiven;
    }

    late final String totalCredit;
    late final Color totalCreditColor;

    if (currentTotal == 0) {
      totalCredit = MoneyFormatter.formatCurrency(0, 'ko_KR', '₩ ');
      totalCreditColor = Colors.grey;
    } else {
      if (selectedIndex == 0) {
        // "총액" 탭: 실제 부호 기준으로 + / - 표시
        final prefix = currentTotal > 0 ? '+ ' : '- ';
        totalCredit =
            "$prefix${MoneyFormatter.formatCurrency(currentTotal.abs(), 'ko_KR', '₩ ')}";
        totalCreditColor = currentTotal > 0 ? primaryColor : cashBlueColor;
      } else if (selectedIndex == 1) {
        // "받은 돈" 탭: 항상 + / 초록(또는 primary)
        totalCredit =
            "+ ${MoneyFormatter.formatCurrency(currentTotal, 'ko_KR', '₩ ')}";
        totalCreditColor = primaryColor;
      } else {
        // "준 돈" 탭: 항상 - / 파란(cashBlueColor)
        totalCredit =
            "- ${MoneyFormatter.formatCurrency(currentTotal, 'ko_KR', '₩ ')}";
        totalCreditColor = cashBlueColor;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          personName,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ShareCardScreen()));
            },
            child: Text(
              'Share',
            ),
          ),
          Gaps.h10,
        ],
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
              Gaps.v20,
              // total
              Text(
                totalCredit,
                style: TextStyle(
                  fontSize: Sizes.size40,
                  fontWeight: FontWeight.bold,
                  color: totalCreditColor,
                ),
              ),
              Gaps.v10,
              // 2. 서브 텍스트
              Text(
                randomEventMessage,
                style: TextStyle(
                  fontSize: Sizes.size14,
                  color: Colors.grey,
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
  const _DetailList({
    super.key,
    required this.filteredList,
  });

  final List<Gift> filteredList;

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

          return Container(
            padding: EdgeInsets.symmetric(
              vertical: Sizes.size16,
              horizontal: Sizes.size16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.size24),
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
                  isReceived ? '+ $oneGiftAmount' : '- $oneGiftAmount',
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    fontWeight: FontWeight.bold,
                    color: isReceived ? primaryColor : cashBlueColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
