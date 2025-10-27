import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 4단계: 크기 선택
class SizeSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const SizeSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<SizeSelectionStep> createState() => _SizeSelectionStepState();
}

class _SizeSelectionStepState extends ConsumerState<SizeSelectionStep> {
  final List<Map<String, String>> _sizes = [
    {'name': '소형', 'code': 'small', 'desc': '5-10mm', 'icon': '●'},
    {'name': '중형', 'code': 'medium', 'desc': '10-15mm', 'icon': '⬤'},
    {'name': '대형', 'code': 'large', 'desc': '15-20mm', 'icon': '⬤'},
    {'name': '초대형', 'code': 'xlarge', 'desc': '20mm 이상', 'icon': '⬤'},
  ];
  
  String? _selectedSize;
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    _selectedSize = data.size;
  }
  
  void _handleNext() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('약품의 크기를 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    ref.read(drugIdentificationProvider.notifier).updateSize(_selectedSize);
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // 헤더
          const Icon(
            Icons.straighten,
            size: 48,
            color: Colors.purple,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '크기 선택',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '약품의 대략적인 크기를 선택해주세요',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 가중치 정보
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.purple,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '10% 가중치',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 참고 이미지
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReferenceItem('동전', '10원', '23mm'),
                _buildReferenceItem('동전', '100원', '24mm'),
                _buildReferenceItem('동전', '500원', '26.5mm'),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 크기 선택
          ...List.generate(_sizes.length, (index) {
            final size = _sizes[index];
            final isSelected = _selectedSize == size['code'];
            final iconSize = 20.0 + (index * 10);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSize = size['code'];
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 크기 시각화
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          size['icon']!,
                          style: TextStyle(
                            fontSize: iconSize,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      // 설명
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              size['name']!,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              size['desc']!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: AppSpacing.xxxl),
          
          // 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selectedSize != null ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('다음'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReferenceItem(String label, String name, String size) {
    return Column(
      children: [
        const Icon(
          Icons.monetization_on,
          size: 32,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          size,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}