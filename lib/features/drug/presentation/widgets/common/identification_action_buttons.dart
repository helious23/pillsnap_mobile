import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 약품 식별 단계별 화면의 공통 액션 버튼 위젯
class IdentificationActionButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onReset;
  final String nextText;
  final bool isNextEnabled;
  final bool isResetEnabled;
  
  const IdentificationActionButtons({
    super.key,
    required this.onNext,
    this.onReset,
    this.nextText = '다음',
    this.isNextEnabled = true,
    this.isResetEnabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 다음 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: isNextEnabled ? onNext : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              nextText,
              style: AppTextStyles.button,
            ),
          ),
        ),
        
        // 초기화 버튼이 있는 경우에만 표시
        if (onReset != null) ...[
          const SizedBox(width: AppSpacing.md),
          _ResetButton(
            onPressed: isResetEnabled ? onReset : null,
          ),
        ],
      ],
    );
  }
}

/// 초기화 버튼 (일관된 사이즈와 스타일)
class _ResetButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const _ResetButton({
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, // 일관된 너비
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          side: BorderSide(
            color: onPressed != null 
              ? AppColors.border 
              : AppColors.border.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 18,
              color: onPressed != null
                ? AppColors.textSecondary
                : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '초기화',
              style: AppTextStyles.button.copyWith(
                color: onPressed != null
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}