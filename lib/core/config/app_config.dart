import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase 앱 설정
/// .env 파일에서 환경변수 로드
class AppConfig {
  // Supabase 설정 (.env 파일에서 로드)
  static String get supabaseUrl => dotenv.env['SUPABASE_PROJECT_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiUrl => dotenv.env['API_URL'] ?? 'https://api.pillsnap.co.kr';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // 딥링크 설정
  static const String appScheme = 'pillsnap';
  static const String authCallbackPath = 'auth-callback';
  static const String authCallbackUrl = '$appScheme://$authCallbackPath';

  // 개발/프로덕션 환경 플래그
  static bool get isDebug => dotenv.env['DEBUG']?.toLowerCase() == 'true';
}