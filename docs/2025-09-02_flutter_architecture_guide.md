# Flutter 아키텍처 가이드 - PillSnap

**문서 작성일: 2025-09-02**

## 목차

1. [개요](#개요)
2. [아키텍처 원칙](#아키텍처-원칙)
3. [폴더 구조 상세](#폴더-구조-상세)
4. [레이어별 책임](#레이어별-책임)
5. [구현 패턴](#구현-패턴)
6. [개발 워크플로우](#개발-워크플로우)
7. [코드 예시](#코드-예시)
8. [체크리스트](#체크리스트)

## 개요

PillSnap은 **Feature-first + Layered Architecture**를 채택한 Flutter 애플리케이션입니다. 이 문서는 일관된 코드 구조와 개발 패턴을 유지하기 위한 완전한 가이드입니다.

### 핵심 원칙

- **기능 우선 구조**: 각 기능을 독립적인 모듈로 관리
- **레이어 분리**: Presentation, Domain, Data 계층 엄격 분리
- **의존성 역전**: 상위 레이어가 하위 레이어에 의존하지 않음
- **테스트 가능성**: 모든 비즈니스 로직은 테스트 가능하게 설계

## 아키텍처 원칙

### 1. Clean Architecture 적용

```
┌─────────────────────────────────────────┐
│            Presentation Layer           │
│         (UI, State Management)          │
├─────────────────────────────────────────┤
│              Domain Layer               │
│    (Business Logic, Use Cases)          │
├─────────────────────────────────────────┤
│               Data Layer                │
│    (Repository Impl, Data Sources)      │
└─────────────────────────────────────────┘
```

### 2. 의존성 규칙

- **Presentation** → Domain (UseCase, Entity)
- **Data** → Domain (Repository Interface)
- **Domain** → 독립적 (외부 의존성 없음)

### 3. 데이터 흐름

```
UI → Controller → UseCase → Repository → DataSource → API/DB
                     ↓           ↓            ↓
                  Entity     Domain Model  Data Model
```

## 폴더 구조 상세

```
lib/
├── core/                              # 앱 전역 공통 요소
│   ├── error/
│   │   ├── exceptions.dart          # 커스텀 예외 클래스
│   │   ├── failures.dart           # 실패 타입 정의
│   │   └── error_handler.dart      # 에러 처리 유틸
│   ├── network/
│   │   ├── api_client.dart         # HTTP 클라이언트 설정
│   │   ├── network_info.dart       # 네트워크 상태 체크
│   │   └── api_endpoints.dart      # API 엔드포인트 상수
│   ├── widgets/
│   │   ├── buttons/                # 공통 버튼 컴포넌트
│   │   ├── cards/                  # 공통 카드 컴포넌트
│   │   ├── loading/                # 로딩 인디케이터
│   │   └── dialogs/                # 공통 다이얼로그
│   ├── utils/
│   │   ├── constants.dart          # 앱 상수
│   │   ├── validators.dart         # 입력 검증 함수
│   │   ├── formatters.dart         # 포맷터 유틸
│   │   └── extensions.dart         # Dart 확장 메서드
│   ├── router/
│   │   ├── app_router.dart         # go_router 설정
│   │   ├── route_guards.dart       # 라우트 가드
│   │   └── route_paths.dart        # 라우트 경로 상수
│   └── i18n/
│       └── l10n_extensions.dart    # 국제화 헬퍼
│
├── theme/
│   ├── app_theme.dart              # 테마 설정 (기존)
│   ├── app_colors.dart             # 색상 토큰
│   ├── app_typography.dart         # 타이포그래피 토큰
│   ├── app_spacing.dart            # 간격 토큰
│   └── app_dimensions.dart         # 크기 토큰
│
├── features/
│   ├── auth/                       # 인증 기능
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_email_code.dart
│   │   │       ├── verify_code.dart
│   │   │       ├── set_password.dart
│   │   │       └── sign_in.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── login_controller.dart
│   │       │   ├── signup_controller.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── email_input_page.dart
│   │       │   ├── code_input_page.dart
│   │       │   └── password_input_page.dart
│   │       └── widgets/
│   │           ├── email_form.dart
│   │           ├── code_verification.dart
│   │           └── password_form.dart
│   │
│   ├── onboarding/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── onboarding_content.dart
│   │   │   └── repositories/
│   │   │       └── onboarding_repository.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── onboarding_controller.dart
│   │       ├── pages/
│   │       │   ├── onboarding_first_page.dart
│   │       │   ├── onboarding_second_page.dart
│   │       │   └── onboarding_last_page.dart
│   │       └── widgets/
│   │           ├── onboarding_indicator.dart
│   │           └── onboarding_content_card.dart
│   │
│   ├── camera/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── camera_datasource.dart
│   │   │   └── repositories/
│   │   │       └── camera_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── captured_image.dart
│   │   │   ├── repositories/
│   │   │   │   └── camera_repository.dart
│   │   │   └── usecases/
│   │   │       ├── capture_image.dart
│   │   │       └── analyze_image.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── camera_controller.dart
│   │       ├── pages/
│   │       │   ├── camera_page.dart
│   │       │   ├── camera_info_page.dart
│   │       │   └── camera_result_page.dart
│   │       └── widgets/
│   │           ├── camera_preview.dart
│   │           ├── zoom_controls.dart
│   │           └── crosshair_overlay.dart
│   │
│   ├── drug/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── drug_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── drug_model.dart
│   │   │   └── repositories/
│   │   │       └── drug_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── drug.dart
│   │   │   ├── repositories/
│   │   │   │   └── drug_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_drug_details.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── drug_detail_controller.dart
│   │       ├── pages/
│   │       │   └── drug_detail_page.dart
│   │       └── widgets/
│   │           ├── drug_info_card.dart
│   │           └── drug_warning_section.dart
│   │
│   └── settings/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   └── repositories/
│       │       └── settings_repository.dart
│       └── presentation/
│           ├── controllers/
│           │   └── settings_controller.dart
│           ├── pages/
│           │   └── settings_page.dart
│           └── widgets/
│               └── setting_item.dart
│
├── l10n/
│   ├── app_ko.arb                  # 한국어 리소스
│   └── app_en.arb                  # 영어 리소스
│
└── main.dart                        # 앱 진입점
```

## 레이어별 책임

### Presentation Layer

**책임**: UI 렌더링, 사용자 입력 처리, 상태 관리

#### Controllers (Riverpod Notifiers)

```dart
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<AuthState> build() => const AuthState.initial();

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    final useCase = ref.read(signInUseCaseProvider);
    final result = await useCase(SignInParams(email, password));

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(AuthState.authenticated(user)),
    );
  }
}
```

#### Pages

```dart
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
      ),
      body: state.when(
        data: (authState) => _buildContent(authState),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorWidget(error),
      ),
    );
  }
}
```

### Domain Layer

**책임**: 비즈니스 로직, 유스케이스 정의, 도메인 모델

#### Entities

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    DateTime? createdAt,
  }) = _User;
}
```

#### Use Cases

```dart
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<Failure, User>> call(SignInParams params) async {
    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure('Invalid email'));
    }

    return await _repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
```

#### Repository Interfaces

```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> sendEmailCode(String email);

  Future<Either<Failure, void>> verifyCode({
    required String email,
    required String code,
  });
}
```

### Data Layer

**책임**: 데이터 소스 관리, Repository 구현, 모델 변환

#### Repository Implementation

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = await _remoteDataSource.signIn(email, password);
      await _localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
```

#### Data Models

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Entity 변환
  User toEntity() => User(
    id: id,
    email: email,
    name: name,
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
  );
}
```

#### Data Sources

```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<void> sendEmailCode(String email);
  Future<void> verifyCode(String email, String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.signIn,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }

    return UserModel.fromJson(response.data);
  }
}
```

## 구현 패턴

### 1. 에러 처리 패턴

```dart
// Either 패턴 사용
typedef Result<T> = Either<Failure, T>;

