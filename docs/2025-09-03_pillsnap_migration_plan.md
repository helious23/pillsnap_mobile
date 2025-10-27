# PillSnap 프로젝트 마이그레이션 계획

_작성일: 2025-09-03_  
_작성자: PillSnap Engineering Team_

## 📋 프로젝트 개요

PillSnap Flutter 애플리케이션을 기존 screens 기반 구조에서 Feature-first + Clean Architecture로 전환하는 마이그레이션 계획서입니다.

### 목표

- Feature-first + Layered Architecture 적용
- Riverpod 상태관리 도입
- go_router 기반 라우팅 시스템
- 국제화(i18n) 지원
- Assets 스크린샷과 100% 일치하는 UI 구현

## 🏗️ 아키텍처 원칙

### 강제 규칙

1. **폴더 구조**: `features/<feature>/{presentation,domain,data}` 고수
2. **상태관리**: Riverpod 최신 API(Notifier/AsyncNotifier)만 사용
3. **라우팅**: go_router 사용, 모든 경로는 `core/router/route_paths.dart` 상수 참조
4. **스타일링**: theme/ 토큰만 사용, 하드코딩 금지
5. **네이밍 규칙**:
   - 파일: snake_case
   - 클래스: UpperCamelCase
   - 컨트롤러: 기능+Controller/Notifier
6. **국제화**: 모든 문자열은 l10n ARB 통해 근접
7. **텍스트 제한**: 모든 문장 2줄 이내

### 기술 스택

```yaml
dependencies:
  # 라우팅
  go_router: ^14.0.0

  # 상태관리
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # 모델/직렬화
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # 유틸리티
  dartz: ^0.10.1

  # UI/UX
  device_preview: ^1.2.0

  # 권한/카메라 (추후 추가)
  # permission_handler: ^11.0.0
  # camera: ^0.10.0

dev_dependencies:
  # 코드 생성
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0

  # 테스트
  mocktail: ^1.0.4

  # 린트
  flutter_lints: ^3.0.0
```

## 📁 프로젝트 구조

```
lib/
├── core/                       # 앱 전역 공통
│   ├── error/                  # 에러 처리
│   ├── network/                # 네트워크 설정
│   ├── widgets/                # 공통 위젯
│   │   ├── buttons/
│   │   ├── inputs/
│   │   ├── dialogs/
│   │   └── bottom_navigation/
│   ├── utils/                  # 유틸리티
│   ├── router/                 # go_router 설정
│   │   ├── route_paths.dart   # 라우트 상수
│   │   └── app_router.dart    # 라우터 구성
│   └── i18n/                   # 국제화 헬퍼
├── theme/                      # 테마 시스템
│   └── app_theme.dart          # 색상/타이포/간격 토큰
├── features/
│   ├── auth/                   # 인증 기능
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── repositories/
│   │   │   └── models/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── email_input_page.dart
│   │       │   ├── code_verification_page.dart
│   │       │   └── password_setup_page.dart
│   │       ├── widgets/
│   │       └── controllers/
│   ├── onboarding/
│   ├── camera/
│   ├── drug/
│   └── settings/
├── l10n/                       # 국제화 파일
│   ├── app_ko.arb
│   └── app_en.arb
└── main.dart
```

## 🚀 마이그레이션 Phase

### Phase 0: 즉시 작업 - 기본 설정 (30분)

#### 작업 내용

1. **pubspec.yaml 업데이트**

   - 필수 패키지 추가
   - scripts 섹션 추가 (build, watch, lint, gen:l10n)
   - assets/ 경로 등록
   - fonts (Inter) 등록

2. **analysis_options.yaml 생성**

   - Effective Dart 규칙 적용
   - 불필요 파일 제외 설정
   - 린트 규칙 구성

3. **core/router 스켈레톤**

   - route_paths.dart: 라우트 상수 정의
   - app_router.dart: go_router 구성
   - 라우트 가드 및 리다이렉트 규칙

4. **features 디렉토리 구조 생성**
   - 각 feature별 폴더 구조 생성
   - 기존 screens 파일 마이그레이션 준비

#### 완료 조건

