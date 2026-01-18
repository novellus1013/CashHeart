# CashHeart - 경조사비 기록 · 관리

경조사비를 쉽고 체계적으로 관리할 수 있는 Flutter 기반 모바일 애플리케이션입니다.

## 다운로드 

| App Store | Google Play |
|---|---|
| [<img width="120" height="40" alt="App Store" src="https://github.com/user-attachments/assets/2d85e984-1949-4262-9aae-63f36ca00726" />](https://apps.apple.com/kr/app/cashheart-%EA%B2%BD%EC%A1%B0%EC%82%AC%EB%B9%84-%EA%B8%B0%EB%A1%9D-%EA%B4%80%EB%A6%AC/id6755832129) | [<img width="120" height="40" alt="Google Play" src="https://github.com/user-attachments/assets/bcc419e6-1d8c-44bf-b5df-1454f3c89df9" />](https://play.google.com/store/apps/details?id=co.novelus.cashheart) |

## 앱 소개

### 화면
<p align="center">
  <img width="22%" height="2532" alt="home" src="https://github.com/user-attachments/assets/7216c3da-86a4-49fd-9ccc-eefdc6ca75fe" />
  <img width="22%" height="2532" alt="detail" src="https://github.com/user-attachments/assets/2bcd8623-24a7-4a02-be65-1246ddebb052" />
  <img width="22%" height="2532" alt="report" src="https://github.com/user-attachments/assets/d04b536f-2c7c-4a00-8074-9298aa4c4e0a" />
  <img width="22%" height="2532" alt="settings" src="https://github.com/user-attachments/assets/a1752b40-ce35-4891-b773-12ca98a2eb37" />
</p>

### 컨셉
CashHeart는 경조사 문화에서 주고받는 축의금, 조의금 등의 금전 거래를 기록하고 관리하는 앱입니다.
"누구에게 얼마를 받았는지", "누구에게 얼마를 줬는지"를 한눈에 파악하여 인간관계에서 금전적 균형을 유지할 수 있도록 도와줍니다.

### 이런 분에게 추천드립니다.
- 경조사비를 체계적으로 관리하고 싶은 분
- 지인들과의 금전 거래 내역을 기록해두고 싶은 분
- 받은 만큼 돌려주는 것을 중요하게 생각하는 분
- 가족, 친구, 직장 동료 등 다양한 관계의 경조사비를 분류하여 관리하고 싶은 분

## 주요 기능

### 1. 인맥 관리
- 지인 등록/수정/삭제
- 카테고리별 분류 (가족, 친구, 직장, 지인, 그외)
- 메모 기능으로 추가 정보 기록

### 2. 거래 내역 관리
- 받은 돈/준 돈 기록
- 경조사 유형별 분류 (결혼, 장례, 출산, 입학, 취업, 생일, 명절, 기념일, 기타)
- 날짜 및 메모 기록
- 스와이프로 간편한 수정/삭제

### 3. 통계 및 리포트
- 총 수입/지출 현황
- 월별 거래 추이 분석
- 카테고리별 통계 (도넛 차트)
- 가장 많이 받은/준 인맥 TOP 5

### 4. 사용자 경험
- 다크모드/라이트모드 지원
- Pretendard 폰트 적용
- 직관적인 UI/UX

## 기술 스택 및 아키텍처

### 아키텍처
```
lib/
├── config/          # 환경 설정 (dev/prod)
├── constants/       # 상수 (색상, 사이즈, 간격)
├── models/          # 데이터 모델
│   ├── person.dart
│   ├── gift.dart
│   └── gift_types.dart
├── providers/       # 상태 관리 (ViewModel)
│   ├── person_view_model.dart
│   ├── gift_view_model.dart
│   ├── report_view_model.dart
│   └── theme_provider.dart
├── repositories/    # 데이터 액세스 계층
│   ├── person_repository.dart
│   └── gift_repository.dart
├── screens/         # 화면 UI
│   ├── home_screen.dart
│   ├── person_detail_screen.dart
│   ├── add_edit_person_screen.dart
│   ├── add_edit_gift_screen.dart
│   ├── report_screen.dart
│   └── setting_screen.dart
├── services/        # 서비스 (Mock 데이터 등)
├── utils/           # 유틸리티 함수
├── widgets/         # 재사용 위젯
└── main.dart        # 앱 진입점
```

### 디자인 패턴
- **MVVM 패턴**: Model-View-ViewModel 구조로 관심사 분리
- **Repository 패턴**: 데이터 소스 추상화
- **Provider 패턴**: Flutter의 상태 관리

### 데이터베이스
- **SQLite (sqflite)**: 로컬 데이터 영구 저장
- Person과 Gift 테이블 간 1:N 관계
- CASCADE DELETE로 데이터 무결성 유지

## 사용 패키지

### 핵심 패키지
| 패키지 | 버전 | 용도 |
|--------|------|------|
| `provider` | ^6.1.5+1 | 상태 관리 |
| `sqflite` | ^2.4.2 | SQLite 데이터베이스 |
| `path_provider` | ^2.1.5 | 파일 시스템 경로 |
| `shared_preferences` | ^2.2.2 | 설정값 저장 (테마 등) |

### UI/UX 패키지
| 패키지 | 버전 | 용도 |
|--------|------|------|
| `intl` | ^0.20.2 | 날짜/통화 포맷팅 |
| `table_calendar` | ^3.2.0 | 캘린더 위젯 |
| `flutter_slidable` | ^4.0.3 | 스와이프 액션 |

### 개발/배포 패키지
| 패키지 | 버전 | 용도 |
|--------|------|------|
| `sentry_flutter` | ^9.8.0 | 에러 모니터링 |
| `package_info_plus` | ^8.2.0 | 앱 버전 정보 |
| `flutter_native_splash` | ^2.4.4 | 스플래시 화면 |
| `flutter_launcher_icons` | ^0.14.4 | 앱 아이콘 생성 |

## 환경 설정

### 개발/프로덕션 환경
`lib/config/app_config.dart`에서 환경을 설정할 수 있습니다.

```dart
// 개발 환경: Mock 데이터 사용
AppConfig.setDev();

// 프로덕션 환경: Sentry 에러 모니터링 활성화
AppConfig.setProd();
```

---
    
