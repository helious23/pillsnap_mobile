import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/identification_bottom_sheet.dart';

/// 약품 정보 입력 화면의 통일된 레이아웃 템플릿
class BaseIdentificationStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback? onReset;
  final bool isNextEnabled;
  final bool isResetEnabled;
  final String? nextText;
  
  const BaseIdentificationStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onNext,
    this.onReset,
    this.isNextEnabled = true,
    this.isResetEnabled = false,
    this.nextText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 제목 영역 - 모든 화면에서 동일한 위치
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxxl * 1.5,  // 고정된 상단 여백
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // 중앙 컨텐츠 영역 - 완벽한 중앙 정렬
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: content,
            ),
          ),
        ),
        
        // 하단 버튼 영역 - bottom sheet 스타일
        IdentificationBottomSheet(
          onNext: onNext,
          onReset: onReset,
          isNextEnabled: isNextEnabled,
          isResetEnabled: isResetEnabled,
          nextText: nextText,
        ),
      ],
    );
  }
}