- [ ] flutter pub get 성공
- [ ] flutter analyze 에러 0개
- [ ] 기본 라우팅 동작 확인
- [ ] 디렉토리 구조 완성

### Phase 1: Auth 화면 마이그레이션 (2시간)

#### 작업 내용

1. **login_page.dart** (01.login_page.png 기준)

   - 소셜 로그인 버튼
   - 이메일 로그인 옵션
   - 회원가입 링크

2. **email_input_page.dart** (02.email_input.png 기준)

   - 이메일 입력 필드
   - 유효성 검사
   - 다음 버튼

3. **code_verification_page.dart** (03.code_input.png 기준)

   - 6자리 인증 코드 입력
   - 재전송 기능
   - 타이머 표시

4. **password_setup_page.dart** (04.password_input.png 기준)
   - 비밀번호 입력
   - 비밀번호 확인
   - 강도 표시기

#### 완료 조건

- [ ] 4개 화면 assets와 100% 일치
- [ ] AuthController/AuthNotifier 구현
- [ ] 라우팅 동작 확인
- [ ] 문장 2줄 이내 확인

### Phase 2: Onboarding 화면 마이그레이션 (1시간)

#### 작업 내용

1. **onboarding_page.dart** (05-07.png 기준)
   - PageView로 3개 화면 통합
   - 도트 인디케이터
   - 건너뛰기/다음 버튼
   - 애니메이션 전환

#### 완료 조건

- [ ] 3개 슬라이드 정확한 구현
- [ ] 페이지 전환 애니메이션
- [ ] 온보딩 완료 후 홈 이동

### Phase 3: Home 화면 마이그레이션 (2시간)

#### 작업 내용

1. **home_page.dart** (08.home_page.png 기준)

   - 헤더 섹션 (환영 메시지)
   - 최근 촬영 알약 섹션
   - 빠른 실행 버튼들
   - 일일 복용 알림 카드

2. **curved_bottom_navigation.dart**
   - 곡선 디자인 네비게이션
   - 3개 탭 (홈, 카메라, 설정)
   - 선택 애니메이션

#### 완료 조건

- [ ] 홈 화면 레이아웃 완성
- [ ] 하단 네비게이션 동작
- [ ] 스크린샷과 픽셀 일치

### Phase 4: Camera 화면 마이그레이션 (3시간)

#### 작업 내용

1. **single_pill_camera_page.dart** (09-1.png 기준)

   - 카메라 프리뷰
   - 십자선 오버레이
   - 줌 컨트롤 (1x, 2x, 3x)
   - 플래시 토글

2. **multi_pill_camera_page.dart** (09-2.png 기준)

   - 복수 알약 모드
   - 그리드 가이드라인
   - 자동 감지 표시

3. **camera_guide_page.dart** (10-1, 10-2.png 기준)

   - 촬영 가이드 단계별 설명
   - 이미지 예시
   - 팁 제공

4. **camera_result_page.dart** (12.png 기준)
   - 식별 결과 표시
   - 신뢰도 표시
   - 재촬영/확인 버튼

#### 위젯 분리

```
widgets/
├── camera_preview.dart
├── crosshair_overlay.dart
├── zoom_controls.dart
├── flash_toggle.dart
├── pill_result_card.dart
└── confidence_indicator.dart
```

#### 완료 조건

- [ ] 4개 카메라 화면 완성
- [ ] 위젯 컴포넌트 분리
- [ ] UI 요소 정확한 배치

### Phase 5: Drug Detail 화면 마이그레이션 (1시간)

#### 작업 내용

1. **drug_detail_page.dart** (13-14.png 기준)
   - 약물 이미지 갤러리
   - 기본 정보 섹션
   - 복용 방법
   - 부작용 정보
   - 주의사항

#### 완료 조건

- [ ] 상세 정보 레이아웃
- [ ] 이미지 갤러리 동작
- [ ] 스크롤 가능 콘텐츠

### Phase 6: Settings 화면 마이그레이션 (30분)

#### 작업 내용

1. **settings_page.dart**
   - 프로필 섹션
   - 알림 설정
   - 언어 설정
   - 앱 정보
   - 로그아웃

#### 완료 조건

- [ ] 설정 항목 리스트
- [ ] 토글/선택 동작
- [ ] 네비게이션 연결

