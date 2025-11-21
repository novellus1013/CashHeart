import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/home_screen.dart';
import 'package:cash_heart/screens/setting_screen.dart';
import 'package:cash_heart/screens/share_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
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
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "pretendard",
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            scrolledUnderElevation: 0,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: Sizes.size20,
              color: Colors.black,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(
            fontSize: Sizes.size14,
            color: Colors.grey,
          )),
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
