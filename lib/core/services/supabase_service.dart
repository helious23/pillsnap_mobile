import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase 서비스 싱글톤
class SupabaseService {
  SupabaseService._();
  
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  // Supabase 클라이언트 접근
  SupabaseClient get client => Supabase.instance.client;
  
  // 인증 상태 스트림
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // 현재 사용자
  User? get currentUser => client.auth.currentUser;
  
  // 현재 세션
  Session? get currentSession => client.auth.currentSession;
  
  /// Supabase 초기화
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );
  }
  
  /// 딥링크 처리
  Future<bool> handleDeepLink(Uri uri) async {
    try {
      // auth-callback 경로인지 확인
      if (uri.scheme == AppConfig.appScheme && 
          uri.host == AppConfig.authCallbackPath) {
        // 세션 복구
        await client.auth.getSessionFromUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      // 딥링크 처리 실패: $e
      return false;
    }
  }
  
  /// 세션 확인 및 갱신
  Future<bool> refreshSession() async {
    try {
      if (currentSession == null) return false;
      
      final response = await client.auth.refreshSession();
      return response.session != null;
    } catch (e) {
      // 세션 갱신 실패: $e
      return false;
    }
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      // 로그아웃 실패: $e
    }
  }
}