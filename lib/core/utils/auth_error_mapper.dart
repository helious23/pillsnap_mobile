import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 인증 에러 표준화 매퍼
class AuthErrorMapper {
  /// 표준 에러 코드
  static const String alreadyRegistered = 'already_registered';
  static const String emailNotConfirmed = 'email_not_confirmed';
  static const String rateLimited = 'rate_limited';
  static const String invalidCredentials = 'invalid_credentials';
  static const String weakPassword = 'weak_password';
  static const String invalidEmail = 'invalid_email';
  static const String unknown = 'unknown';
  
  /// AuthException을 표준 에러 코드로 변환
  static String mapError(AuthException e) {
    final message = e.message.toLowerCase();
    final statusCode = e.statusCode?.toString();
    
    // 1. 이미 가입된 이메일 (최우선 체크)
    if (message.contains('user_already_registered') ||
        message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('email already registered') ||
        (statusCode == '422' && message.contains('registered'))) {
      return alreadyRegistered;
    }
    
    // 2. 이메일 미인증
    if (message.contains('email not confirmed')) {
      return emailNotConfirmed;
    }
    
    // 3. 레이트 리밋
    if (statusCode == '429' || message.contains('rate limit')) {
      return rateLimited;
    }
    
    // 4. 자격증명 불일치 (로그인용)
    if (message.contains('invalid login credentials')) {
      return invalidCredentials;
    }
    
    // 5. 약한 비밀번호
    if (message.contains('weak password')) {
      return weakPassword;
    }
    
    // 6. 잘못된 이메일 형식
    if (message.contains('invalid email')) {
      return invalidEmail;
    }
    
    // 7. 기타
    return unknown;
  }
  
  /// 표준 에러 코드를 사용자 메시지로 변환
  static String getUserMessage(String errorCode) {
    switch (errorCode) {
      case alreadyRegistered:
        return '이미 가입된 이메일입니다. 로그인으로 이동합니다.';
      case emailNotConfirmed:
        return '이메일 인증이 필요합니다';
      case rateLimited:
        return '잠시 후 다시 시도해주세요 (60초)';
      case invalidCredentials:
        return '이메일 또는 비밀번호가 일치하지 않습니다';
      case weakPassword:
        return '비밀번호가 너무 약합니다';
      case invalidEmail:
        return '올바른 이메일 형식이 아닙니다';
      default:
        return '잠시 후 다시 시도해주세요';
    }
  }
}