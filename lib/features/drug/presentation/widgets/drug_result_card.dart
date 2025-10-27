import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_result.dart';

/// 약품 검색 결과 카드
class DrugResultCard extends StatelessWidget {
  final DrugResult drug;
  final bool isTopResult;
  final VoidCallback? onTap;

  const DrugResultCard({
    super.key,
    required this.drug,
    this.isTopResult = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: isTopResult ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(
                color: isTopResult 
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
                width: isTopResult ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // 약품 이미지 또는 플레이스홀더
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: drug.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            drug.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: AppSpacing.lg),
                
                // 약품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 최고 유사도 뱃지
                      if (isTopResult) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '최고 유사도',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      
                      // 약품명
                      Text(
                        drug.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      
                      // 제조사
                      Text(
                        drug.manufacturer,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      
                      // 정확도
                      Row(
                        children: [
                          // 정확도 바
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: drug.confidence,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getConfidenceColor(drug.confidence),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          
                          // 정확도 퍼센트
                          Text(
                            '${drug.confidencePercent}%',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getConfidenceColor(drug.confidence),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 화살표 아이콘
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.medication_outlined,
        size: 40,
        color: AppColors.textTertiary.withValues(alpha: 0.5),
      ),
    );
  }

  Color _getConfidenceColor(double accuracy) {
    if (accuracy >= 0.8) {
      return const Color(0xFF4CAF50); // Green
    } else if (accuracy >= 0.6) {
      return const Color(0xFFFFA726); // Orange
    } else {
      return const Color(0xFFEF5350); // Red
    }
  }
}