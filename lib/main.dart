import 'package:cash_heart/config/app_config.dart';
import 'package:cash_heart/providers/person_view_model.dart';
import 'package:cash_heart/providers/theme_provider.dart';
import 'package:cash_heart/repositories/person_repository.dart';
import 'package:cash_heart/screens/main_shell_screen.dart';
import 'package:cash_heart/services/mock_data_service.dart';
import 'package:cash_heart/theme/app_theme.dart';
import 'package:cash_heart/utils/root_messenger.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    if (sentryDsn.isEmpty) {
      // assert는 release에서 스트립되므로 사용하지 않음 - release에서도 남아야 하는 경고.
      debugPrint(
          '[CashHeart] SENTRY_DSN이 비어있습니다. flutter build 시 '
          '--dart-define=SENTRY_DSN=<값> 옵션 없이 빌드되어 Sentry가 전송되지 않습니다.');
    }

    // release 문자열을 pubspec.yaml 버전에 하드코딩 고정해뒀던 게 매 버전 올릴
    // 때마다 갱신을 잊기 쉬워 실제로도 밀려 있었다(2026-07-11 발견) — 설치된
    // 버전을 직접 읽어 항상 최신 상태로 맞춘다.
    final packageInfo = await PackageInfo.fromPlatform();

    // Production: Sentry 활성화
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;

        options.sendDefaultPii = false;
        options.enableLogs = true;
        options.tracesSampleRate = 0.1;
        options.profilesSampleRate = 0;
        options.replay.sessionSampleRate = 0.0;
        options.replay.onErrorSampleRate = 0.0;
        options.environment = 'production';
        options.release =
            'CashHeart@${packageInfo.version}+${packageInfo.buildNumber}';
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
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            home: const MainShellScreen(),
            debugShowCheckedModeBanner: AppConfig.isDev,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
          );
        },
      ),
    );
  }
}
