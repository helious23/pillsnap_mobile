import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 제형 선택 단계 (Step 1)
class FormSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FormSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<FormSelectionStep> createState() => _FormSelectionStepState();
}

class _FormSelectionStepState extends ConsumerState<FormSelectionStep> {
  String? selectedForm;
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    selectedForm = data.form;
  }
  
  void _selectForm(String form) {
    setState(() {
      selectedForm = form;
    });
    ref.read(drugIdentificationProvider.notifier).setForm(form);
  }
  
  void _handleNext() {
    if (selectedForm != null) {
      widget.onNext();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseIdentificationStep(
      title: '어떤 형태의 약인가요?',
      subtitle: '약의 기본 형태를 선택해주세요',
      content: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.3,
        children: [
          _CompactFormButton(
            iconWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            title: '정제',
            isSelected: selectedForm == '정제',
            onTap: () => _selectForm('정제'),
          ),
          _CompactFormButton(
            iconWidget: Container(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: '경질캡슐',
            isSelected: selectedForm == '경질캡슐',
            onTap: () => _selectForm('경질캡슐'),
          ),
          _CompactFormButton(
            iconWidget: Container(
              width: 60,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.6),
                    Colors.orange.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            title: '연질캡슐',
            isSelected: selectedForm == '연질캡슐',
            onTap: () => _selectForm('연질캡슐'),
          ),
          _CompactFormButton(
            iconWidget: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
            title: '기타',
            isSelected: selectedForm == '기타',
            onTap: () => _selectForm('기타'),
          ),
        ],
      ),
      onNext: _handleNext,
      onReset: () {
        setState(() {
          selectedForm = null;
        });
        ref.read(drugIdentificationProvider.notifier).setForm(null);
      },
      nextText: selectedForm == null ? '제형 선택' : '다음',
      isNextEnabled: selectedForm != null,
      isResetEnabled: selectedForm != null,
    );
  }
}

/// 컴팩트한 제형 선택 버튼
class _CompactFormButton extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactFormButton({
    required this.iconWidget,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}