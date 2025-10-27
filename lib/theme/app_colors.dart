import 'package:flutter/material.dart';

/// 애플리케이션 색상 토큰
class AppColors {
  AppColors._();
  
  // 주요 색상
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0F62D6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F9FC);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color sectionBg = Color(0xFFF5F7FA);
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFF0B0F1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // 상태 색상
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // 테두리 및 구분선
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  
  // 그라디언트 색상
  static const Color cardBlueStart = Color(0xFF1169F3);
  static const Color cardBlueEnd = Color(0xFF0259EC);
  static const Color cardDarkStart = Color(0xFF334155);
  static const Color cardDarkEnd = Color(0xFF1F2937);
  
  // 그림자
  static Color shadowColor = const Color(0xFF111827).withValues(alpha: 0.08);
}