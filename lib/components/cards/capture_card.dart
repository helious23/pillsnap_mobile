import 'package:flutter/material.dart';
import '../../theme.dart';

class CaptureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final bool large;
  final bool isDark;
  final VoidCallback onTap;
  final bool showInfoTooltip;

  const CaptureCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    this.large = false,
    this.isDark = false,
    required this.onTap,
    this.showInfoTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: large ? AppSpacing.lg : AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: EdgeInsets.all(large ? AppSpacing.xxl : AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.cardDarkStart, AppColors.cardDarkEnd]
                : [AppColors.cardBlueStart, AppColors.cardBlueEnd],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: large ? AppShadows.card : AppShadows.elevation1,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 좌측 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          description!,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 우측 아이콘
                Container(
                  width: large ? 96 : 80,
                  height: large ? 96 : 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    icon,
                    size: large ? 36 : 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // 정보 툴팁
            if (showInfoTooltip)
              Positioned(
                top: 0,
                right: 0,
                child: _InfoTooltip(),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTooltip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.info_outline,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}