import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/add_gift_screen.dart';
import 'package:cash_heart/screens/home_screen.dart';
import 'package:cash_heart/screens/person_detail_screen.dart';
import 'package:cash_heart/screens/setting_screen.dart';
import 'package:cash_heart/screens/share_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final repository = PersonRepository.instance;
          final vm = PersonViewModel(repository);
          vm.loadPersons();
          return vm;
        })

        // //cascade 적용
        // ChangeNotifierProvider(create: (context) => PersonViewModel(PersonRepository.instance)..loadPersons(),
        // ),
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          "/": (context) => const HomeScreen(),
          "/add": (context) => const AddGiftScreen(),
          "/detail": (context) => const PersonDetailScreen(),
          "/share": (context) => const ShareCardScreen(),
          "/setting": (context) => const SettingScreen(),
        },
        theme: ThemeData(
          fontFamily: "pretendard",
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffFF6258),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w700),
            displayMedium: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: Sizes.size28,
              color: Colors.black,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
