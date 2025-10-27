import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 애플리케이션 크기 및 반경 토큰
class AppRadius {
  AppRadius._();
  
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 999;
}

/// 애플리케이션 그림자 스타일
class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: AppColors.shadowColor.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];
}