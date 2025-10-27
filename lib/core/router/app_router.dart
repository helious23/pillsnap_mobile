import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/features/auth/presentation/providers/auth_provider.dart';
import 'package:pillsnap/features/onboarding/presentation/controllers/onboarding_controller.dart';

// Feature 페이지 import
import 'package:pillsnap/features/auth/presentation/pages/login_page.dart';
import 'package:pillsnap/features/auth/presentation/pages/email_input_page.dart';
import 'package:pillsnap/features/auth/presentation/pages/code_verification_page.dart';
import 'package:pillsnap/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:pillsnap/features/auth/presentation/pages/password_setup_page.dart';
import 'package:pillsnap/features/auth/presentation/pages/email_confirmation_page.dart';
import 'package:pillsnap/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pillsnap/features/home/presentation/pages/home_page.dart';
import 'package:pillsnap/features/camera/presentation/pages/camera_page.dart';
import 'package:pillsnap/features/camera/presentation/pages/camera_loading_page.dart';
import 'package:pillsnap/features/camera/presentation/pages/photo_confirm_page.dart';
import 'package:pillsnap/features/drug/presentation/pages/camera_result_page.dart';
import 'package:pillsnap/features/drug/presentation/pages/drug_detail_page.dart';
import 'package:pillsnap/features/drug/presentation/pages/drug_identification_flow_page.dart';
import 'package:pillsnap/features/settings/presentation/pages/settings_page.dart';
import 'package:pillsnap/features/settings/presentation/pages/profile_page.dart';
import 'package:pillsnap/features/settings/presentation/pages/capture_history_page.dart';
import 'package:pillsnap/features/settings/presentation/pages/app_info_page.dart';
import 'package:pillsnap/components/bottom_nav/curved_nav.dart';