// Failure 타입 정의
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error']) : super(message);
}

// 사용 예시
Future<Result<User>> getUser() async {
  try {
    final user = await _api.getUser();
    return Right(user);
  } on ServerException {
    return const Left(ServerFailure());
  } on NetworkException {
    return const Left(NetworkFailure());
  }
}
```

### 2. 의존성 주입 패턴

```dart
// Provider 정의
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient(baseUrl: ApiEndpoints.baseUrl);
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
SignInUseCase signInUseCase(SignInUseCaseRef ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
}
```

### 3. 상태 관리 패턴

```dart
// State 정의
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Notifier 구현
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final userOption = await ref.read(getCurrentUserUseCaseProvider)();

    state = userOption.fold(
      () => const AuthState.unauthenticated(),
      (user) => AuthState.authenticated(user),
    );
  }
}
```

### 4. 라우팅 패턴

```dart
// go_router 설정
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState is Authenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/camera',
            name: 'camera',
            builder: (context, state) => const CameraPage(),
          ),
        ],
      ),
    ],
  );
}
```

## 개발 워크플로우

### 1. 새 기능 추가 프로세스

1. **Domain Layer 정의**

   - Entity 생성
   - Repository Interface 정의
   - UseCase 구현

2. **Data Layer 구현**

   - Model 생성 (with freezed)
   - DataSource 구현
   - Repository 구현

3. **Presentation Layer 구성**

   - State/Controller 생성
   - Page/Widget 구현
   - Provider 연결

4. **테스트 작성**
   - Unit Test (UseCase, Repository)
   - Widget Test
   - Integration Test

### 2. 코드 생성 명령어

```bash
# Freezed & JsonSerializable 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 국제화 파일 생성
flutter gen-l10n

