import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/screens/add_edit_gift_screen.dart';
import 'package:cash_heart/utils/event_message_handler.dart';
import 'package:cash_heart/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final personVm = context.watch<PersonViewModel>();
    final giftVm = context.watch<GiftViewModel>();

    final personName = personVm.getPersonById(widget.personId)!.name;

    final totalAmount = giftVm.totalAmount;
    final totalReceived = giftVm.totalReceived;
    final totalGiven = giftVm.totalGiven;

    final randomEventMessage = getRandomEventMessage(totalAmount);

    final totalFormat =
        MoneyFormatter.formatCurrency(totalAmount, 'ko_KR', '₩');

    int selectedIndex = 0;

    final List<String> tabs = ["총액", "받은 돈", "준 돈"];

    // 더미 데이터 리스트
    final List<Map<String, dynamic>> transactions = [
      {
        "title": "민준님 결혼 축하",
        "date": "2024년 5월 20일",
        "amount": -100000,
        "icon": "👰‍♀️",
        "bgColor": 0xFFE3F2FD, // Light Blue
      },
      {
        "title": "내 생일 축하",
        "date": "2024년 4월 15일",
        "amount": 50000,
        "icon": "🎂",
        "bgColor": 0xFFE8F5E9, // Light Green
      },
      {
        "title": "새해 선물",
        "date": "2024년 1월 1일",
        "amount": 150000,
        "icon": "🎉",
        "bgColor": 0xFFF3E5F5, // Light Purple
      },
      {
        "title": "집들이 선물",
        "date": "2023년 11월 8일",
        "amount": 100000,
        "icon": "🎁",
        "bgColor": 0xFFFFF3E0, // Light Orange
      },
      {
        "title": "친구랑 저녁",
        "date": "2023년 10월 2일",
        "amount": -30000,
        "icon": "🍝",
        "bgColor": 0xFFFFEBEE, // Light Red
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          personName,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/share');
            },
            icon: Icon(
              Icons.settings,
              size: 28.0,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffFF6258),
        shape: CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => GiftViewModel(
                  GiftRepository.instance,
                  widget.personId,
                )..loadGifts(),
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
      body: Center(
        child: Column(
          children: [
            Gaps.v20,
            // 2. 총 금액
            Text(
              "+₩200,000",
              style: TextStyle(
                fontSize: Sizes.size40,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A88FF),
              ),
            ),
            Gaps.v10,

            // 3. 서브 텍스트
            Text(
              "I was the only one who cared 🥲",
              style: TextStyle(
                fontSize: Sizes.size14,
                color: Colors.grey.shade600,
              ),
            ),
            Gaps.v24,

            // 4. 탭 (총액, 받은 돈, 준 돈)
            Container(
              margin: EdgeInsets.symmetric(horizontal: Sizes.size20),
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
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: Sizes.size10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(Sizes.size16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
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

            // 5. 무한 스크롤 리스트
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(Sizes.size20, 0, Sizes.size20,
                    Sizes.size96 // 하단 버튼에 가려지지 않도록 여백 추가
                    ),
                itemCount: 20, // 무한 스크롤 시뮬레이션 (데이터 반복)
                separatorBuilder: (context, index) => Gaps.v12,
                itemBuilder: (context, index) {
                  // 데이터 순환 참조
                  final data = transactions[index % transactions.length];
                  final isPositive = data['amount'] > 0;

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
                          color: Colors.black.withOpacity(0.03),
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
                            color: Color(data['bgColor']),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            data['icon'],
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
                                data['title'],
                                style: TextStyle(
                                  fontSize: Sizes.size16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Gaps.v4,
                              Text(
                                data['date'],
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
                          "${isPositive ? '+' : ''}₩${(data['amount'] as int).abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: TextStyle(
                            fontSize: Sizes.size16,
                            fontWeight: FontWeight.bold,
                            color: isPositive
                                ? const Color(0xFF4A88FF)
                                : const Color(0xFFFF5252),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
