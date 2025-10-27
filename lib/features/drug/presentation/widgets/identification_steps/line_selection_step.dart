import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 분할선 선택 단계 (Step 6)
class LineSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const LineSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<LineSelectionStep> createState() => _LineSelectionStepState();
}

class _LineSelectionStepState extends ConsumerState<LineSelectionStep> {
  String? selectedLine;  // 하나의 분할선만 선택
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    // 기존 데이터가 있으면 첫 번째 것 사용
    selectedLine = data.lineFront ?? data.lineBack ?? 'none';
  }
  
  void _handleNext() {
    // 앞면과 뒷면 모두에 동일한 값 저장
    ref.read(drugIdentificationProvider.notifier).updateLines(
      front: selectedLine,
      back: selectedLine,
    );
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseIdentificationStep(
      title: '약에 분할선이 있나요?',
      subtitle: '약을 쉽게 나누기 위한 홈이나 선을 확인하세요',
      content: _buildLineSelection(),
      onNext: _handleNext,
      onReset: () {
        setState(() {
          selectedLine = 'none';
        });
      },
      isResetEnabled: selectedLine != 'none',
      nextText: selectedLine == 'none' ? '분할선 없음' : '다음',
      isNextEnabled: true,
    );
  }
  
  Widget _buildLineSelection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: [
            _buildLineOption(
              value: 'none',
              label: '없음',
              icon: _buildLineIcon('none'),
              isSelected: selectedLine == 'none',
              onTap: () => setState(() => selectedLine = 'none'),
            ),
            _buildLineOption(
              value: '-',
              label: '(－)',
              icon: _buildLineIcon('-'),
              isSelected: selectedLine == '-',
              onTap: () => setState(() => selectedLine = '-'),
            ),
            _buildLineOption(
              value: '+',
              label: '(＋)',
              icon: _buildLineIcon('+'),
              isSelected: selectedLine == '+',
              onTap: () => setState(() => selectedLine = '+'),
            ),
            _buildLineOption(
              value: 'other',
              label: '기타',
              icon: _buildLineIcon('other'),
              isSelected: selectedLine == 'other',
              onTap: () => setState(() => selectedLine = 'other'),
            ),
      ],
    );
  }
  
  Widget _buildLineOption({
    required String value,
    required String label,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 3 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLineIcon(String type) {
    const size = 32.0;
    
    switch (type) {
      case 'none':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        );
      
      case '-':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textSecondary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.6,
              height: 2,
              color: AppColors.textSecondary,
            ),
          ),
        );
      
      case '+':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textSecondary,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.6,
                height: 2,
                color: AppColors.textSecondary,
              ),
              Container(
                width: 2,
                height: size * 0.6,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      
      case 'other':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textSecondary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.5, size * 0.6),
              painter: _SCurvePainter(color: AppColors.textSecondary),
            ),
          ),
        );
      
      default:
        return Container();
    }
  }
}

/// S 커브 모양을 그리는 CustomPainter
class _SCurvePainter extends CustomPainter {
  final Color color;
  
  _SCurvePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // S 커브 그리기
    path.moveTo(size.width * 0.2, size.height * 0.8);
    
    // 첫 번째 커브 (아래에서 위로)
    path.cubicTo(
      size.width * 0.2, size.height * 0.5,  // 제어점 1
      size.width * 0.5, size.height * 0.5,  // 제어점 2
      size.width * 0.5, size.height * 0.5,  // 중간점
    );
    
    // 두 번째 커브 (위에서 아래로)
    path.cubicTo(
      size.width * 0.5, size.height * 0.5,  // 제어점 1
      size.width * 0.8, size.height * 0.5,  // 제어점 2
      size.width * 0.8, size.height * 0.2,  // 끝점
    );
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(_SCurvePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}