/// go_router 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  // 인증 상태 감지
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final profileCompleted = ref.watch(profileCompletedProvider);
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);
  
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    
    redirect: (context, state) {
      debugPrint('🧭 [ROUTER] redirect 체크 - 현재: ${state.matchedLocation}');
      
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboarding = state.matchedLocation == RoutePaths.onboarding;
      final isSplash = state.matchedLocation == RoutePaths.splash;
      final isProfileSetup = state.matchedLocation == RoutePaths.profileSetup;
      final isHome = state.matchedLocation == RoutePaths.home;
      
      // splash에서 시작
      if (isSplash) {
        // 인증되었으면 프로필 → 온보딩 체크, 아니면 로그인으로
        if (isAuthenticated) {
          debugPrint('🧭 [ROUTER] Splash - 인증됨');
          
          // 1. 프로필 완료 체크
          final profileStatus = profileCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          
          debugPrint('🧭 [ROUTER] 프로필 상태: $profileStatus');
          
          if (profileStatus == null) {
            debugPrint('🧭 [ROUTER] 프로필 로딩 중 - 대기');
            return null; // 로딩 중이면 대기
          }
          if (!profileStatus) {
            debugPrint('🧭 [ROUTER] 결정: 프로필 미완료 -> profile');
            return RoutePaths.profileSetup;
          }
          
          // 2. 온보딩 완료 체크  
          final onboardingStatus = onboardingCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          
          debugPrint('🧭 [ROUTER] 온보딩 상태: $onboardingStatus');
          
          if (onboardingStatus == null) {
            debugPrint('🧭 [ROUTER] 온보딩 로딩 중 - 대기');
            return null; // 로딩 중이면 대기
          }
          if (!onboardingStatus) {
            debugPrint('🧭 [ROUTER] 결정: 온보딩 미완료 -> onboarding');
            return RoutePaths.onboarding;
          }
          
          debugPrint('🧭 [ROUTER] 결정: 프로필&온보딩 완료 -> home');
          return RoutePaths.home;
        }
        debugPrint('🧭 [ROUTER] 결정: 미인증 -> login');
        return RoutePaths.login;
      }
      
      // 인증되지 않은 상태
      if (!isAuthenticated) {
        debugPrint('🧭 [ROUTER] 미인증 상태 - isAuthRoute: $isAuthRoute, isOnboarding: $isOnboarding');
        // 인증 관련 페이지나 온보딩은 허용
        if (!isAuthRoute && !isOnboarding) {
          debugPrint('🧭 [ROUTER] 결정: 미인증 & 인증페이지 아님 -> login');
          return RoutePaths.login;
        }
      } else {
        // 인증된 상태
        debugPrint('🧭 [ROUTER] 인증된 상태');
        if (isAuthRoute && !isProfileSetup) {
          // 프로필 설정 페이지가 아닌 인증 페이지 접근 시
          // 프로필 → 온보딩 순서로 체크
          final profileStatus = profileCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          debugPrint('🧭 [ROUTER] 인증페이지 접근 - 프로필상태: $profileStatus');
          
          if (profileStatus == false) {
            debugPrint('🧭 [ROUTER] 결정: 프로필 미완료 -> profile');
            return RoutePaths.profileSetup;
          }
          
          final onboardingStatus = onboardingCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          debugPrint('🧭 [ROUTER] 인증페이지 접근 - 온보딩상태: $onboardingStatus');
          
          if (onboardingStatus == false) {
            debugPrint('🧭 [ROUTER] 결정: 온보딩 미완료 -> onboarding');
            return RoutePaths.onboarding;
          }
          
          debugPrint('🧭 [ROUTER] 결정: 프로필&온보딩 완료 -> home');
          return RoutePaths.home;
        }
        
        // 온보딩 페이지에서는 추가 리다이렉트 없음
        if (isOnboarding) {
          return null; // 온보딩 페이지 유지
        }
        
        // 홈 화면에 접근할 때 프로필/온보딩 체크
        if (isHome) {
          // 1. 프로필 체크
          final profileStatus = profileCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          
          debugPrint('🧭 [ROUTER] 홈 접근 - 프로필 상태: $profileStatus');
          
          // 프로필이 완료되지 않았으면 프로필로
          if (profileStatus == false) {
            debugPrint('🧭 [ROUTER] 결정: 프로필 미완료 -> profile');
            return RoutePaths.profileSetup;
          }
          
          // 2. 온보딩 체크
          final onboardingStatus = onboardingCompleted.when(
            data: (value) => value,
            loading: () => null,
            error: (_, __) => false,
          );
          
          debugPrint('🧭 [ROUTER] 홈 접근 - 온보딩 상태: $onboardingStatus');
          
          // 온보딩이 완료되지 않았으면 온보딩으로
          if (onboardingStatus == false) {
            debugPrint('🧭 [ROUTER] 결정: 온보딩 미완료 -> onboarding');
            return RoutePaths.onboarding;
          }
          
          debugPrint('🧭 [ROUTER] 결정: 프로필&온보딩 완료 -> 홈 유지');
          // 모두 완료 시 홈 유지
          return null;
        }
      }
      
      return null;
    },
    
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // 인증 라우트
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        pageBuilder: (context, state) {
          // 로그아웃에서 오는 경우 왼쪽에서 슬라이드
          final isFromLogout = state.uri.queryParameters['from'] == 'logout';
          
          if (isFromLogout) {
            return CustomTransitionPage(
              child: LoginPage(extra: state.extra as Map<String, dynamic>?),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0); // 왼쪽에서 시작
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          }
          
          // 일반적인 경우는 기본 트랜지션
          return MaterialPage(child: LoginPage(extra: state.extra as Map<String, dynamic>?));
        },
      ),
      GoRoute(
        path: RoutePaths.emailInput,
        name: 'emailInput',
        builder: (context, state) => const EmailInputPage(),
      ),
      GoRoute(
        path: RoutePaths.codeVerification,
        name: 'codeVerification',
        builder: (context, state) => const CodeVerificationPage(),
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: RoutePaths.passwordSetup,
        name: 'passwordSetup',
        builder: (context, state) => const PasswordSetupPage(),
      ),
      GoRoute(
        path: RoutePaths.emailConfirmation,
        name: 'emailConfirmation',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return EmailConfirmationPage(
            email: (extras?['email'] ?? '') as String,
            password: (extras?['password'] ?? '') as String,
            isResend: (extras?['isResend'] ?? false) as bool,
            rateLimitSeconds: extras?['rateLimitSeconds'] as int?,
          );
        },
      ),
      
      // 온보딩
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // 메인 앱 - ShellRoute로 하단 네비게이션 구현
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: 'home',
            pageBuilder: (context, state) {
              // 이전 위치 확인
              final previousLocation = state.extra as String?;
              final isFromSettings = previousLocation == 'settings';
              final isFromCamera = previousLocation == 'camera';
              
              if (isFromSettings || isFromCamera) {
                // 설정이나 카메라에서 홈으로 올 때 왼쪽에서 슬라이드
                return CustomTransitionPage(
                  child: const HomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              }
              
              // 기본 트랜지션
              return const MaterialPage(child: HomePage());
            },
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'history',
                name: 'captureHistory',
                builder: (context, state) => const CaptureHistoryPage(),
              ),
              GoRoute(
                path: 'info',
                name: 'appInfo',
                builder: (context, state) => const AppInfoPage(),
              ),
            ],
          ),
        ],
      ),
      
      // 카메라는 ShellRoute 밖에 위치 (전체화면)
      GoRoute(
        path: RoutePaths.camera,
        name: 'camera',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          return CustomTransitionPage(
            child: CameraPage(
              isMultiMode: mode == 'multi',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          );
        },
        routes: [
          GoRoute(
            path: 'guide',
            name: 'cameraGuide',
            builder: (context, state) => const PlaceholderPage(title: 'Camera Guide'),
          ),
          GoRoute(
            path: 'confirm',
            name: 'photoConfirm',
            pageBuilder: (context, state) {
              final path = state.uri.queryParameters['path'] ?? '';
              final roi = state.uri.queryParameters['roi'];  // ROI 경로 추출
              final mode = state.uri.queryParameters['mode'];
              final isMultiMode = mode == 'multi';
              return CustomTransitionPage(
                child: PhotoConfirmPage(
                  imagePath: path,
                  roiPath: roi,  // ROI 경로 전달
                  isMultiMode: isMultiMode,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              );
            },
          ),
          GoRoute(
            path: 'loading',
            name: 'cameraLoading',
            pageBuilder: (context, state) {
              final path = state.uri.queryParameters['path'];
              final roi = state.uri.queryParameters['roi'];  // ROI 경로 추출
              final mode = state.uri.queryParameters['mode'];
              final isMultiMode = mode == 'multi';
              return CustomTransitionPage(
                child: CameraLoadingPage(
                  imagePath: path,
                  roiPath: roi,  // ROI 경로 전달
                  isMultiMode: isMultiMode,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              );
            },
          ),
          GoRoute(
            path: 'result',
            name: 'cameraResult',
            builder: (context, state) => const CameraResultPage(),
          ),
        ],
      ),
      
      // 약품 식별 플로우 (정적 경로를 동적 경로보다 먼저 배치)
      GoRoute(
        path: RoutePaths.drugIdentification,
        name: 'drugIdentification',
        builder: (context, state) {
          debugPrint('🟢 [ROUTER] DrugIdentificationFlowPage 생성');
          return const DrugIdentificationFlowPage();
        },
      ),
      
      // 약물 상세 (동적 경로는 나중에 배치)
      GoRoute(
        path: RoutePaths.drugDetail,
        name: 'drugDetail',
        builder: (context, state) {
          final drugId = state.pathParameters['id'] ?? '';
          debugPrint('🟡 [ROUTER] DrugDetailPage 생성 - id: $drugId');
          return DrugDetailPage(drugId: drugId);
        },
      ),
    ],
    
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

/// 임시 플레이스홀더 페이지
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({
    super.key,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('This page is under construction'),
          ],
        ),
      ),
    );
  }
}

