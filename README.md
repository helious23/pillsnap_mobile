# PillSnap

카메라 이미징을 통해 의약품을 식별하는 Flutter 기반 모바일 애플리케이션입니다.

## 프로젝트 개요

PillSnap은 사용자가 약물 이미지를 캡처하고 분석하여 의약품 정보를 확인할 수 있는 모바일 앱입니다. 단일 및 다중 알약 식별을 모두 지원하며, 사용자 친화적인 인터페이스를 제공합니다.

## 주요 기능

- 📸 **카메라 촬영**: 단일/다중 모드 지원, 줌 컨트롤, 탭 포커스
- 🔍 **약품 식별**: AI 기반 알약 인식 및 정보 제공
- 📚 **약품 정보**: 성분, 효능·효과, 용법·용량, 주의사항 제공
- 🔐 **사용자 인증**: 이메일 기반 회원가입/로그인
- 🌐 **다국어 지원**: 한국어 기본 (추가 언어 예정)

## 기술 스택

### 프레임워크 & 언어
- Flutter 3.8.1+
- Dart

### 상태관리 & 아키텍처
- **Riverpod** - 상태관리
- **Clean Architecture** - Feature-first + Layered Architecture
- **go_router** - 라우팅

### 주요 패키지
- `camera` - 카메라 기능
- `image` - 이미지 전처리
- `supabase_flutter` - 백엔드 서비스
- `freezed` - 불변 모델 생성
- `json_serializable` - JSON 직렬화

## 이미지 전처리 파이프라인

### 프론트엔드 책임사항
- **표준화**: 2048px 긴 변, JPEG Q95
- **EXIF 처리**: 픽셀에 회전 반영 (bakeOrientation)
- **메타데이터**: 제거
- **구조화 로깅**: 추적 ID 기반 디버깅

### 처리 흐름
```
원본 이미지 (4032×3024)
    ↓ EXIF 처리
    ↓ 비율 유지 다운스케일
    ↓ JPEG 재인코딩 (Q95)
최종 이미지 (2048×1536)
```

자세한 내용은 [IMAGE_PREPROCESSING_PIPELINE.md](docs/IMAGE_PREPROCESSING_PIPELINE.md) 참조

## 프로젝트 구조

```
lib/
├── core/                   # 앱 전역 공통
│   ├── error/             # 에러 처리
│   ├── network/           # 네트워크 설정
│   ├── widgets/           # 공통 위젯
│   ├── utils/             # 유틸리티 (StructuredLogger 등)
│   └── router/            # go_router 설정
├── theme/                  # 테마 시스템
├── features/              # 기능별 모듈
│   ├── auth/             # 인증
│   ├── onboarding/       # 온보딩
│   ├── camera/           # 카메라
│   ├── drug/             # 약품 정보
│   └── settings/         # 설정
└── l10n/                  # 국제화
```

## 시작하기

### 사전 요구사항
- Flutter SDK 3.8.1+
- Dart SDK (Flutter에 포함)
- Android Studio 또는 Xcode (플랫폼별)

### 설치

1. 저장소 클론
```bash
git clone https://github.com/yourusername/pillsnap.git
cd pillsnap
```

2. 의존성 설치
```bash
flutter pub get
```

3. 코드 생성
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. 앱 실행
```bash
flutter run
```

## 개발 명령어

### 빌드 & 실행
```bash
flutter run                 # 기본 디바이스 실행
flutter run -d ios          # iOS 시뮬레이터
flutter run -d android      # Android 에뮬레이터
flutter build apk           # Android APK 빌드
flutter build ios           # iOS 빌드
```

### 코드 생성
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch # 자동 재생성
```

### 테스트 & 품질
```bash
flutter test                # 테스트 실행
flutter analyze             # 정적 분석
flutter format .            # 코드 포맷팅
```

### 국제화
```bash
flutter gen-l10n            # 번역 파일 생성
```

## 환경 설정

### API 엔드포인트
- 개발: `https://api-dev.pillsnap.co.kr`
- 운영: `https://api.pillsnap.co.kr`

### 환경 변수
`.env` 파일 생성:
```
API_BASE_URL=https://api.pillsnap.co.kr
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## 테스트

### 단위 테스트
```bash
flutter test test/unit/
```

### 위젯 테스트
```bash
flutter test test/widget/
```

### 통합 테스트
```bash
flutter test test/integration/
```

## 문서

- [아키텍처 가이드](docs/ARCHITECTURE.md)
- [API 연동 가이드](docs/API_INTEGRATION.md)
- [이미지 전처리 파이프라인](docs/IMAGE_PREPROCESSING_PIPELINE.md)
- [이미지 최적화 가이드](docs/IMAGE_OPTIMIZATION_GUIDE.md)

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 문의

프로젝트 관련 문의사항이 있으시면 이슈를 생성해주세요.