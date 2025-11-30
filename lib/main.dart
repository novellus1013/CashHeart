import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://8f01d649f395a7c25a20358d75df2d95@o4510417424285696.ingest.us.sentry.io/4510417425465344';

      // 개인정보(IP, 헤더 등)도 함께 전송
      options.sendDefaultPii = false;
      options.enableLogs = true;

      //성능 모니터링 100% 샘플링. 배포 후 상황 보고 수치 낮추기 (0.1 시도)
      options.tracesSampleRate = 0.1;
      options.profilesSampleRate = 0;
      //일반 녹화
      options.replay.sessionSampleRate = 0.0;
      //에러시 녹화
      options.replay.onErrorSampleRate = 0.0;

      // 환경
      options.environment = kReleaseMode ? 'production' : 'development';

      // 릴리즈 버전
      options.release = 'CashHeart@1.0.0+1';
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
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
            surfaceTintColor: Colors.transparent,
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
