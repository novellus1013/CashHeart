import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/person.dart';
import 'package:cash_heart/providers/gift_view_model.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/gift_repository.dart';
import 'package:cash_heart/screens/add_edit_person_screen.dart';
import 'package:cash_heart/screens/person_detail_screen.dart';
import 'package:cash_heart/screens/setting_screen.dart';
import 'package:cash_heart/utils/event_message_handler.dart';
import 'package:cash_heart/utils/money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //read와 달리 notifyListeners()가 호출될 때마다 home_screen이 자동으로 다시 build 실행 - ui가 항상 최신화
    final personList = context.watch<PersonViewModel>().persons;

    final PageController pageController = PageController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'CashHeart',
        ),
        actions: [
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
          )
        ],
      ),
      floatingActionButton: personList.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xffFF6258),
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddEditPersonScreen(),
                ));
              },
              child: const Icon(
                Icons.add,
                size: 28.0,
                color: Colors.white,
              ),
            ),
      body: personList.isEmpty
          ? _EmptyPersonBox()
          : _PersonPageView(
              personList: personList, pageController: pageController),
    );
  }
}

class _PersonPageView extends StatefulWidget {
  final List<Person> personList;
  final PageController pageController;

  const _PersonPageView({
    required this.personList,
    required this.pageController,
  });

  @override
  State<_PersonPageView> createState() => _PersonPageViewState();
}

class _PersonPageViewState extends State<_PersonPageView> {
  late PageController _pageController;
  // 애니메이션 계산용 -> opacitry, scale 값이 double이라서
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    // viewportFraction: 0.8 -> 양옆의 카드가 살짝 보이게 하기
    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v20,
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.personList.length,
            itemBuilder: (context, index) {
              //현재 페이지 vs 양 옆 카드
              double value = (index - _currentPageValue).abs();

              // 현재 페이지 크기 1.0 양 옆 페이지 크기 0.9
              double scale = 1.0 - (value * 0.1);

              // 현재 페이지 선명 양 옆 페이지 조금 흐림
              double opacity = 1.0 - (value * 0.3);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    //FAB 잘 보이게 하려는 용도
                    padding: const EdgeInsets.only(
                      bottom: Sizes.size56 + Sizes.size56,
                    ),
                    child: _PersonBox(person: widget.personList[index]),
                  ),
                ),
              );
            },
          ),
        ),
        Gaps.v60,
      ],
    );
  }
}

class _PersonBox extends StatelessWidget {
  final Person person;

  const _PersonBox({required this.person});

  @override
  Widget build(BuildContext context) {
    //TODO: 나중에 totalAmount로 변경
    final int fakeAmount = 200000;

    final randomEventMessage = getRandomEventMessage(fakeAmount);

    final totalFormat = MoneyFormatter.formatCurrency(fakeAmount, 'ko_KR', '₩');

    //TODO: person의 totalAmount를 기준으로 isReceived 정의
    final bool isGiven = false;

    final Gradient backgroundGradient = isGiven
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cashBlueColor, Color(0xFF36D1DC)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, Color(0xFFFB9F35)],
          );

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
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(Sizes.size32),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: Sizes.size16,
              offset: const Offset(
                Sizes.size32,
                Sizes.size32,
              ),
            ),
          ],
        ),
        child: Stack(
          children: [
            //카드 메인
            _Content(
                person: person,
                isGiven: isGiven,
                totalFormat: totalFormat,
                randomEventMessage: randomEventMessage),
            // edit 버튼용 ui
            _EditButton(person: person),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.person,
    required this.isGiven,
    required this.totalFormat,
    required this.randomEventMessage,
  });

  final Person person;
  final bool isGiven;
  final String totalFormat;
  final String randomEventMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.size28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: Sizes.size32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gaps.v10,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size10,
                  vertical: Sizes.size4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Sizes.size20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  person.note ?? ' ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isGiven ? "받은 마음" : "보낸 마음",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  //TODO: person의 totalAmount 가져와서 적용
                  totalFormat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: Sizes.size48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Container(
              //   padding: const EdgeInsets.all(
              //     Sizes.size16,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withValues(alpha: 0.2),
              //     borderRadius: BorderRadius.circular(
              //       Sizes.size16,
              //     ),
              //   ),
              //   child: Center(
              //     child: Text(
              //       randomEventMessage,
              //       textAlign: TextAlign.start,
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: Sizes.size16,
              //         fontStyle: FontStyle.italic,
              //       ),
              //     ),
              //   ),
              // ),
              // Gaps.v20,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "CashHeart",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: Sizes.size14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -Sizes.size64,
      right: -Sizes.size64,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditPersonScreen(
                personId: person.id,
              ),
            ),
          );
        },
        child: Container(
          width: Sizes.size40 * 5,
          height: Sizes.size40 * 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Transform.translate(
            offset: Offset(
              -Sizes.size20,
              Sizes.size20,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white70,
              size: Sizes.size28,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPersonBox extends StatelessWidget {
  const _EmptyPersonBox();

  @override
  Widget build(BuildContext context) {
    // FloatingActionButton과 동일한 동작 (AddEditPersonScreen으로 이동)
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
              color: Colors.grey[800],
            ),
          ),
          Gaps.v10,
          Text(
            "아직 등록된 인연이 없습니다.\n첫 번째 지인을 등록하고 관리를 시작하세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size14,
              color: Colors.grey[500],
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
