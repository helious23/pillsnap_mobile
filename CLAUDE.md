# CLAUDE.md

### 모든 대답은 반드시 한국어로 해야한다

이 파일은 Claude Code (claude.ai/code)가 이 저장소의 코드를 작업할 때 지침을 제공합니다.

## Flutter 아키텍처 및 코드 생성 규칙 (필수 준수)

### 0) 프로젝트 기본 정보
- **앱명**: PillSnap
- **라우팅**: lib/main.dart에 선언된 기존 라우트 존중
- **테마**: AppTheme.light() 사용 (이미 존재)

### 1) 폴더 구조 (Feature-first + Layered Architecture)
```
lib/
  core/                       # 앱 전역 공통
    error/                    # 에러 처리
    network/                  # 네트워크 설정
    widgets/                  # 공통 위젯
    utils/                    # 유틸리티
    router/                   # go_router 설정
    i18n/                     # 국제화 헬퍼
  theme/                      # AppTheme, 색상/타이포/간격 토큰
  features/
    auth/                     # 인증 기능
      data/                   # datasource, repository 구현
        datasources/
        repositories/
        models/
      domain/                 # entity, repository 인터페이스, usecase
        entities/
        repositories/
        usecases/
      presentation/           # page, widget, state(provider)
        pages/
        widgets/
        controllers/
    onboarding/               # 온보딩
      data/
      domain/
      presentation/
    camera/                   # 카메라 기능
      data/
      domain/
      presentation/
    drug/                     # 약물 정보
      data/
      domain/
      presentation/
    settings/                 # 설정
      data/
      domain/
      presentation/
```

### 2) 라우팅 규칙
- go_router 사용 권장 (core/router/app_router.dart)
- 기존 Navigator.pushNamed 유지 필요시 브릿지 헬퍼 제공
- 딥링크, 웹 경로 호환성 go_router 패턴 사용

### 3) 상태관리 규칙
- **Riverpod** 표준 사용
- AsyncNotifier/Notifier 기반 구성
- 금지사항:
  - 위젯 내 provider 초기화
  - 초기화 단계 side-effect
  - 에페메랄 상태의 Provider 과사용

### 4) 도메인/데이터 레이어
- **Repository 패턴** 필수
- domain/: Entity(불변), Repository 인터페이스, UseCase
- data/: DataSource, RepositoryImpl
- 모델: freezed + json_serializable
- 비동기 결과: Either<Failure, T> 또는 Result<T> 래핑

### 5) 코드 스타일 & 네이밍
- **Effective Dart Style** 준수
- 파일/디렉터리: lowercase_with_underscores
- 타입: UpperCamelCase
- 멤버/변수: lowerCamelCase
- 위젯 150줄 제한

### 6) 테마/디자인 토큰
- 모든 색상/타이포/간격은 theme/ 토큰만 참조
- 직접 하드코딩 금지
- 공통 컴포넌트는 core/widgets/로 추출