### Phase 7: 공통 컴포넌트 추출 (1시간)

#### 작업 내용

```
core/widgets/
├── buttons/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── icon_button.dart
├── inputs/
│   ├── text_field.dart
│   ├── search_field.dart
│   └── otp_field.dart
├── dialogs/
│   ├── confirmation_dialog.dart
│   └── loading_dialog.dart
└── chips/
    ├── tag_chip.dart
    └── filter_chip.dart
```

#### 완료 조건

- [ ] 재사용 가능한 컴포넌트
- [ ] 일관된 스타일 적용
- [ ] theme 토큰 사용

### Phase 8: 라우팅 통합 (1시간)

#### 작업 내용

1. **go_router 전체 통합**

   - 모든 라우트 연결
   - 네스티드 라우팅
   - 라우트 가드 구현

2. **main.dart 업데이트**

   - MaterialApp.router 전환
   - ProviderScope 추가
   - 초기화 로직

3. **기존 screens 폴더 정리**
   - 레거시 코드 제거
   - import 경로 업데이트

#### 완료 조건

- [ ] 모든 화면 라우팅 동작
- [ ] 딥링크 지원
- [ ] 뒤로가기 처리

### Phase 9: i18n 적용 (1시간)

#### 작업 내용

1. **ARB 파일 생성**

   ```arb
   // app_ko.arb
   {
     "appTitle": "PillSnap",
     "welcomeMessage": "안녕하세요!",
     "cameraGuide": "알약을 십자선 중앙에\n위치시켜 주세요"
   }
   ```

2. **하드코딩 문자열 교체**
   - 모든 텍스트 ARB 키로 변경
   - 2줄 제한 버전 작성
   - 다국어 테스트

#### 완료 조건

- [ ] 모든 문자열 l10n 적용
- [ ] 한국어/영어 지원
- [ ] 문장 길이 검증

### Phase 10: 최종 검증 (1시간)

#### 작업 내용

1. **DevicePreview 검증**

   - 다양한 화면 크기 테스트
   - 반응형 레이아웃 확인
   - 접근성 검사

2. **CI/CD 설정**

   ```yaml
   # .github/workflows/flutter.yml
   - flutter analyze
   - flutter format --set-exit-if-changed
   - flutter test
   - flutter build apk
   ```

3. **성능 최적화**
   - const 생성자 사용
   - 불필요한 rebuild 제거
   - 이미지 캐싱

#### 완료 조건

- [ ] 모든 테스트 통과
- [ ] 린트 에러 0개
- [ ] 빌드 성공
- [ ] 성능 기준 충족

## 📝 Scripts 설정

```yaml
# pubspec.yaml scripts 섹션
scripts:
  # 빌드
  build: flutter pub run build_runner build --delete-conflicting-outputs
  watch: flutter pub run build_runner watch --delete-conflicting-outputs

  # 품질
  lint: flutter analyze && flutter format . --set-exit-if-changed
  fix: dart fix --apply && flutter format .

  # 국제화
  gen:l10n: flutter gen-l10n

  # 테스트
  test: flutter test
  test:coverage: flutter test --coverage

  # 실행
  dev: flutter run --device-id chrome
  dev:ios: flutter run --device-id ios
  dev:android: flutter run --device-id android
```

## ✅ Phase별 체크리스트

### 공통 체크리스트

각 Phase 완료 시 반드시 확인:

- [ ] Assets 스크린샷과 100% UI 일치
- [ ] flutter analyze 에러 없음
- [ ] 모든 문장 2줄 이내
- [ ] theme 토큰만 사용 (하드코딩 없음)
- [ ] l10n 키 등록 완료
- [ ] DevicePreview 검증 통과
- [ ] 파일명 snake_case 준수
- [ ] 클래스명 UpperCamelCase 준수
- [ ] Git 커밋 단위 적절함

## 🚨 주의사항

### 금지사항

1. ❌ 하드코딩된 색상/폰트/간격
2. ❌ 위젯 내 비즈니스 로직
3. ❌ Riverpod legacy API 사용
4. ❌ 문자열 하드코딩
5. ❌ Effective Dart 규칙 위반
6. ❌ 150줄 이상의 위젯 파일

