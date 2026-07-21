# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

CashHeart는 경조사비(축의금·조의금 등)를 기록·관리하는 Flutter 모바일 앱입니다. App Store와 Google Play Store에 MVP 버전이 배포되어 있습니다.

## Commands

```bash
# 실행 (시뮬레이터/디바이스)
flutter run

# 빌드 (prod: SENTRY_DSN 필수 — 없으면 Sentry가 조용히 비활성화됨)
flutter build apk --dart-define=SENTRY_DSN=<값>           # Android
flutter build ios --dart-define=SENTRY_DSN=<값>           # iOS

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

Sentry DSN은 코드에 하드코딩하지 않고 `String.fromEnvironment('SENTRY_DSN')`로 주입합니다(`lib/main.dart`). 실제 값은 GitHub repo secret `SENTRY_DSN`에 등록되어 있으며(`gh secret set SENTRY_DSN --repo novellus1013/CashHeart`), prod 빌드 시 `--dart-define=SENTRY_DSN=<값>`으로 전달해야 합니다. 누락 시 크래시 없이 Sentry 전송만 조용히 꺼지므로 배포 전 체크리스트에 반드시 포함하세요.

## Architecture

MVVM + Repository 패턴을 사용합니다.

```
Screen (View) → ViewModel (Provider) → Repository → AppDatabase (SQLite)
```

- **Screens** (`lib/screens/`): UI만 담당. ViewModel을 `context.watch`/`context.read`로 구독.
- **ViewModels** (`lib/providers/`): `ChangeNotifier` 기반 상태 관리. Repository를 주입받아 사용.
- **Repositories** (`lib/repositories/`): SQLite CRUD. `AppDatabase.instance`를 통해 DB 접근. 모두 싱글턴.
- **AppDatabase** (`lib/services/app_database.dart`): sqflite 싱글턴 래퍼. 현재 버전 3 (Sprint 1: `gifts(person_id, date)` 복합 인덱스 추가).

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
- `lib/theme/` (Sprint 2 Phase B~): `AppColors`(`ThemeExtension`, 라이트/다크 페어), `AppRadii`, `AppTextStyles`, `BalanceState` — 신규 위젯은 `Theme.of(context).extension<AppColors>()!`를 우선 사용. 규칙은 `.claude/rules/design-tokens.md` 참고.
- `lib/widgets/`의 Sprint 2 Phase B 신규 컴포넌트(`HeroCard`, `BalanceVisualization`, `PillNav`, `RelationshipRow`)는 아직 실제 화면에 연결되지 않았습니다(Sprint 3에서 연결 예정). `lib/screens/dev_component_gallery_screen.dart`(`AppConfig.isDev`일 때 홈 화면 AppBar 팔레트 아이콘으로 진입)에서 미리보기 가능 — Sprint 3 작업 시작 전 참고.

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

---

# v2.0 작업 컨텍스트

현재 **v2.0.0 큰 기능 확장** 진행 중. PRFAQ + UI 사양 완료. Sprint 0–6으로 분해.

**Sprint 상태** (최신은 `docs/sprints/ROADMAP.md` 참고): Sprint 0 완료(dev 머지) → Sprint 1 완료(DB v3 마이그레이션, dev 미머지) → Sprint 2 Phase A+B 완료(설정화면 정비/인프라 하드닝 + 디자인 토큰·핵심 컴포넌트, dev 미머지) → **Sprint 3 구현 완료**(9화면 중 6개 실제 통합, `feat/sprint-3-ui-integration`) — **카피 톤 사용자 게이트만 대기 중**, 통과 전까지 dev 머지 보류.

> ⚠️ 다크모드는 이미 v1.1부터 구현되어 있다(`lib/providers/theme_provider.dart`). Sprint 2는 다크모드 "도입"이 아니라 디자인 토큰 체계 구축이다.

### 산출물 위치

- **`docs/sprints/ROADMAP.md`** — Sprint 0–6 상세 스코프 + 부록(버그 백로그/개선 의견/위험) **마스터 문서**. repo 안에 존재하지만 gitignore 처리(비공개 작업 문서). 세션 시작 시 이 문서를 최신 상태로 우선 참고.
- `_bmad-output/planning-artifacts/prfaq-CashHeart-distillate.md` — PRFAQ 압축 (gitignore)
- `_bmad-output/planning-artifacts/ui-prompt-CashHeart-v2.md` — UI 사양 (gitignore)
- `design_handoff_cashheart/README.md` — Claude Design 9 화면 prototype (gitignore)

> `~/.claude/plans/`(plan-mode 스크래치 영역)에는 로드맵을 두지 않는다 — 세션 사이에 정리되어 유실된 전례가 있음(2026-07-10). 상세 계획은 항상 `docs/sprints/`에 커밋 대상 밖으로 보관한다.

## 어필 4축 (커리어 어필 목적)

v2.0 작업의 핵심. 모든 sprint는 이 중 1개 이상에 기여해야 한다.

1. **AI 도입의 수치적 증명** ⭐ — 모든 sprint가 측정 지표 누적에 기여
2. Flutter 설계/아키텍처 — Sprint 1–3 집중
3. Claude Code 활용 (skills/subagents/hooks/MCP) — Sprint 0 인프라
4. Test + Architecture + CI/CD + Code Review — Sprint 0 베이스라인, 모든 sprint 게이트

## AI 효과 측정 지표

**생산성** (`tools/metrics/`에 commit 단위 누적)

- LLM 생성/가공 LOC 비율 (commit-msg hook이 자동 기록)
- Story 1개당 소요 시간 (bmad-dev-story 시작/종료)

**품질**

- `flutter analyze` warning 카운트 (commit 단위 추이)
- 테스트 커버리지 (lcov 누적)
- 버그 발견율 (issue 라벨 + Sentry crash rate)

출시 시점에 Sprint 0 베이스라인 vs 출시 직전 비교 그래프 산출 → 어필 1번의 정량 근거.

## Sprint Workflow

각 sprint 표준 흐름:

1. `bmad-dev-story`로 story 분해
2. LLM이 코드 작성 (사람은 watch)
3. pre-commit hook → `flutter analyze` 차단
4. `/code-review high` adversarial 게이트 (codex 구독 미보유로 `/codex review`는 실제로 쓰인 적 없음 — Sprint 6에서 문서를 실제 practice로 정정, PR #7~#14 전부 `/code-review high` 사용)
5. **사용자 검수 게이트** (sprint별로 명시된 시점만 — 톤·데이터·정책·시안)
6. `feat/sprint-{N}-{topic}` → `dev` PR
7. hook이 측정 지표를 `tools/metrics/sprint-{N}.json`에 누적

### Git Branch

- `main` 출시 가능 (App Store / Play Store 동기화)
- `dev` 통합
- `feat/sprint-{N}-{topic}` 작업

### Sprint 사용자 직접 개입 시점 (sprint plan에서 발췌)

- Sprint 0: CLAUDE.md 컨벤션 검토 + hook 시연 동의 ✅
- Sprint 1: 실 기기 v1.1 → v2.0 데이터 보존 검증 ✅
- Sprint 2 Phase A: 없음 — 5개 항목 모두 사용자 결정 완료(2026-07-10) ✅
- Sprint 2 Phase B: 디자인 토큰(`lib/theme/`)·핵심 컴포넌트 시안 톤 검수 ✅ (다크모드는 이미 구현됨, 이 sprint는 토큰화 작업)
- Sprint 3 (← 지금 단계, 구현 완료·게이트 대기): 비난조 카피 검수, 균형 시각화 톤 확정
- Sprint 4: 9 카드 변형 시안 검수 + AI 메시지 A/B 결과 검토
- Sprint 5: iOS App Store Guideline 2.4.5 본인 검토 + 강제/권장 업데이트 정책 결정
- Sprint 6: ASO 자산 직접 작성(랜딩은 Sprint 2 Phase A에서 이미 완료 — 키워드/아이콘/스크린샷 카피만 남음), 출시 후 30일 Sentry 모니터링(런북은 준비되나 실행은 실제 출시 이후)

## Design Tone Rules (비협상 — PRFAQ 결정)

모든 카피·시각화·아이콘에 적용.

- ❌ 비난조 금지: "부족", "낮은", "차이남", "균형이 깨졌습니다", "더 많이 주고 있습니다"
- ❌ 방향성 화살표 (↑↓→) 금지 — 판단처럼 읽힘. 방향은 _형태_(게이지 기울기, 막대 비율)와 *부드러운 색*으로만 전달
- ✅ 따뜻한 정(情) 어휘: "오고 간 정", "주고받은 마음", "5년간 9번의 마음"
- ✅ 일방성은 사실로만 전달: "이 관계는 한쪽으로 흐르고 있어요" / "주고받음이 균형 잡혀 있어요"
- 카드 톤: 금액 강조 X, 관계의 시간에 무게
- 색 매핑(Sprint 2 확정): 준 마음(given)=파랑, 받은 마음(received)=빨강 — `AppColors.given`/`.received`로만 참조(`design_handoff_cashheart` 문서 원문과 반대이니 문서 보고 되돌리지 말 것). balanced/tilted/severe는 방향 무관, 치우침 크기만 반영. 상세는 `.claude/rules/copy-tone.md`.

## .gitignore 정책

**커밋 (공유 가치 있음 — 어필 2/3/4 증거)**

- `CLAUDE.md` (project level)
- `.claude/agents/` (subagent 정의)
- `.claude/rules/` (코드/카피 규칙)
- `.claude/settings.json` (hooks 블록, secret 제외)
- `.mcp.json` (project MCP 설정, secret 제외)
- `.github/workflows/` (CI/CD)
- `test/`, `tools/metrics/`

**무시 (private/임시)**

- `_bmad/`, `_bmad-output/` (bmad 산출)
- `.claude/skills/` (bmad 자동 설치 skill 54개)
- `.claude/settings.local.json` (개인 권한 설정, secret 포함 가능)
- `docs/` (sprint 계획서는 `docs/sprints/`에 두어 자동 ignore)
- `design_handoff_cashheart/` (Claude Design 참고 prototype)

## Subagents (`.claude/agents/`)

- `flutter-tester` — `flutter analyze` + `flutter test` 실행 및 영향 받는 테스트 식별
- `db-migrator` — 스키마 변경 시 마이그레이션 함수 생성/검증 (in-memory sqflite 테스트 포함)

## Hooks (`.claude/settings.json` — Claude Code 훅)

git 훅이 아니라 Claude Code 훅으로 구현. `git commit` Bash 호출을 가로챈다. 스크립트 실체는 `tools/hooks/`에 있다.

- **PreToolUse (analyze 게이트)** → `tools/hooks/pre_commit_gate.sh`: `git commit` 시 `flutter analyze` 실행, **warning/error 0건이 아니면 exit 2로 커밋 차단** (info는 차단 안 함, 추이로만 기록). flutter 부재 등 환경 문제로는 차단하지 않음.
- **PostToolUse (지표 기록)** → `tools/hooks/post_commit_metrics.sh` → `tools/metrics/record_commit.py`: `git commit` 성공 후 LOC(+/-)·변경 파일 수·analyze 카운트·LLM 저작 여부(`Co-Authored-By: Claude` 트레일러)를 `tools/metrics/sprint-{N}.json`에 append. non-blocking(항상 exit 0).

집계는 `python3 tools/metrics/summary.py`. 지표 정의는 `tools/metrics/README.md`.

## Rules (`.claude/rules/`)

- `copy-tone.md` — 비난조 금지·화살표 금지·정(情) 어휘 (Sprint 3·4 카피 게이트)
- `design-tokens.md` — 색/치수/간격 하드코딩 금지, `colors.dart`·`Sizes`·`Gaps` 토큰 사용 (Sprint 2 대비)
- `architecture.md` — MVVM+Repository 계층 경계

## MCP (`.mcp.json`)

**미채택.** Sprint 0에서 보류 후 Sprint 6에서 항목별로 재검토해 확정:

- **GitHub MCP — 미채택 확정.** PR 조회/생성 등 필요한 작업은 이미 인증된 `gh` CLI로 충분(PR #7~#14 감사, PR 생성 모두 `gh`로 처리). CI/CD(`ci.yml`)도 정적 YAML 파일이라 MCP 없이 작성.
- **Sentry MCP — 미채택 유지, 부록 E(출시 후 30일 KPI, `docs/sprints/ROADMAP.md`) 실행 시점에 재검토.** 현재는 v2.0 미출시라 크래시 데이터 자체가 없어 무의미. 실제 출시 후 "Claude Code가 크래시 데이터를 직접 조회/요약"하는 워크플로우가 필요해지면 그때 도입 검토(secret 관리 부담 대비 실익 재평가).
