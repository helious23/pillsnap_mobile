import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/auth_error_mapper.dart';
import '../../../../core/utils/input_validator.dart';

/// 인증 리포지토리
class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  
  /// 이메일/비밀번호로 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    debugPrint('🔍 [AUTH_REPO.signUp] 시작 - email: $email');
    
    // 입력 검증 (보안)
    final sanitizedEmail = InputValidator.sanitizeEmail(email);
    final sanitizedPassword = InputValidator.sanitizePassword(password);
    
    if (sanitizedEmail == null) {
      debugPrint('🚨 [AUTH_REPO.signUp] 유효하지 않은 이메일 형식');
      throw Exception('올바른 이메일 형식이 아닙니다');
    }
    
    if (sanitizedPassword == null) {
      debugPrint('🚨 [AUTH_REPO.signUp] 유효하지 않은 비밀번호');
      throw Exception('비밀번호는 8자 이상이어야 합니다');
    }
    
    // Supabase의 기본 동작: 이미 가입된 이메일에 대해서도 새 User를 생성함 (보안상 이유)
    // 해결책: signUp 전에 로그인 시도로 계정 존재 여부 확인
    
    try {
      // 1단계: 먼저 로그인 시도로 계정 존재 여부 확인
      debugPrint('🔍 [AUTH_REPO.signUp] 1단계: 로그인 시도로 계정 존재 확인');
      try {
        await _supabase.client.auth.signInWithPassword(
          email: sanitizedEmail,
          password: sanitizedPassword,
        );
        // 로그인 성공 = 이미 존재하는 계정
        debugPrint('🚨 [AUTH_REPO.signUp] 로그인 성공 - 이미 가입된 계정');
        await _supabase.client.auth.signOut();
        throw Exception('이미 가입된 이메일입니다. 로그인으로 이동합니다.');
      } on AuthException catch (authError) {
        debugPrint('🔍 [AUTH_REPO.signUp] 로그인 실패: ${authError.message}');
        // 로그인 실패 = 계정이 없거나 비밀번호가 틀림
        // Invalid login credentials = 계정이 없음 (회원가입 진행)
        // Email not confirmed = 계정은 있지만 미인증
        if (authError.message.toLowerCase().contains('email not confirmed')) {
          debugPrint('🚨 [AUTH_REPO.signUp] 이메일 미인증 계정 존재');
          // 미인증 계정은 특별한 예외로 처리
          throw Exception('EMAIL_NOT_CONFIRMED:이메일 인증이 필요합니다.');
        }
        // Invalid credentials면 계정이 없으므로 회원가입 진행
      }
      
      // 2단계: 실제 회원가입
      debugPrint('🔍 [AUTH_REPO.signUp] 2단계: 실제 회원가입 진행');
      final response = await _supabase.client.auth.signUp(
        email: sanitizedEmail,
        password: sanitizedPassword,
        data: displayName != null ? {'display_name': displayName} : null,
        emailRedirectTo: AppConfig.authCallbackUrl,
      );
      
      debugPrint('🔍 [AUTH_REPO.signUp] 응답 수신');
      debugPrint('  - User ID: ${response.user?.id}');
      debugPrint('  - Session: ${response.session != null ? "있음" : "없음"}');
      debugPrint('  - User Email: ${response.user?.email}');
      debugPrint('  - Email Confirmed: ${response.user?.emailConfirmedAt != null}');
      
      // 세션이 생성된 경우 - 이미 가입되고 인증된 계정
      if (response.session != null) {
        debugPrint('🚨 [AUTH_REPO.signUp] 예상치 못한 세션 생성');
        await _supabase.client.auth.signOut();
        throw Exception('이미 가입된 이메일입니다. 로그인으로 이동합니다.');
      }
      
      debugPrint('✅ [AUTH_REPO.signUp] 성공 - 새 사용자 회원가입 완료');
      return response;
    } on AuthException catch (e) {
      debugPrint('🚨 [AUTH_REPO.signUp] AuthException 발생');
      debugPrint('  - 메시지: ${e.message}');
      debugPrint('  - 상태코드: ${e.statusCode}');
      
      final errorCode = AuthErrorMapper.mapError(e);
      final userMessage = AuthErrorMapper.getUserMessage(errorCode);
      
      debugPrint('🚨 [AUTH_REPO.signUp] 에러 코드: $errorCode');
      debugPrint('🚨 [AUTH_REPO.signUp] 사용자 메시지: $userMessage');
      
      // 표준화된 에러 처리
      if (errorCode == AuthErrorMapper.alreadyRegistered) {
        debugPrint('🚨 [AUTH_REPO.signUp] 결정: 이미 가입된 이메일 -> Exception 던짐');
        throw Exception(userMessage);
      }
      
      debugPrint('🚨 [AUTH_REPO.signUp] 결정: 기타 에러 -> _handleAuthException');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('🚨 [AUTH_REPO.signUp] 일반 Exception: $e');
      rethrow;
    }
  }
  
  /// 이메일/비밀번호로 로그인
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('=== 로그인 응답 ===');
      debugPrint('User ID: ${response.user?.id}');
      debugPrint('Email: ${response.user?.email}');
      debugPrint('Email Confirmed At: ${response.user?.emailConfirmedAt}');
      debugPrint('Session: ${response.session != null ? "있음" : "없음"}');
      
      // 로그인은 성공했지만 이메일 인증 확인은 여기서 하지 않음
      // (Supabase가 자체적으로 Email not confirmed 에러를 발생시킴)
      
      return response;
    } on AuthException catch (e) {
      debugPrint('AuthException 발생: ${e.message}, statusCode=${e.statusCode}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('일반 Exception 발생: $e');
      rethrow;
    }
  }
  
  /// 비밀번호 재설정 요청
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConfig.authCallbackUrl,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// 비밀번호 업데이트 (재설정 후)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// 이메일 인증 재전송
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// [DEPRECATED] 이메일 중복 체크 - 사용하지 않음
  /// Supabase signUp의 응답으로만 판단
  @Deprecated('Use signUp response to check if email exists')
  Future<bool> checkEmailExists(String email) async {
    try {
      debugPrint('=== 이메일 중복 체크 시작: $email ===');
      
      // 1. 먼저 profiles 테이블에서 확인
      final profileResponse = await _supabase.client
          .from('profiles')
          .select('email')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();
      
      debugPrint('Profile 조회 결과: $profileResponse');
      
      if (profileResponse != null) {
        debugPrint('이메일이 이미 존재함 (profiles 테이블)');
        return true;
      }
      
      // 2. signInWithPassword를 시도하여 계정 존재 여부 확인
      try {
        await _supabase.client.auth.signInWithPassword(
          email: email.toLowerCase().trim(),
          password: 'DummyPassword123!', // 틀린 비밀번호
        );
        // 로그인이 성공하면 (실제로는 일어나지 않음) 이메일 존재
        debugPrint('이메일이 존재함 (로그인 성공?)');
        await _supabase.client.auth.signOut(); // 혹시 모르니 로그아웃
        return true;
      } on AuthException catch (authError) {
        debugPrint('SignIn Auth 에러: ${authError.message}');
        debugPrint('SignIn Auth 상태코드: ${authError.statusCode}');
        
        // Email not confirmed 에러는 이메일이 존재한다는 의미
        if (authError.message.toLowerCase().contains('email not confirmed')) {
          debugPrint('이메일이 존재함 (이메일 미인증)');
          return true;
        }
        
        // "Invalid login credentials"는 이메일이 없을 때도 반환됨 (보안상 이유)
        // 따라서 이 경우는 존재하지 않는 것으로 처리
        if (authError.message.toLowerCase().contains('invalid login credentials')) {
          debugPrint('Invalid credentials - 이메일 존재하지 않음으로 처리');
          return false;
        }
        
        // 기타 에러는 존재하지 않는 것으로 처리
        debugPrint('기타 에러 - 존재하지 않음으로 처리');
        return false;
      }
    } catch (e) {
      debugPrint('이메일 중복 체크 에러: $e');
      return false;
    }
  }
  
  /// 로그인용 이메일 체크 (가입된 이메일인지 확인)
  Future<bool> checkEmailForLogin(String email) async {
    try {
      debugPrint('=== 로그인용 이메일 체크 시작: $email ===');
      
      // Supabase Admin API를 통해 이메일로 사용자 존재 여부 확인
      // signInWithPassword를 dry run처럼 사용
      try {
        // 틀린 비밀번호로 로그인 시도하여 사용자 존재 여부 확인
        await _supabase.client.auth.signInWithPassword(
          email: email.toLowerCase().trim(), 
          password: 'dummy_password_for_check_12345!@#'
        );
        // 이 줄에 도달하면 안됨 (비밀번호가 맞을 리 없음)
        return true;
      } catch (authError) {
        final errorMessage = authError.toString().toLowerCase();
        debugPrint('Auth 체크 에러 메시지: $errorMessage');
        
        // Invalid login credentials = 사용자는 존재하지만 비밀번호가 틀림
        if (errorMessage.contains('invalid login credentials') || 
            errorMessage.contains('invalid password')) {
          debugPrint('사용자 존재함 - 비밀번호 틀림');
          return true;
        }
        
        // User not found 또는 다른 메시지 = 사용자가 없음
        if (errorMessage.contains('user not found') ||
            errorMessage.contains('no user found') ||
            errorMessage.contains('not been registered')) {
          debugPrint('사용자 존재하지 않음');
          return false;
        }
        
        // 기본값: 사용자 존재한다고 가정
        debugPrint('기타 에러 - 사용자 존재한다고 가정');
        return true;
      }
    } catch (e) {
      debugPrint('로그인용 이메일 체크 에러: $e');
      // 에러 시에는 로그인 시도하도록 true 반환
      return true;
    }
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    await _supabase.signOut();
  }
  
  /// 현재 사용자
  User? get currentUser => _supabase.currentUser;
  
  /// 현재 세션
  Session? get currentSession => _supabase.currentSession;
  
  /// 인증 상태 스트림
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;
  
  /// 세션 갱신
  Future<bool> refreshSession() => _supabase.refreshSession();
  
  /// 에러 처리
  Exception _handleAuthException(AuthException e) {
    // Supabase의 실제 에러 코드는 문자열이 아닌 null일 수 있음
    final statusCode = e.statusCode ?? '';
    
    // Email not confirmed 에러 처리 (가장 먼저 체크)
    if (e.message.contains('Email not confirmed')) {
      return Exception('이메일 인증이 필요합니다');
    }
    
    // Invalid login credentials 에러 처리
    if (e.message.contains('Invalid login credentials')) {
      return Exception('이메일 또는 비밀번호가 일치하지 않습니다');
    }
    
    switch (statusCode) {
      case '400':
        if (e.message.contains('email')) {
          return Exception('잘못된 이메일 형식입니다');
        } else if (e.message.contains('password')) {
          return Exception('비밀번호는 최소 8자 이상이어야 합니다');
        }
        return Exception('입력 정보를 확인해주세요');
        
      case '422':
        if (e.message.contains('already registered')) {
          return Exception('이미 가입된 이메일입니다');
        }
        return Exception('처리할 수 없는 요청입니다');
        
      case '401':
        return Exception('이메일 또는 비밀번호가 일치하지 않습니다');
        
      case '403':
        return Exception('이메일 인증이 필요합니다. 메일함을 확인해주세요');
        
      default:
        // 기본 에러 메시지
        return Exception(e.message);
    }
  }
}