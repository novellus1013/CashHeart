import 'package:cash_heart/config/app_config.dart';
import 'package:cash_heart/constants/colors.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/providers/theme_provider.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/home_screen.dart';
import 'package:cash_heart/services/mock_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

late ThemeProvider _themeProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  // 환경 설정 (dev / prod) - 배포 시 AppConfig.setProd()로 변경!
  // AppConfig.setDev();
  AppConfig.setProd();

  // ThemeProvider 초기화 (SharedPreferences 로드)
  _themeProvider = await ThemeProvider.create();

  if (AppConfig.useSentry) {
    // Production: Sentry 활성화
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://8f01d649f395a7c25a20358d75df2d95@o4510417424285696.ingest.us.sentry.io/4510417425465344';

        options.sendDefaultPii = false;
        options.enableLogs = true;
        options.tracesSampleRate = 0.1;
        options.profilesSampleRate = 0;
        options.replay.sessionSampleRate = 0.0;
        options.replay.onErrorSampleRate = 0.0;
        options.environment = 'production';
        options.release = 'CashHeart@1.0.0+1';
      },
      appRunner: () => runApp(SentryWidget(child: const MyApp())),
    );
  } else {
    // Development: Sentry 비활성화
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider(create: (context) {
          final repository = PersonRepository.instance;
          final vm = PersonViewModel(repository);

          if (AppConfig.useMockData) {
            // Dev: Mock 데이터 생성 후 로드
            MockDataService.instance.ensureMockData().then((_) {
              vm.loadPersons();
            });
          } else {
            // Prod: 바로 로드
            vm.loadPersons();
          }

          return vm;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            home: HomeScreen(),
            debugShowCheckedModeBanner: AppConfig.isDev,
            themeMode: themeProvider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "pretendard",
      scaffoldBackgroundColor: const Color(0xFFF8F6F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xFFF8F6F5),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: Sizes.size20,
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: Sizes.size14,
          color: Colors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade200,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "pretendard",
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: Sizes.size20,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: Sizes.size14,
          color: Colors.grey.shade400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: const Color(0xFF2A2A2A),
      dividerColor: Colors.grey.shade800,
    );
  }
}