### 권장사항

1. ✅ 작은 단위 커밋
2. ✅ Phase별 PR 생성
3. ✅ 코드 리뷰 진행
4. ✅ 테스트 우선 작성
5. ✅ 문서화 동시 진행

☐ Phase 0: 즉시 작업 - 기본 설정
☐ 0.1 pubspec.yaml 업데이트 (의존성, scripts, assets, fonts)
☐ 0.2 analysis_options.yaml 생성 (Effective Dart 규칙)
☐ 0.3 core/router 스켈레톤 생성 (route_paths, app_router)
☐ 0.4 features 디렉토리 구조 생성
☐ Phase 1: Auth 화면 마이그레이션 (assets 기준)
☐ 1.1 login_page (01.login_page.png 기준)
☐ 1.2 email_input_page (02.email_input.png 기준)
☐ 1.3 code_verification_page (03.code_input.png 기준)
☐ 1.4 password_setup_page (04.password_input.png 기준)
☐ Phase 2: Onboarding 화면 마이그레이션
☐ 2.1 onboarding_pages (05-07.png 기준, PageView 통합)
☐ Phase 3: Home 화면 마이그레이션
☐ 3.1 home_page (08.home_page.png 기준)
☐ 3.2 curved_bottom_navigation 구현
☐ Phase 4: Camera 화면 마이그레이션
☐ 4.1 single_pill_camera_page (09-1.png 기준)
☐ 4.2 multi_pill_camera_page (09-2.png 기준)
☐ 4.3 camera_guide_pages (10-1, 10-2.png 기준)
☐ 4.4 camera_result_page (12.png 기준)
☐ Phase 5: Drug Detail 화면 마이그레이션
☐ 5.1 drug_detail_page (13-14.png 기준)
☐ Phase 6: Settings 화면 마이그레이션
☐ 6.1 settings_page 구현
☐ Phase 7: 공통 컴포넌트 추출
☐ 7.1 core/widgets 공통 컴포넌트화
☐ Phase 8: 라우팅 통합
☐ 8.1 go_router 전체 통합 및 main.dart 업데이트
☐ Phase 9: i18n 적용
☐ 9.1 ARB 파일 생성 및 모든 문자열 교체
☐ Phase 10: 최종 검증
☐ 10.1 DevicePreview 검증 및 CI/CD 설정

## 📊 예상 소요 시간

| Phase    | 작업 내용     | 예상 시간     |
| -------- | ------------- | ------------- |
| Phase 0  | 기본 설정     | 30분          |
| Phase 1  | Auth 화면     | 2시간         |
| Phase 2  | Onboarding    | 1시간         |
| Phase 3  | Home 화면     | 2시간         |
| Phase 4  | Camera 화면   | 3시간         |
| Phase 5  | Drug Detail   | 1시간         |
| Phase 6  | Settings      | 30분          |
| Phase 7  | 공통 컴포넌트 | 1시간         |
| Phase 8  | 라우팅 통합   | 1시간         |
| Phase 9  | i18n 적용     | 1시간         |
| Phase 10 | 최종 검증     | 1시간         |
| **총계** |               | **약 14시간** |

## 🔄 진행 상태

| Phase    | 상태      | 완료일 | 담당자 | 비고 |
| -------- | --------- | ------ | ------ | ---- |
| Phase 0  | 🟡 진행중 | -      | -      | -    |
| Phase 1  | ⏸️ 대기   | -      | -      | -    |
| Phase 2  | ⏸️ 대기   | -      | -      | -    |
| Phase 3  | ⏸️ 대기   | -      | -      | -    |
| Phase 4  | ⏸️ 대기   | -      | -      | -    |
| Phase 5  | ⏸️ 대기   | -      | -      | -    |
| Phase 6  | ⏸️ 대기   | -      | -      | -    |
| Phase 7  | ⏸️ 대기   | -      | -      | -    |
| Phase 8  | ⏸️ 대기   | -      | -      | -    |
| Phase 9  | ⏸️ 대기   | -      | -      | -    |
| Phase 10 | ⏸️ 대기   | -      | -      | -    |

---

_이 문서는 프로젝트 진행에 따라 지속적으로 업데이트됩니다._
