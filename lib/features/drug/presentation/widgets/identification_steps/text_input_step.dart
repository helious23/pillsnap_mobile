import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 텍스트 입력 단계
class TextInputStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  
  const TextInputStep({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  ConsumerState<TextInputStep> createState() => _TextInputStepState();
}

class _TextInputStepState extends ConsumerState<TextInputStep> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // 기존 입력값 복원
    final data = ref.read(drugIdentificationProvider);
    _frontController.text = data.textFront ?? '';
    _backController.text = data.textBack ?? '';
  }
  
  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }
  
  void _handleNext() {
    final frontText = _frontController.text.trim();
    final backText = _backController.text.trim();
    
    // 데이터 저장
    ref.read(drugIdentificationProvider.notifier).updateTexts(
      front: frontText.isEmpty ? null : frontText,
      back: backText.isEmpty ? null : backText,
    );
    
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    final hasText = _frontController.text.isNotEmpty || _backController.text.isNotEmpty;
    
    return BaseIdentificationStep(
      title: '약에 적힌 문자가 있나요?',
      subtitle: '영문, 숫자, 기호 등을 입력해주세요',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 앞면 입력
          TextField(
            controller: _frontController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: '앞면',
              hintText: '예: KYP, 123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.text_fields),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 뒷면 입력
          TextField(
            controller: _backController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: '뒷면',
              hintText: '예: 500mg, A/B',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.text_fields),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 도움말
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '보이는 모든 문자와 숫자를 입력하세요',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onNext: _handleNext,
      onReset: () {
        setState(() {
          _frontController.clear();
          _backController.clear();
        });
      },
      nextText: hasText ? '다음' : '건너뛰기',
      isNextEnabled: true,
      isResetEnabled: hasText,
    );
  }
}