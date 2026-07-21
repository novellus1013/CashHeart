# 아키텍처 경계 규칙 — MVVM + Repository

계층 흐름을 단방향으로 유지한다. 경계를 넘는 참조는 유지보수·테스트·마이그레이션을 무너뜨린다.

```
Screen (View) → ViewModel (Provider) → Repository → AppDatabase (SQLite)
```

## Screen (`lib/screens/`)

- UI만 담당. 상태는 ViewModel을 `context.watch`(구독) / `context.read`(액션)로만 접근.
- Screen에서 Repository나 `AppDatabase`를 직접 호출하지 않는다. 반드시 ViewModel 경유.
- 비동기 후 `context` 사용 시 `if (!mounted) return;` 가드(현재 info 경고 지점 — 리뉴얼 시 정리).

## ViewModel (`lib/providers/`)

- `ChangeNotifier` 기반. Repository를 **주입**받아 사용(직접 인스턴스화 지양).
- 주입 범위:
  - `PersonViewModel`, `ThemeProvider` → `main.dart` `MultiProvider`(앱 전역).
  - `GiftViewModel`, `ReportViewModel` → 화면 진입 시 `MaterialPageRoute` 내 `ChangeNotifierProvider`(페이지 scoping).
- 상태 변경 후 `notifyListeners()` 호출.

## Repository (`lib/repositories/`)

- SQLite CRUD 전담. DB 접근은 반드시 `AppDatabase.instance` 경유. 모두 싱글턴.
- 모든 DB 작업은 `try/catch`로 감싸고 prod에서 `Sentry.captureException`, dev에서 `debugPrint`로 보고.
- 원시 결과(`rawQuery().first[...]`)는 빈 결과 가드 후 접근(Sprint 1 P1 픽스 대상).

## AppDatabase (`lib/services/app_database.dart`)

- sqflite 싱글턴 래퍼. 스키마 변경은 `db-migrator` 서브에이전트 규칙을 따른다(`_dbVersion` +1, `_onUpgrade` 누적, `_onCreate` 동기화).

## 데이터 모델 불변식

- `Gift.direction`은 enum(`GiftDirection`)이지만 DB엔 int(1=received, -1=given)로 저장. `signedAmount = amount * direction.dbValue`.
- Person 카테고리는 현재 `home_screen.dart` `tabs`에 하드코딩(`["전체","가족","친구","직장","지인","그외"]`) — 커스텀화는 v2.0.1 후보.

## 금지

- View → Repository/DB 직접 접근.
- Repository 안에서 UI(SnackBar/Navigator) 호출.
- 계층 역방향 의존(Repository가 ViewModel/Screen 참조).
