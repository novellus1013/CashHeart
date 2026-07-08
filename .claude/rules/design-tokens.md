# 디자인 토큰 사용 규칙

색상·치수·간격은 하드코딩하지 않고 정의된 토큰을 통해서만 사용한다. Sprint 2에서 라이트/다크 테마(`lib/theme/`)를 도입하면 토큰 일치가 다크모드 전환의 전제가 된다.

## 색상 — `lib/constants/colors.dart`

- 브랜드: `primaryColor`(#FF6258), `secondaryColor`(#027DFD).
- 카테고리 색은 `getCategoryColor(category)` 로만 조회. `categoryColors` 맵 밖의 리터럴 색을 화면에서 직접 쓰지 않는다.
- **금지**: 위젯 코드에 `Color(0xFF...)` 리터럴 직접 삽입. 새 색이 필요하면 `colors.dart`(또는 Sprint 2의 테마)에 토큰으로 추가한 뒤 참조한다.
- 다크모드 대응(Sprint 2+): 색은 `Theme.of(context).colorScheme` 또는 테마 토큰에서 가져오고, 라이트/다크 페어로 정의한다. 관계 균형 인디케이터(balanced/tilted/severe)도 토큰으로.

## 치수 — `lib/constants/sizes.dart`

- 폭/높이/패딩/폰트 크기 등 수치는 `Sizes.sizeN`(size1~size96) 사용. 매직 넘버(`padding: EdgeInsets.all(16)`) 대신 `Sizes.size16`.

## 간격 — `lib/constants/gaps.dart`

- 위젯 사이 여백은 새 `SizedBox(height/width: ...)` 대신 `Gaps.vN`(세로) / `Gaps.hN`(가로) 사용.

## 검증

- 리뷰/게이트에서 위젯 파일의 `Color(0xFF`, `SizedBox(height:` / `SizedBox(width:` 숫자 리터럴, `EdgeInsets.*(\d` 매직넘버를 신규 유입 여부로 점검한다.
- 기존 코드의 잔존 하드코딩은 UI 리뉴얼(Sprint 2~3)에서 토큰으로 흡수한다.
