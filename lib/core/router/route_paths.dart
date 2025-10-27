/// 라우트 경로 상수 정의
class RoutePaths {
  // 인증 관련
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String emailInput = '/auth/email';
  static const String profileSetup = '/auth/profile';
  static const String codeVerification = '/auth/code';
  static const String passwordSetup = '/auth/password';
  static const String emailConfirmation = '/auth/confirm';
  
  // 온보딩
  static const String onboarding = '/onboarding';
  
  // 메인 앱
  static const String home = '/home';
  static const String camera = '/camera';
  static const String cameraResult = '/camera/result';
  static const String cameraLoading = '/camera/loading';
  
  // 약품 정보
  static const String drugDetail = '/drug/:id';
  static const String drugDetailById = '/drug/';
  static const String drugIdentification = '/drug/identification';
  
  // 설정
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String captureHistory = '/settings/history';
  static const String appInfo = '/settings/info';
  static const String notifications = '/settings/notifications';
  
  // 라우트 이름 (go_router name 파라미터용)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String emailInputName = 'emailInput';
  static const String profileSetupName = 'profileSetup';
  static const String codeVerificationName = 'codeVerification';
  static const String passwordSetupName = 'passwordSetup';
  static const String emailConfirmationName = 'emailConfirmation';
  static const String onboardingName = 'onboarding';
  static const String homeName = 'home';
  static const String cameraName = 'camera';
  static const String cameraResultName = 'cameraResult';
  static const String cameraLoadingName = 'cameraLoading';
  static const String drugDetailName = 'drugDetail';
  static const String settingsName = 'settings';
  static const String profileName = 'profile';
  static const String notificationsName = 'notifications';
}