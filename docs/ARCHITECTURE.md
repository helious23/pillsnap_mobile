# PillSnap 아키텍처 문서

> 작성일: 2025-09-03  
> 버전: 1.0.0  
> 프로젝트: PillSnap

## 📐 아키텍처 개요

PillSnap은 **Feature-first + Clean Architecture** 패턴을 따르며, 각 기능을 독립적인 모듈로 구성합니다.

```
┌─────────────────────────────────────────────────────┐
│                   Presentation Layer                 │
│         (Pages, Widgets, Controllers/Providers)      │
├─────────────────────────────────────────────────────┤
│                     Domain Layer                     │
│           (Entities, Repositories, UseCases)         │
├─────────────────────────────────────────────────────┤
│                      Data Layer                      │
│        (DataSources, Models, RepositoryImpl)         │
└─────────────────────────────────────────────────────┘
```

## 🏗️ 프로젝트 구조

```
lib/
├── core/                          # 앱 전역 공통
│   ├── error/                     # 에러 처리
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                   # 네트워크 설정
│   │   └── api_client.dart
│   ├── router/                    # 라우팅
│   │   ├── app_router.dart       # go_router 설정
│   │   └── route_paths.dart      # 라우트 경로 상수
│   ├── utils/                     # 유틸리티
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── structured_logger.dart # 구조화된 로깅
│   └── widgets/                   # 공통 위젯
│       └── loading_widget.dart
│
├── features/                      # Feature 모듈
│   ├── auth/                     # 인증 기능
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── signup_page.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   │
│   ├── camera/                    # 카메라 기능
│   ├── home/                      # 홈 화면
│   └── onboarding/                # 온보딩
│
├── theme/                         # 디자인 시스템
│   ├── app_colors.dart           # 색상 토큰
│   ├── app_typography.dart       # 타이포그래피
│   ├── app_spacing.dart          # 간격 시스템
│   ├── app_dimensions.dart       # 크기, 반경
│   └── app_theme.dart            # Material 테마
│
└── main.dart                      # 앱 진입점
```

## 🔄 데이터 플로우

```
User Input → UI (Widget) → Controller/Provider → UseCase → Repository → DataSource → API/DB
                ↑                                                                           ↓
                └───────────────────────── Response ←──────────────────────────────────────┘
```

## 📦 상태 관리 (Riverpod)

### Provider 종류별 사용 가이드

```dart
// 1. StateProvider - 간단한 상태
final counterProvider = StateProvider<int>((ref) => 0);

// 2. FutureProvider - 비동기 데이터 읽기
final userProvider = FutureProvider<User>((ref) async {
  return await ref.read(authRepositoryProvider).getUser();
});

// 3. StreamProvider - 실시간 데이터
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return ref.read(chatRepositoryProvider).watchMessages();
});

// 4. NotifierProvider - 복잡한 상태 관리
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();
  
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    // ... 로직
  }
}

// 5. AsyncNotifierProvider - 비동기 상태 관리
class CameraNotifier extends AsyncNotifier<CameraState> {
  @override
  Future<CameraState> build() async {
    // 초기화 로직
    return CameraState();
  }
}
```

### Provider 네이밍 컨벤션

- **Provider**: `xxxProvider`
- **Notifier**: `XxxNotifier`
- **State**: `XxxState`
- **Controller**: `xxxControllerProvider`

## 🛣️ 라우팅 (go_router)

### 라우트 구조

```dart
GoRouter(
  routes: [
    // 일반 라우트
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    
    // ShellRoute - 공통 레이아웃
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
      ],
    ),
    
    // 중첩 라우트
    GoRoute(
      path: '/camera',
      builder: (context, state) => CameraPage(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) => ResultPage(),
        ),
      ],
    ),
  ],
);
```

### 네비게이션 패턴

```dart
// 이동
context.go('/home');
context.push('/camera');

// 파라미터
context.push('/drug/${drugId}');

// 쿼리 파라미터
context.push('/camera?mode=multi');

// 뒤로가기
context.pop();
```

## 🎨 디자인 시스템

### 색상 토큰

```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF1A73E8);
  
  // Text
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  
  // Background
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFF1F5F9);
}
```

### 타이포그래피

```dart
class AppTextStyles {
  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
}
```

### 간격 시스템

```dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}
```

## 🔌 의존성 주입

### Repository Pattern

```dart
// Domain Layer (Interface)
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}

// Data Layer (Implementation)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  );
});
```

## 🧪 테스트 전략

### 테스트 구조

```
test/
├── unit/              # 단위 테스트
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       └── login_test.dart
│   │   │   └── data/
│   │   │       └── repositories/
│   │   │           └── auth_repository_test.dart
│   └── core/
│       └── utils/
│           └── validators_test.dart
│
├── widget/            # 위젯 테스트
│   └── features/
│       └── auth/
│           └── pages/
│               └── login_page_test.dart
│
└── integration/       # 통합 테스트
    └── app_test.dart
```

