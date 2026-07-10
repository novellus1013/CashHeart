# 디자인 토큰 사용 규칙

색상·치수·간격은 하드코딩하지 않고 정의된 토큰을 통해서만 사용한다. Sprint 2 Phase B에서 `lib/theme/`가 도입되어 색 토큰의 정식 소스가 됐다.

## 색상 — `lib/theme/app_colors.dart` (신규 코드), `lib/constants/colors.dart` (기존 화면 호환)

- **신규 코드는 `Theme.of(context).extension<AppColors>()!`로 색을 가져온다.** 필드: `primary`(#FF6258 계열), `secondary`(#027DFD 계열), `primarySoft/secondarySoft`, `bg/surface`, `text/text2/text3`, `border/borderSoft`, 관계 균형 인디케이터 `balanced/tilted/severe`(`lib/theme/balance_state.dart`의 `BalanceState`와 함께 사용).
- **준/받은 마음 색은 `primary`/`secondary`를 직접 쓰지 말고 반드시 `colors.given`/`colors.received` getter로 접근한다.** 최종 결정(2026-07-10 시안 검수): `given`=파랑 계열(`secondary` 값), `received`=빨강 계열(`primary` 값) — 기존 화면(`total_card.dart`, `home_screen.dart`의 `_LastGiftInfo` 등)의 관습과 동일. design_handoff 문서 원문은 반대로 적혀 있으나(문서 기준으로 한 번 구현했다가 실제 화면에서 어색해 뒤집음) **문서보다 이 규칙이 우선한다.**
- 기존 `lib/constants/colors.dart`의 `primaryColor`/`secondaryColor`/`categoryColors`는 삭제되지 않았고 기존 화면에서 계속 쓰인다(하위 호환). 신규 위젯은 `AppColors`를 우선 사용.
- 모서리 반경은 `lib/theme/app_radii.dart`(`AppRadii`), 타이포그래피는 `lib/theme/app_text_styles.dart`(`AppTextStyles`) 참고.
- **금지**: 위젯 코드에 `Color(0xFF...)` 리터럴 직접 삽입. 새 색이 필요하면 `AppColors`에 토큰으로 추가한 뒤 참조한다.

## 치수 — `lib/constants/sizes.dart`

- 폭/높이/패딩/폰트 크기 등 수치는 `Sizes.sizeN`(size1~size96) 사용. 매직 넘버(`padding: EdgeInsets.all(16)`) 대신 `Sizes.size16`.

## 간격 — `lib/constants/gaps.dart`

- 위젯 사이 여백은 새 `SizedBox(height/width: ...)` 대신 `Gaps.vN`(세로) / `Gaps.hN`(가로) 사용.

## 검증

- 리뷰/게이트에서 위젯 파일의 `Color(0xFF`, `SizedBox(height:` / `SizedBox(width:` 숫자 리터럴, `EdgeInsets.*(\d` 매직넘버를 신규 유입 여부로 점검한다.
- 기존 코드의 잔존 하드코딩은 UI 리뉴얼(Sprint 2~3)에서 토큰으로 흡수한다.
