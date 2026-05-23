# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

CashHeart는 경조사비(축의금·조의금 등)를 기록·관리하는 Flutter 모바일 앱입니다. App Store와 Google Play에 배포되어 있습니다.

## Commands

```bash
# 실행 (시뮬레이터/디바이스)
flutter run

# 빌드
flutter build apk           # Android
flutter build ios           # iOS

# 정적 분석
flutter analyze

# 테스트
flutter test
flutter test test/widget_test.dart   # 단일 테스트

# 아이콘/스플래시 생성
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 패키지 업데이트
flutter pub upgrade
flutter pub outdated
```

## Environment Configuration

`lib/config/app_config.dart`로 환경을 전환합니다. `main.dart`에서 앱 시작 전에 설정해야 합니다.

- **Dev** (`AppConfig.setDev()`): Mock 데이터 자동 생성, Sentry 비활성화, 디버그 배너 표시
- **Prod** (`AppConfig.setProd()`): 실 DB 사용, Sentry 활성화, 디버그 배너 숨김

**배포 전 반드시** `main.dart`에서 `AppConfig.setProd()`가 활성화되어 있는지 확인하세요.

## Architecture

MVVM + Repository 패턴을 사용합니다.

```
Screen (View) → ViewModel (Provider) → Repository → AppDatabase (SQLite)
```

- **Screens** (`lib/screens/`): UI만 담당. ViewModel을 `context.watch`/`context.read`로 구독.
- **ViewModels** (`lib/providers/`): `ChangeNotifier` 기반 상태 관리. Repository를 주입받아 사용.
- **Repositories** (`lib/repositories/`): SQLite CRUD. `AppDatabase.instance`를 통해 DB 접근. 모두 싱글턴.
- **AppDatabase** (`lib/services/app_database.dart`): sqflite 싱글턴 래퍼. 현재 버전 2 (persons 테이블에 category 컬럼 추가).

### Provider 주입 방식

- `PersonViewModel`과 `ThemeProvider`는 `main.dart`의 `MultiProvider`에서 앱 전역으로 주입.
- `GiftViewModel`과 `ReportViewModel`은 화면 진입 시 해당 `MaterialPageRoute` 내에서 `ChangeNotifierProvider`로 주입 (페이지 범위 scoping).

### Data Model

`Gift` 모델에서 `direction`은 enum(`GiftDirection`)이지만 DB에는 int(`1` = received, `-1` = given)로 저장됩니다. `signedAmount = amount * direction.dbValue`로 순잔액을 계산합니다.

Person 카테고리는 `lib/screens/home_screen.dart`의 `tabs` 리스트에 하드코딩되어 있습니다: `["전체", "가족", "친구", "직장", "지인", "그외"]`.

## Constants

- `lib/constants/colors.dart`: `primaryColor`(#FF6258), `secondaryColor`(#027DFD), 카테고리별 색상 맵
- `lib/constants/sizes.dart`: 공통 spacing/font 크기 상수
- `lib/constants/gaps.dart`: `Gaps.v8`, `Gaps.h4` 등 미리 정의된 `SizedBox` 위젯

## DB Schema

```sql
persons (id, name, note, category, created_at)
gifts   (id, person_id, amount, direction, category, note, date, created_at)
-- direction: 1=received, -1=given
-- date, created_at: millisecondsSinceEpoch
```

스키마 변경 시 `AppDatabase._dbVersion`을 올리고 `_onUpgrade`에 마이그레이션 로직을 추가하세요.

## Error Monitoring

Repository의 모든 DB 작업은 `try/catch`로 감싸며 `Sentry.captureException`으로 에러를 보고합니다 (prod 전용). dev 환경에서는 `debugPrint`만 출력됩니다.
