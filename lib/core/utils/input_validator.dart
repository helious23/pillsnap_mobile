import 'package:flutter/material.dart';

/// 입력 검증 및 보안 유틸리티
class InputValidator {
  /// 이메일 검증 및 살균
  static String? sanitizeEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    
    // 기본 정리
    email = email.trim().toLowerCase();
    
    // SQL Injection 방지: 위험한 문자 제거
    final dangerous = RegExp('[;<>\'"\\\\\/]'); // ignore: unnecessary_string_escapes
    if (dangerous.hasMatch(email)) {
      debugPrint('⚠️ [SECURITY] 위험한 문자 감지 in email: $email');
      return null;
    }
    
    // 이메일 형식 검증
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return null;
    }
    
    // 최대 길이 제한 (보안)
    if (email.length > 254) { // RFC 5321
      return null;
    }
    
    return email;
  }
  
  /// 비밀번호 검증
  static String? sanitizePassword(String? password) {
    if (password == null || password.isEmpty) return null;
    
    // 최소/최대 길이
    if (password.length < 8 || password.length > 128) {
      return null;
    }
    
    // 제어 문자 제거
    final controlChars = RegExp(r'[\x00-\x1F\x7F]');
    if (controlChars.hasMatch(password)) {
      debugPrint('⚠️ [SECURITY] 제어 문자 감지 in password');
      return null;
    }
    
    return password;
  }
  
  /// 일반 텍스트 살균 (XSS 방지)
  static String sanitizeText(String text) {
    if (text.isEmpty) return text;
    
    // HTML/Script 태그 제거
    text = text
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), '') // 모든 HTML 태그 제거
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), ''); // onclick 등 제거
    
    // 특수 문자 이스케이프
    final escapeMap = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;',
      '/': '&#x2F;',
    };
    
    escapeMap.forEach((key, value) {
      text = text.replaceAll(key, value);
    });
    
    // 최대 길이 제한
    if (text.length > 1000) {
      text = text.substring(0, 1000);
    }
    
    return text;
  }
  
  /// 전화번호 살균
  static String? sanitizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    // 숫자와 하이픈만 허용
    phone = phone.replaceAll(RegExp(r'[^\d-]'), '');
    
    // 한국 전화번호 형식 검증
    final phoneRegex = RegExp(r'^01[0-9]-?\d{3,4}-?\d{4}$');
    if (!phoneRegex.hasMatch(phone)) {
      return null;
    }
    
    return phone;
  }
  
  /// 알레르기 정보 살균
  static List<String> sanitizeAllergies(List<String>? allergies) {
    if (allergies == null || allergies.isEmpty) return [];
    
    return allergies
        .map((item) => sanitizeText(item))
        .where((item) => item.isNotEmpty && item.length <= 100)
        .take(20) // 최대 20개 제한
        .toList();
  }
}

/// 비밀번호 강도 체크
class PasswordStrength {
  static PasswordStrengthLevel checkStrength(String password) {
    if (password.length < 8) return PasswordStrengthLevel.weak;
    
    int strength = 0;
    
    // 길이 점수
    if (password.length >= 12) strength++;
    if (password.length >= 16) strength++;
    
    // 문자 종류 점수
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    // 연속/반복 문자 체크
    if (hasRepeatingChars(password)) strength--;
    if (hasSequentialChars(password)) strength--;
    
    if (strength <= 2) return PasswordStrengthLevel.weak;
    if (strength <= 4) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }
  
  static bool hasRepeatingChars(String password) {
    return RegExp(r'(.)\1{2,}').hasMatch(password); // aaa, 111 등
  }
  
  static bool hasSequentialChars(String password) {
    const sequences = ['123', 'abc', 'qwerty', 'password'];
    final lower = password.toLowerCase();
    return sequences.any((seq) => lower.contains(seq));
  }
  
  static String getMessage(PasswordStrengthLevel level) {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return '약한 비밀번호';
      case PasswordStrengthLevel.medium:
        return '보통 비밀번호';
      case PasswordStrengthLevel.strong:
        return '강한 비밀번호';
    }
  }
  
  static Color getColor(PasswordStrengthLevel level) {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return Colors.red;
      case PasswordStrengthLevel.medium:
        return Colors.orange;
      case PasswordStrengthLevel.strong:
        return Colors.green;
    }
  }
}

enum PasswordStrengthLevel {
  weak,
  medium,
  strong,
}