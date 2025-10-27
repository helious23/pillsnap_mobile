import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 약품 식별 정보 입력 진행도 바
class IdentificationProgressBar extends StatelessWidget {
  final Map<String, dynamic> identificationData;
  final VoidCallback? onWarningTap;

  const IdentificationProgressBar({
    super.key,
    required this.identificationData,
    this.onWarningTap,
  });

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    // 선형 정확도 계산 (50-95% 범위)
    final estimatedAccuracy = (score * 1.1).clamp(50, 95).toInt();
    final hasTextInput = _hasTextInput();
    final progressColor = _getProgressColor(estimatedAccuracy, hasTextInput);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 진행도 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '입력 완성도',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$estimatedAccuracy%',
              style: AppTextStyles.h3.copyWith(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        
        // 진행도 바
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: estimatedAccuracy / 100,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        
        // 식별 문자 경고 (텍스트 입력이 없을 때만 표시)
        if (!hasTextInput) ...[
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () {
              // 상위 레벨 경고 표시
              _showTextInputWarning(context);
              onWarningTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '식별 문자 입력 필요',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '식별 문자를 입력하면 후보 약품이 10배 줄어들어 정확도가 크게 향상됩니다',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.orange[700],
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // 입력 항목 요약
        const SizedBox(height: AppSpacing.md),
        _buildInputSummary(),
      ],
    );
  }

  /// 점수 계산 (0-100)
  double _calculateScore() {
    double score = 0;
    
    // 텍스트/마크 (40점) - 가장 중요
    if (identificationData['text'] != null && 
        identificationData['text'].toString().isNotEmpty) {
      score += 40;
    }
    
    // 색상 (25점)
    if (identificationData['colors'] != null && 
        (identificationData['colors'] as List).isNotEmpty) {
      final colors = identificationData['colors'] as List;
      score += colors.length >= 2 ? 25 : 15;  // 2색 이상이면 전체 점수
    }
    
    // 모양 (20점)
    if (identificationData['shape'] != null && 
        identificationData['shape'] != 'unknown') {
      score += 20;
    }
    
    // 크기 (10점)
    if (identificationData['size'] != null && 
        identificationData['size'] != 'unknown') {
      score += 10;
    }
    
    // 특수 특징 (5점)
    if (identificationData['hasScoreLine'] == true || 
        identificationData['hasCoating'] == true) {
      score += 5;
    }
    
    return score;
  }

  /// 텍스트 입력 여부 확인
  bool _hasTextInput() {
    return identificationData['text'] != null && 
           identificationData['text'].toString().isNotEmpty;
  }

  /// 진행도에 따른 색상 결정
  Color _getProgressColor(int accuracy, bool hasText) {
    // 텍스트가 없으면 주황색 계열로 표시
    if (!hasText) {
      return Colors.orange;
    }
    
    // 텍스트가 있으면 정확도에 따라 색상 결정
    if (accuracy >= 85) {
      return AppColors.success;
    } else if (accuracy >= 70) {
      return Colors.blue;
    } else if (accuracy >= 60) {
      return Colors.orange;
    } else {
      return AppColors.warning;
    }
  }

  /// 입력 항목 요약 빌드
  Widget _buildInputSummary() {
    final items = <Widget>[];
    
    // 텍스트
    if (_hasTextInput()) {
      items.add(_buildSummaryChip(
        Icons.text_fields,
        identificationData['text'].toString(),
        AppColors.success,
      ));
    }
    
    // 색상
    if (identificationData['colors'] != null && 
        (identificationData['colors'] as List).isNotEmpty) {
      final colors = identificationData['colors'] as List;
      items.add(_buildSummaryChip(
        Icons.palette,
        '${colors.length}가지 색상',
        AppColors.info,
      ));
    }
    
    // 모양
    if (identificationData['shape'] != null && 
        identificationData['shape'] != 'unknown') {
      items.add(_buildSummaryChip(
        Icons.category,
        _getShapeName(identificationData['shape'].toString()),
        AppColors.primary,
      ));
    }
    
    // 크기
    if (identificationData['size'] != null && 
        identificationData['size'] != 'unknown') {
      items.add(_buildSummaryChip(
        Icons.straighten,
        _getSizeName(identificationData['size'].toString()),
        Colors.purple,
      ));
    }
    
    if (items.isEmpty) {
      return Text(
        '입력된 정보가 없습니다',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }
    
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: items,
    );
  }

  /// 요약 칩 빌드
  Widget _buildSummaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 모양 이름 변환
  String _getShapeName(String shape) {
    const shapeNames = {
      'round': '원형',
      'oval': '타원형',
      'triangle': '삼각형',
      'square': '사각형',
      'diamond': '마름모형',
      'pentagon': '오각형',
      'hexagon': '육각형',
      'octagon': '팔각형',
      'capsule': '캡슐형',
      'unknown': '알 수 없음',
    };
    return shapeNames[shape] ?? shape;
  }

  /// 크기 이름 변환
  String _getSizeName(String size) {
    const sizeNames = {
      'small': '소형 (5-10mm)',
      'medium': '중형 (10-15mm)',
      'large': '대형 (15-20mm)',
      'xlarge': '초대형 (20mm+)',
      'unknown': '알 수 없음',
    };
    return sizeNames[size] ?? size;
  }

  /// 텍스트 입력 경고 다이얼로그 표시
  void _showTextInputWarning(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 48,
          color: Colors.orange,
        ),
        title: const Text('식별 문자 입력이 중요합니다'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '약품에 인쇄된 문자나 기호는 약품 식별의 가장 중요한 정보입니다.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '식별 문자를 입력하면 후보 약품이 10배 이상 줄어들어 정확도가 크게 향상됩니다.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '예시:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '• "KYP", "123", "A/B" 등의 영문/숫자\n'
              '• 제약사 로고나 마크\n'
              '• 용량 표시 ("500mg" 등)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}