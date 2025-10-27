import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 5단계: 특수 특징
class SpecialFeaturesStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  
  const SpecialFeaturesStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  ConsumerState<SpecialFeaturesStep> createState() => _SpecialFeaturesStepState();
}

class _SpecialFeaturesStepState extends ConsumerState<SpecialFeaturesStep> {
  bool _hasScoreLine = false;
  bool _hasCoating = false;
  final _otherController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    _hasScoreLine = data.hasScoreLine;
    _hasCoating = data.hasCoating;
    _otherController.text = data.specialFeatures ?? '';
  }
  
  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }
  
  void _handleNext() {
    ref.read(drugIdentificationProvider.notifier).updateSpecialFeatures(
      hasScoreLine: _hasScoreLine,
      hasCoating: _hasCoating,
      specialFeatures: _otherController.text.trim().isEmpty 
          ? null 
          : _otherController.text.trim(),
    );
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
            Icons.star_outline,
            size: 48,
            color: Colors.amber,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '특수 특징',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '특별한 특징이 있나요? (선택)',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 가중치 정보
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '5% 가중치 (선택사항)',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 분할선
          _buildFeatureCard(
            title: '분할선',
            description: '약을 반으로 나눌 수 있는 선',
            icon: Icons.horizontal_rule,
            value: _hasScoreLine,
            onChanged: (value) {
              setState(() {
                _hasScoreLine = value!;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // 코팅
          _buildFeatureCard(
            title: '코팅',
            description: '표면이 매끄럽게 코팅되어 있음',
            icon: Icons.water_drop_outlined,
            value: _hasCoating,
            onChanged: (value) {
              setState(() {
                _hasCoating = value!;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 기타 특징
          Text(
            '기타 특징',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _otherController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '예: 반짝이는 입자, 특이한 냄새, 부분적 손상 등',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
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
                  onPressed: _handleNext,
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
  
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value 
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.border,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}