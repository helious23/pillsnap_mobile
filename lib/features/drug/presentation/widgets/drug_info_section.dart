import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 약품 정보 섹션 위젯
class DrugInfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final bool isWarning;

  const DrugInfoSection({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isWarning 
            ? const Color(0xFFFFF3E0) // 경고는 주황색 배경
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isWarning
            ? Border.all(
                color: const Color(0xFFFFB74D),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isWarning
                  ? const Color(0xFFFFB74D).withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: isWarning
                        ? const Color(0xFFE65100)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isWarning
                          ? const Color(0xFFE65100)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 내용
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              content,
              style: AppTextStyles.body2.copyWith(
                height: 1.6,
                color: isWarning
                    ? const Color(0xFFE65100)
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}