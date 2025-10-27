/// Supabase 앱 설정
/// --dart-define으로 환경변수 주입 또는 기본값 사용
class AppConfig {
  // Supabase 설정 (--dart-define으로 주입, 없으면 기본값)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // .env 파일 또는 --dart-define으로 주입 필요
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // .env 파일 또는 --dart-define으로 주입 필요
  );
  
  // 딥링크 설정
  static const String appScheme = 'pillsnap';
  static const String authCallbackPath = 'auth-callback';
  static const String authCallbackUrl = '$appScheme://$authCallbackPath';
  
  // 개발/프로덕션 환경 플래그
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: true,
  );
}