### 테스트 패턴

```dart
// 단위 테스트
test('should return user when login is successful', () async {
  // Arrange
  when(mockRepository.login(any, any))
      .thenAnswer((_) async => Right(tUser));
  
  // Act
  final result = await usecase(LoginParams(email, password));
  
  // Assert
  expect(result, Right(tUser));
});

// 위젯 테스트
testWidgets('should display login form', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: LoginPage()),
    ),
  );
  
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

## 🚀 성능 최적화

### 1. 레이지 로딩

```dart
// FutureProvider with family
final drugDetailProvider = FutureProvider.family<Drug, String>((ref, id) async {
  return ref.read(drugRepositoryProvider).getDrug(id);
});
```

### 2. 캐싱 전략

```dart
// keepAlive 사용
final cachedDataProvider = FutureProvider<Data>((ref) async {
  ref.keepAlive();  // 데이터 유지
  return fetchData();
});
```

### 3. 이미지 최적화

```dart
// 캐시 네트워크 이미지
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

## 🔒 보안 고려사항

1. **API 키 관리**: 환경 변수 사용
2. **토큰 저장**: secure_storage 사용
3. **입력 검증**: 모든 사용자 입력 검증
4. **HTTPS**: 모든 네트워크 통신 암호화

## 📚 코딩 컨벤션

### 파일 네이밍
- **파일/폴더**: `lowercase_with_underscores.dart`
- **클래스**: `UpperCamelCase`
- **변수/함수**: `lowerCamelCase`
- **상수**: `SCREAMING_SNAKE_CASE` 또는 `lowerCamelCase`

### 코드 스타일
- **들여쓰기**: 2 spaces
- **라인 길이**: 80자 권장, 120자 최대
- **import 순서**: dart → package → project

## 🔄 CI/CD 파이프라인

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

## 📈 모니터링 및 분석

- **Crashlytics**: 크래시 리포팅
- **Analytics**: 사용자 행동 분석
- **Performance**: 성능 모니터링
- **Sentry**: 에러 트래킹

## 🖼️ 이미지 전처리 아키텍처

### 전처리 파이프라인 책임 분리

```
┌─────────────────────────────────────────────────────┐
│                    Frontend (Flutter)                 │
│  - 이미지 표준화: 2048px 긴 변, JPEG Q95            │
│  - EXIF 픽셀 반영 (bakeOrientation)                  │
│  - 메타데이터 제거                                    │
│  - 구조화 로깅 (trace_id)                            │
└────────────────────────┬────────────────────────────┘
                         │
                    표준화된 이미지
                         │
┌────────────────────────▼────────────────────────────┐
│                      BFF Server                       │
│  - 매직넘버 검증                                      │
│  - 재인코딩 여부 판단                                 │
│  - trace_id 전파                                      │
└────────────────────────┬────────────────────────────┘
                         │
                    검증된 이미지
                         │
┌────────────────────────▼────────────────────────────┐
│                   Inference Server                    │
│  - 분류: center-crop 768×768                         │
│  - 감지: letterbox 1024×1024                         │
│  - 모델별 정규화                                      │
└─────────────────────────────────────────────────────┘
```

### 이미지 처리 클래스

```dart
// 업로드 규격 상수
class UploadImageSpec {
  static const int targetLongEdge = 2048;
  static const int jpegQuality = 95;
}

// 처리 결과 메타데이터
class ProcessedImageResult {
  final String path;
  final int width, height, fileSize;
  final String hash, traceId;
  final bool wasResized, exifFixed;
  final double scaleFactor;
}

// 처리 실패 예외
class ProcessingException implements Exception {
  final String message;
  final String? originalPath;
  final Map<String, dynamic>? metadata;
}
```

### 구조화된 로깅

```dart
// 추적 가능한 로그 생성
StructuredLogger.logImageProcessing(
  traceId: traceId,
  phase: 'resize',
  originalWidth: 4032,
  processedWidth: 2048,
  decision: 'larger_than_desired',
);

// 출력 예시 (JSON)
{
  "timestamp": "2025-09-06T10:00:00Z",
  "level": "info",
  "stage": "image_processing",
  "traceId": "uuid-v4",
  "data": {
    "phase": "resize",
    "wasResized": true,
    "scaleFactor": "0.51"
  }
}
```

자세한 내용은 [IMAGE_PREPROCESSING_PIPELINE.md](./IMAGE_PREPROCESSING_PIPELINE.md) 참조

---

*이 문서는 지속적으로 업데이트됩니다.*
*최종 수정: 2025-09-07*