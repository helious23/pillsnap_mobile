import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 6단계: 추가 정보
class AdditionalInfoStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;
  
  const AdditionalInfoStep({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  ConsumerState<AdditionalInfoStep> createState() => _AdditionalInfoStepState();
}

class _AdditionalInfoStepState extends ConsumerState<AdditionalInfoStep> {
  String? _selectedDrugType;
  final _suspectedNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  final List<Map<String, String>> _drugTypes = [
    {'name': '정제', 'code': 'tablet'},
    {'name': '캡슐', 'code': 'capsule'},
    {'name': '산제', 'code': 'powder'},
    {'name': '과립', 'code': 'granule'},
    {'name': '기타', 'code': 'other'},
  ];
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    _selectedDrugType = data.drugType;
    _suspectedNameController.text = data.suspectedName ?? '';
    _notesController.text = data.notes ?? '';
  }
  
  @override
  void dispose() {
    _suspectedNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _handleComplete() {
    ref.read(drugIdentificationProvider.notifier).updateAdditionalInfo(
      drugType: _selectedDrugType,
      suspectedName: _suspectedNameController.text.trim().isEmpty 
          ? null 
          : _suspectedNameController.text.trim(),
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );
    widget.onComplete();
  }
  
  @override
  Widget build(BuildContext context) {
    final identificationData = ref.watch(drugIdentificationProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.note_add,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '추가 정보',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '선택사항입니다',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 최종 정확도 표시
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '예상 정확도',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${identificationData.estimatedAccuracy}%',
                  style: AppTextStyles.h1.copyWith(
                    color: identificationData.estimatedAccuracy >= 85 
                        ? AppColors.success
                        : identificationData.estimatedAccuracy >= 70
                            ? AppColors.primary
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!ref.read(drugIdentificationProvider.notifier).hasTextInput)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '식별 문자 미입력',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 약품 종류
          Text(
            '약품 종류',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _drugTypes.map((type) {
              final isSelected = _selectedDrugType == type['code'];
              return ChoiceChip(
                label: Text(type['name']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedDrugType = selected ? type['code'] : null;
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 예상 약품명
          Text(
            '예상 약품명',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _suspectedNameController,
            decoration: InputDecoration(
              hintText: '알고 계신 약품명이 있다면 입력해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 메모
          Text(
            '메모',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '추가로 알려주실 정보가 있나요?',
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
                child: ElevatedButton.icon(
                  onPressed: _handleComplete,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('촬영하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}