# Riverpod 코드 생성
flutter pub run build_runner watch
```

### 3. 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 실행
flutter test test/unit/auth_test.dart

# 커버리지 리포트
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 코드 예시

### 완전한 기능 구현 예시: 이메일 인증

#### 1. Domain - Entity

```dart
// lib/features/auth/domain/entities/email_verification.dart
@freezed
class EmailVerification with _$EmailVerification {
  const factory EmailVerification({
    required String email,
    required String code,
    required DateTime expiresAt,
  }) = _EmailVerification;
}
```

#### 2. Domain - Repository Interface

```dart
// lib/features/auth/domain/repositories/email_verification_repository.dart
abstract class EmailVerificationRepository {
  Future<Result<void>> sendCode(String email);
  Future<Result<EmailVerification>> verifyCode(String email, String code);
}
```

#### 3. Domain - UseCase

```dart
// lib/features/auth/domain/usecases/send_verification_code.dart
class SendVerificationCodeUseCase {
  final EmailVerificationRepository _repository;

  SendVerificationCodeUseCase(this._repository);

  Future<Result<void>> call(String email) async {
    if (!EmailValidator.validate(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await _repository.sendCode(email);
  }
}
```

#### 4. Data - Model

```dart
// lib/features/auth/data/models/email_verification_model.dart
@freezed
class EmailVerificationModel with _$EmailVerificationModel {
  const factory EmailVerificationModel({
    required String email,
    required String code,
    required String expiresAt,
  }) = _EmailVerificationModel;

  factory EmailVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationModelFromJson(json);

  EmailVerification toEntity() => EmailVerification(
    email: email,
    code: code,
    expiresAt: DateTime.parse(expiresAt),
  );
}
```

#### 5. Data - Repository Implementation

```dart
// lib/features/auth/data/repositories/email_verification_repository_impl.dart
class EmailVerificationRepositoryImpl implements EmailVerificationRepository {
  final EmailVerificationRemoteDataSource _remoteDataSource;

  EmailVerificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> sendCode(String email) async {
    try {
      await _remoteDataSource.sendCode(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<EmailVerification>> verifyCode(String email, String code) async {
    try {
      final model = await _remoteDataSource.verifyCode(email, code);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

#### 6. Presentation - Controller

```dart
// lib/features/auth/presentation/controllers/email_verification_controller.dart
@riverpod
class EmailVerificationController extends _$EmailVerificationController {
  @override
  FutureOr<void> build() {}

  Future<void> sendCode(String email) async {
    state = const AsyncLoading();

    final useCase = ref.read(sendVerificationCodeUseCaseProvider);
    final result = await useCase(email);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> verifyCode(String email, String code) async {
    state = const AsyncLoading();

    final useCase = ref.read(verifyCodeUseCaseProvider);
    final result = await useCase(email, code);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) {
        ref.read(routerProvider).go('/auth/set-password');
        return const AsyncData(null);
      },
    );
  }
}
```

#### 7. Presentation - Page

```dart
// lib/features/auth/presentation/pages/email_verification_page.dart
class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(emailVerificationControllerProvider);

    ref.listen(
      emailVerificationControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emailVerification),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              EmailInputWidget(
                onSubmit: (email) {
                  ref.read(emailVerificationControllerProvider.notifier)
                      .sendCode(email);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CodeInputWidget(
                onSubmit: (code) {
                  ref.read(emailVerificationControllerProvider.notifier)
                      .verifyCode(email, code);
                },
              ),
              if (state.isLoading) const LoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 체크리스트

### 새 기능 개발 체크리스트

- [ ] **Domain Layer**

  - [ ] Entity 정의 (freezed 사용)
  - [ ] Repository Interface 작성
  - [ ] UseCase 구현
  - [ ] 비즈니스 로직 검증

- [ ] **Data Layer**

  - [ ] Model 생성 (fromJson/toJson)
  - [ ] DataSource 구현
  - [ ] Repository 구현
  - [ ] 에러 처리 로직

- [ ] **Presentation Layer**

  - [ ] State 정의
  - [ ] Controller/Notifier 구현
  - [ ] Page 구성
  - [ ] Widget 분리
  - [ ] 국제화 적용

- [ ] **테스트**

  - [ ] Unit Test (UseCase)
  - [ ] Unit Test (Repository)
  - [ ] Widget Test
  - [ ] Integration Test

- [ ] **코드 품질**
  - [ ] flutter analyze 통과
  - [ ] flutter format 적용
  - [ ] 불필요한 import 제거
  - [ ] 주석 추가 (필요시)

### 코드 리뷰 체크리스트

- [ ] **아키텍처 준수**

  - [ ] 레이어 분리 준수
  - [ ] 의존성 방향 확인
  - [ ] 폴더 구조 일관성

- [ ] **코드 스타일**

  - [ ] Effective Dart 준수
  - [ ] 네이밍 컨벤션
  - [ ] 파일/클래스 크기

- [ ] **상태 관리**

  - [ ] Riverpod 패턴 준수
  - [ ] 불필요한 rebuild 방지
  - [ ] 메모리 누수 체크

- [ ] **UI/UX**

  - [ ] 테마 토큰 사용
  - [ ] 반응형 디자인
  - [ ] 접근성 고려
  - [ ] 에러 처리 UI

- [ ] **성능**
  - [ ] const 생성자 사용
  - [ ] 불필요한 위젯 rebuild 방지
  - [ ] 이미지 최적화

## 참고 자료

### 공식 문서

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)

### 아키텍처 참고

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture)
- [Effective Dart](https://dart.dev/effective-dart)

### 테스트 가이드

- [Flutter Testing](https://flutter.dev/docs/testing)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

---

**문서 버전**: 1.0.0  
**최종 수정일**: 2025-09-02  
**작성자**: Claude AI Assistant  
**프로젝트**: PillSnap

이 문서는 PillSnap 프로젝트의 핵심 아키텍처 가이드입니다. 모든 개발자는 이 가이드를 숙지하고 준수해야 합니다.
