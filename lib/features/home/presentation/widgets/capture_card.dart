import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/theme/app_dimensions.dart';

/// 캡처 카드 위젯
class CaptureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool large;
  final bool isDark;
  final bool showInfoTooltip;
  final VoidCallback onTap;
  
  const CaptureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.large = false,
    this.isDark = false,
    this.showInfoTooltip = false,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: EdgeInsets.all(large ? AppSpacing.xl : AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isDark 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade400.withValues(alpha: 0.7),
                    Colors.grey.shade500.withValues(alpha: 0.6),
                    Colors.grey.shade600.withValues(alpha: 0.5),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4FC3F7),
                    Color(0xFF1976D2),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.grey : AppColors.primary)
                  .withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: (large ? AppTextStyles.h2 : AppTextStyles.h3).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showInfoTooltip) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: large ? 56 : 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}