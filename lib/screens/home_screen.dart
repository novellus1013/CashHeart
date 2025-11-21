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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        floatingActionButton: FloatingActionButton(
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
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: Sizes.size40),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: personList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.size10,
                    ),
                    child: _EmptyPersonBox(), // 데이터가 없을 때 표시할 화면
                  )
                : PageView.builder(
                    controller: pageController,
                    itemCount: personList.length,
                    itemBuilder: (context, index) {
                      final person = personList[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size10,
                        ),
                        child: _PesronBox(
                          person: person,
                        ),
                      );
                    },
                  ),
          ),
        ));
  }
}

class _PesronBox extends StatelessWidget {
  final Person person;

  const _PesronBox({
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final int fakeAmount = 200000;

    Color amountColor;

    final randomEventMessage = getRandomEventMessage(fakeAmount);

    final totalFormat = MoneyFormatter.formatCurrency(fakeAmount, 'ko_KR', '₩');

    if (fakeAmount > 100000) {
      amountColor = primaryColor;
    } else if (fakeAmount < -100000) {
      amountColor = cashBlueColor;
    } else {
      amountColor = Colors.grey;
    }

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
      child: Card(
        elevation: Sizes.size8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.size32),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(
            Sizes.size40,
          ),
          //TODO: A RenderFlex overflowed by 14 pixels on the bottom.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: TextStyle(
                  fontSize: Sizes.size32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // 강조 색상
                ),
              ),
              Gaps.v8,
              Text(
                person.note ?? " ",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
              ),
              Gaps.v32,
              Center(
                child: Text(
                  totalFormat,
                  style: TextStyle(
                    fontSize: Sizes.size40,
                    fontWeight: FontWeight.w900, // 가장 굵게
                    color: amountColor, // 차별화된 강조 색상
                  ),
                ),
              ),
              Gaps.v40,
              Center(
                child: Text(
                  maxLines: 2,
                  randomEventMessage,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: Text(
                  'CashHeart',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('지인을 등록해 주세요!'),
            content: Text('지인이 없으면 기록을 추가할 수 없어요.'),
          ),
        );
      },
      child: Card(
        elevation: Sizes.size8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.size32),
        ),
        // 비어있는 카드임을 시각적으로 나타내기 위해 색상을 Surface Container Lowest로 설정
        color: Theme.of(context).colorScheme.surfaceContainerLowest,

        child: Padding(
          padding: const EdgeInsets.all(
            Sizes.size40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '지인 등록',
                style: TextStyle(
                  fontSize: Sizes.size32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v10,
              Text(
                'CashHeart는 축의금 개인 기록 앱 입니다.',
                style: TextStyle(
                  fontSize: Sizes.size16,
                ),
              ),
              Gaps.v20,
              Text(
                '오른쪽 하단 버튼을 눌러 첫 번째 인연을 등록하세요.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: Sizes.size16,
                ),
              ),
              Spacer(),
              Center(
                child: FaIcon(
                  FontAwesomeIcons.userPlus,
                  size: Sizes.size60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              Gaps.v40,
              Center(
                child: Text(
                  'CashHeart',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
