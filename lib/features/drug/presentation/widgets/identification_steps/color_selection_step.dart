import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 색상 선택 단계 (Step 3)
class ColorSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const ColorSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<ColorSelectionStep> createState() => _ColorSelectionStepState();
}

class _ColorSelectionStepState extends ConsumerState<ColorSelectionStep> {
  List<String> selectedColors = [];
  
  // 16가지 색상 순서대로 배치
  final List<String> colorOrder = [
    '하양', '노랑', '주황', '분홍',
    '빨강', '갈색', '연두', '초록',
    '청록', '파랑', '남색', '자주',
    '보라', '회색', '검정', '투명',
  ];
  
  // 색상별 실제 색상값
  final Map<String, Color> colorValues = {
    '하양': const Color(0xFFFAFAFA),
    '노랑': const Color(0xFFFFD93D),
    '주황': const Color(0xFFFF8C00),
    '분홍': const Color(0xFFFFB6C1),
    '빨강': const Color(0xFFFF0000),
    '갈색': const Color(0xFF8B4513),
    '연두': const Color(0xFF90EE90),
    '초록': const Color(0xFF008000),
    '청록': const Color(0xFF00CED1),
    '파랑': const Color(0xFF4169E1),
    '남색': const Color(0xFF000080),
    '자주': const Color(0xFF8B008B),
    '보라': const Color(0xFF800080),
    '회색': const Color(0xFF808080),
    '검정': const Color(0xFF000000),
    '투명': const Color(0xFFE0E0E0),
  };
  
  // 그룹 선택 로직
  final Map<String, List<String>> colorGroups = {
    '노랑': ['노랑', '주황', '분홍', '빨강', '갈색'],
    '초록': ['연두', '초록', '청록'],
    '파랑': ['청록', '파랑', '남색'],
    '보라': ['자주', '보라'],
  };
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    selectedColors = List<String>.from(data.colors);
  }
  
  void _toggleColor(String color) {
    setState(() {
      if (selectedColors.contains(color)) {
        // 개별 선택 해제
        selectedColors.remove(color);
      } else {
        // 색상 선택 시 그룹 자동 선택
        selectedColors.add(color);
        
        // 그룹에 속한 색상들도 함께 선택
        for (final entry in colorGroups.entries) {
          if (entry.value.contains(color)) {
            for (final groupColor in entry.value) {
              if (!selectedColors.contains(groupColor)) {
                selectedColors.add(groupColor);
              }
            }
            break;
          }
        }
      }
    });
    
    // 상태 업데이트
    ref.read(drugIdentificationProvider.notifier).updateColors(selectedColors);
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseIdentificationStep(
      title: '약의 색상은 무엇인가요?',
      subtitle: '해당되는 색상을 모두 선택하세요',
      content: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
        children: colorOrder.map((colorName) {
          final isSelected = selectedColors.contains(colorName);
          return _ColorCard(
            color: colorValues[colorName]!,
            label: colorName,
            isSelected: isSelected,
            onTap: () => _toggleColor(colorName),
          );
        }).toList(),
      ),
      onNext: () {
        ref.read(drugIdentificationProvider.notifier).updateColors(selectedColors);
        widget.onNext();
      },
      onReset: () {
        setState(() {
          selectedColors.clear();
        });
        ref.read(drugIdentificationProvider.notifier).updateColors([]);
      },
      nextText: selectedColors.isEmpty ? '색상 선택' : '다음',
      isNextEnabled: selectedColors.isNotEmpty,
      isResetEnabled: selectedColors.isNotEmpty,
    );
  }
}

/// 색상 카드 위젯
class _ColorCard extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ColorCard({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // 하양 카드 특별 처리
    final isWhite = label == '하양';
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWhite 
                      ? Colors.grey.withValues(alpha: 0.6)
                      : Colors.grey.withValues(alpha: 0.2),
                    width: isWhite ? 1.0 : 0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}