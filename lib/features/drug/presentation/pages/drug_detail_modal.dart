import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_detail_controller.dart';

/// 약품 상세 정보 모달
class DrugDetailModal extends ConsumerStatefulWidget {
  final String drugId;
  
  const DrugDetailModal({
    super.key,
    required this.drugId,
  });

  @override
  ConsumerState<DrugDetailModal> createState() => _DrugDetailModalState();
  
  /// 모달 표시 헬퍼 메서드
  static Future<void> show(BuildContext context, String drugId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => DrugDetailModal(drugId: drugId),
    );
  }
}

class _DrugDetailModalState extends ConsumerState<DrugDetailModal> {
  bool _isImageExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drugDetailProvider(widget.drugId));
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 상단 핸들 바
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 닫기 버튼
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          
          // 콘텐츠
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildError(state.error!)
                    : state.drug != null
                        ? _buildContent(state.drug!)
                        : const SizedBox(),
          ),
          
          // 하단 정보 및 버튼
          if (state.drug != null) _buildBottomSection(state.drug!),
        ],
      ),
    );
  }
  
  Widget _buildContent(DrugDetail drug) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // 약품 이미지
          GestureDetector(
            onTap: () {
              setState(() {
                _isImageExpanded = !_isImageExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isImageExpanded ? 400 : 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),  // 베이지색 배경
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (drug.imageUrl != null)
                    Center(
                      child: Hero(
                        tag: 'drug_image_${drug.itemSeq}',
                        child: Image.network(
                          drug.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderPill();
                          },
                        ),
                      ),
                    )
                  else
                    _buildPlaceholderPill(),
                  
                  // 확대/축소 힌트
                  Positioned(
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isImageExpanded ? Icons.zoom_in_map : Icons.zoom_out_map,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // 기본 정보
          _buildInfoSection(
            '기본 정보',
            [
              if (drug.entpName.isNotEmpty)
                _buildInfoRow('제조사', drug.entpName),
              if (drug.etcOtcCode != null)
                _buildInfoRow('구분', drug.etcOtcCode!),
              if (drug.chart != null)
                _buildInfoRow('제형', drug.chart!),
              if (drug.colorClass1 != null)
                _buildInfoRow('색상', drug.colorClass1!),
              if (drug.printFront != null || drug.printBack != null)
                _buildInfoRow(
                  '식별표시',
                  '${drug.printFront ?? ''} ${drug.printBack ?? ''}'.trim(),
                ),
            ],
          ),
          
          // 성분 정보
          if (drug.ingredients != null && drug.ingredients!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildInfoSection(
              '성분 정보',
              drug.ingredients!
                  .map((i) => _buildInfoRow(i.name, '${i.amount ?? ''} ${i.unit ?? ''}'))
                  .toList(),
            ),
          ],
          
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderPill() {
    return Center(
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.primary.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim(),
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomSection(DrugDetail drug) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 약품명
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug.itemName,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    drug.entpName,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // 알림 버튼
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${drug.itemName} 알림이 설정되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text(
                '알림',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '오류가 발생했습니다',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}