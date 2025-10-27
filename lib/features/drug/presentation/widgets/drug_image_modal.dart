import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:pillsnap/theme/app_spacing.dart';

/// 약품 이미지 확대 모달
class DrugImageModal extends StatelessWidget {
  final Widget pillImage;
  
  const DrugImageModal({
    super.key,
    required this.pillImage,
  });
  
  /// 모달 표시 헬퍼 메서드
  static Future<void> show(BuildContext context, Widget pillImage) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => DrugImageModal(pillImage: pillImage),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 블러 배경
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          
          // 중앙 이미지
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Hero(
                    tag: 'drug_image',
                    child: Transform.scale(
                      scale: 1.5,
                      child: pillImage,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 닫기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.xl,
            right: AppSpacing.xl,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}