/// 스플래시 페이지
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// 에러 페이지
class ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const ErrorPage({
    super.key,
    this.error,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 메인 셸 (하단 네비게이션 포함)
class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({
    super.key,
    required this.child,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentIndex = _calculateSelectedIndex(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 메인 콘텐츠
          widget.child,
          // 하단에 플로팅 네비게이션
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedNav(
              currentIndex: _currentIndex,
              onTap: (index) => _onItemTapped(index, context),
            ),
          ),
        ],
      ),
    );
  }
  
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.home)) return 0;
    if (location.startsWith(RoutePaths.camera)) return 1;
    if (location.startsWith(RoutePaths.settings)) return 2;
    return 0;
  }
  
  void _onItemTapped(int index, BuildContext context) {
    final previousIndex = _currentIndex;
    
    switch (index) {
      case 0:
        setState(() {
          _currentIndex = 0;
        });
        // 설정(index 2)에서 홈으로 가는 경우
        if (previousIndex == 2) {
          context.go(RoutePaths.home, extra: 'settings');
        } else {
          context.go(RoutePaths.home);
        }
        break;
      case 1:
        // 카메라 버튼 클릭 시 약품 식별 플로우로 이동
        debugPrint('🔵 [BOTTOM_NAV] 카메라 버튼 클릭');
        debugPrint('🔵 [BOTTOM_NAV] 이동할 경로: ${RoutePaths.drugIdentification}');
        context.push(RoutePaths.drugIdentification);
        debugPrint('🔵 [BOTTOM_NAV] 약품 식별 플로우로 push 완료');
        break;
      case 2:
        setState(() {
          _currentIndex = 2;
        });
        context.go(RoutePaths.settings);
        break;
    }
  }
}