### 7) 국제화(i18n)
- flutter gen-l10n 기반
- lib/l10n/arb/*.arb 사용
- 텍스트 하드코딩 금지
- AppLocalizations 통해 접근

### 8) 접근성/반응형
- 최소/최대 텍스트 스케일 대응
- Semantics 사용
- LayoutBuilder/MediaQuery로 반응형 처리

### 9) 테스트 구조
```
test/
  unit/            # usecase, repository 단위 테스트
  widget/          # 화면/위젯 테스트
  integration/     # 라우팅/흐름 테스트
```

### 10) 필수 의존성
- 라우팅: go_router
- 상태관리: riverpod/flutter_riverpod
- 모델: freezed, json_serializable
- 국제화: Flutter gen_l10n
- 테스트: flutter_test, mocktail

### 11) 금지사항
- 하드코딩된 색상/폰트/간격 (theme 토큰 필수)
- 위젯 내 비즈니스 로직
- Riverpod legacy API
- 문자열 하드코딩 (ARB 필수)
- Effective Dart 위반
- withOpacity 사용 금지 (withValues(alpha: value) 사용)

## 프로젝트 개요

PillSnap은 카메라 이미징을 통해 의약품 알약을 식별하는 Flutter 기반 모바일 애플리케이션입니다. 이 앱은 약물 이미지를 캡처하고 분석하기 위한 사용자 친화적인 인터페이스를 제공하며, 단일 및 다중 알약 식별을 모두 지원합니다.

### 현재 진행 상황 (2025-09-03 기준)
- **완료된 Phase**: 0, 1, 2, 3, 4, 5, 6 (전체 70% 완료)
- **아키텍처**: Feature-first + Clean Architecture 적용 완료
- **상태관리**: Riverpod (StateNotifier 패턴)
- **라우팅**: go_router (ShellRoute 활용)
- **API 연동**: 엔티티 구조 API 스펙 정렬 완료
- **카메라 기능**: 기본 촬영, 줌(1x/2x/3x), 탭 포커스 구현 (복잡한 iOS 렌즈 시스템 제거)

## 개발 명령어

### 핵심 Flutter 명령어

```bash
# 개발
flutter run                 # 연결된 기기/에뮬레이터에서 앱 실행
flutter run -d chrome       # Chrome에서 실행 (웹)
flutter run -d ios          # iOS 시뮬레이터에서 실행
flutter run -d android      # Android 에뮬레이터에서 실행

# 빌드
flutter build apk           # Android APK 빌드
flutter build ios           # iOS 앱 빌드 (Xcode가 설치된 Mac 필요)
flutter build web           # 웹 배포용 빌드

# 테스트
flutter test                # 모든 테스트 실행
flutter test test/widget_test.dart  # 특정 테스트 파일 실행

# 코드 품질
flutter analyze             # 정적 분석 실행
flutter format .            # 모든 Dart 파일 포맷팅
```

### 의존성 관리

```bash
flutter pub get             # 의존성 설치
flutter pub upgrade         # 의존성을 최신 버전으로 업그레이드
flutter pub outdated        # 구버전 패키지 확인
```

## 프로젝트 구조

### 현재 구현된 Feature 모듈
```
lib/features/
├── auth/           ✅ 완료 - 로그인, 회원가입, 인증 (UI만)
├── onboarding/     ✅ 완료 - 3단계 온보딩
├── home/           ✅ 완료 - 홈 화면, 최근 촬영
├── camera/         ✅ 완료 - 카메라 UI, 권한 처리, 가이드 모달
├── drug/           ✅ 완료 - 약품 검색 결과, 상세 정보 페이지
└── settings/       🔄 예정 - 앱 설정
```

### 내비게이션 플로우 (go_router 기반)

1. **인증 플로우**: 
   - `/login` → `/auth/email` → `/auth/code` → `/auth/password`
   
2. **온보딩**: 
   - `/onboarding` (PageView 기반 3단계)
   
3. **메인 앱** (ShellRoute): 
   - `/home` - 홈 화면
   - `/camera` - 카메라 (단일/다중 모드)
   - `/camera/loading` - 카메라 로딩 (약 분석 중)
   - `/camera/result` - 검색 결과 페이지
   - `/settings` - 설정
   
4. **상세 화면**:
   - `/drug/:id` - 약품 상세 정보 (탭 구조)

### 테마 시스템

앱은 `lib/theme.dart`에 정의된 중앙집중식 테마 접근 방식을 사용합니다:

- **AppColors**: 기본 색상, 텍스트 색상, 배경 정의
- **AppTextStyles**: Inter 폰트 패밀리를 사용한 일관된 타이포그래피
- **AppTheme**: 커스텀 컴포넌트 스타일이 포함된 Material 3 테마 구성

주요 테마 특징:

- 기본 색상: 파란색 (#1A73E8)
- 일관된 보더 반경: 대부분의 컴포넌트에 12px
- 앱 전체에 한국어 UI 요소

### 주요 UI 컴포넌트

**카메라 기능**:
- 단일/다중 촬영 모드 전환
- 줌 컨트롤 (1x, 2x, 3x) - 하단 컨트롤에만 위치
- 탭하여 포커스/노출 설정
- 플래시 토글
- 촬영 가이드 모달 (하단 시트 형식)
- 십자선 및 원형 가이드라인 오버레이
- 갤러리에서 이미지 선택

**약품 정보**:
- 검색 결과 카드 (정확도 표시)
- 약품 상세 페이지 (4개 탭: 성분, 효능·효과, 용법·용량, 주의사항)
- 약품 이미지 확대 모달 (블러 배경)

**공통 컴포넌트**:
- 커스텀 로딩 인디케이터 (회전하는 알약 애니메이션)
- 곡선 디자인의 하단 네비게이션
- 일관된 버튼 스타일

## 개발 가이드라인

### 상태 관리

Riverpod을 사용한 상태 관리:

- **StateNotifier 패턴**: 복잡한 상태 관리 (예: DrugResultNotifier, DrugDetailNotifier)
- **FutureProvider**: 비동기 데이터 로드 (예: recentCapturesProvider)
- **Provider**: 단순 의존성 주입
- **ConsumerWidget/ConsumerStatefulWidget**: UI 위젯에서 상태 구독

### 코드 스타일

- Flutter 공식 스타일 가이드를 따르세요
- 성능을 위해 가능한 곳에서 `const` 생성자 사용
- 모든 텍스트 위젯에 오버플로우 처리 포함
- 스크린 콘텐츠에 일관된 `SafeArea` 사용

### 플랫폼 고려사항

- Android 최소 SDK는 `android/app/build.gradle.kts`에 구성됨
- iOS 배포 대상은 Runner.xcodeproj에 설정됨
- 웹 지원이 포함되었지만 카메라 권한 처리가 필요할 수 있음

## 테스트 접근법

프로젝트는 기본 위젯 테스트 설정을 포함합니다. 새 기능 추가 시:

- `test/` 디렉토리에서 위젯 테스트 업데이트 또는 생성
- 스크린 간 내비게이션 플로우 테스트
- 새 컴포넌트에 테마 적용 확인

## 환경 요구사항

- Flutter SDK: ^3.8.1
- Dart SDK: Flutter에 포함됨
- 플랫폼 도구:
  - Android: Android SDK가 포함된 Android Studio
  - iOS: Xcode (Mac 전용)
  - 웹: Chrome 또는 기타 최신 브라우저

## 최근 변경사항 (2025-09-07)

### 이미지 전처리 파이프라인 구현
- **구조화 로깅**: StructuredLogger 유틸리티 추가 (trace_id 기반)
- **전처리 메타데이터**: ProcessedImageResult 클래스로 처리 결과 추적
- **예외 처리**: ProcessingException으로 명시적 에러 핸들링
- **업로드 규격**: UploadImageSpec 상수 클래스 정의 (2048px, JPEG Q95)
- **ROI 최적화**: 기본 비활성화, 저신뢰 폴백 경로에서만 활성화
- **책임 분리**:
  - 프론트: 이미지 표준화 (2048px, JPEG Q95, EXIF 픽셀 반영)
  - BFF: 매직넘버 검증, 재인코딩 판단
  - 추론서버: 모델별 전처리 (center-crop 768, letterbox 1024)

## 최근 변경사항 (2025-09-03)

### 카메라 기능 단순화
- **제거된 기능**: 
  - LensBias 시스템 (macro/normal/far 프리셋)
  - SimpleZoomSelector 위젯 (상단 0.5×/1×/2× 버튼)
  - iOS 특화 렌즈 전환 로직
  - 촬영 전 보정 로직
- **유지된 기능**:
  - 하단 줌 컨트롤 (1x/2x/3x)
  - 탭하여 포커스 설정
  - 기본 카메라 기능 (촬영, 플래시, 갤러리)
- **상세 변경 이력**: `docs/camera_modifications_log.md` 참조

## 남은 구현 사항

### 핵심 기능 (우선순위 높음)
1. **API 연동**: https://api.pillsnap.co.kr 실제 연동
2. **카메라 실제 촬영**: camera 패키지 구현, 이미지 업로드
3. **설정 페이지**: 프로필, 알림, 언어 설정

### 사용자 경험 (중간 우선순위)
4. **인증 시스템**: 실제 이메일 인증, 토큰 관리
5. **데이터 영속성**: SharedPreferences/SQLite 연동
6. **알림 기능**: 복약 알림, 로컬 푸시

### 추가 기능 (낮은 우선순위)
7. **다국어 지원**: 영어, 중국어, 일본어
8. **테스트 코드**: 유닛/위젯/통합 테스트
9. **성능 최적화**: 이미지 압축, 레이지 로딩