import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 모양 선택 단계 (Step 2)
class ShapeSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ShapeSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<ShapeSelectionStep> createState() => _ShapeSelectionStepState();
}

class _ShapeSelectionStepState extends ConsumerState<ShapeSelectionStep> {
  List<String> selectedShapes = [];
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    selectedShapes = List<String>.from(data.shapes);
  }

  void _toggleShape(String shape) {
    setState(() {
      // 그룹 정의 - 원형, 타원형, 장방형은 함께 선택
      final shapeGroup = ['원형', '타원형', '장방형'];
      
      if (selectedShapes.contains(shape)) {
        // 개별 선택 해제
        selectedShapes.remove(shape);
      } else {
        selectedShapes.add(shape);
        // 그룹에 속한 모양이면 나머지도 함께 선택
        if (shapeGroup.contains(shape)) {
          for (final groupShape in shapeGroup) {
            if (!selectedShapes.contains(groupShape)) {
              selectedShapes.add(groupShape);
            }
          }
        }
      }
    });
    ref.read(drugIdentificationProvider.notifier).updateShapes(selectedShapes);
  }

  @override
  Widget build(BuildContext context) {
    return BaseIdentificationStep(
      title: '약의 모양은 어떤가요?',
      subtitle: '약의 전체적인 윤곽을 보세요',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                    // 첫번째 줄: 원형, 타원형, 장방형 (크게)
                    Row(
                      children: [
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 50 25 A 25 25 0 1 1 50 75 A 25 25 0 1 1 50 25',
                            label: '원형',
                            isSelected: selectedShapes.contains('원형'),
                            onTap: () => _toggleShape('원형'),
                            isLarge: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 20 50 A 30 20 0 1 1 80 50 A 30 20 0 1 1 20 50',
                            label: '타원형',
                            isSelected: selectedShapes.contains('타원형'),
                            onTap: () => _toggleShape('타원형'),
                            isLarge: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 25 35 L 75 35 A 10 10 0 0 1 75 65 L 25 65 A 10 10 0 0 1 25 35',
                            label: '장방형',
                            isSelected: selectedShapes.contains('장방형'),
                            onTap: () => _toggleShape('장방형'),
                            isLarge: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 두번째 줄: 반원형, 육각형, 팔각형, 기타
                    Row(
                      children: [
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 25 50 A 25 25 0 0 1 75 50 L 25 50',
                            label: '반원형',
                            isSelected: selectedShapes.contains('반원형'),
                            onTap: () => _toggleShape('반원형'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 50 20 L 70 35 L 70 65 L 50 80 L 30 65 L 30 35 Z',
                            label: '육각형',
                            isSelected: selectedShapes.contains('육각형'),
                            onTap: () => _toggleShape('육각형'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 35 25 L 65 25 L 75 35 L 75 65 L 65 75 L 35 75 L 25 65 L 25 35 Z',
                            label: '팔각형',
                            isSelected: selectedShapes.contains('팔각형'),
                            onTap: () => _toggleShape('팔각형'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ShapeCardSvg(
                            svgPath: 'M 40 30 L 60 30 L 60 50 L 70 50 L 50 70 L 30 50 L 40 50 Z',
                            label: '기타',
                            isSelected: selectedShapes.contains('기타'),
                            onTap: () => _toggleShape('기타'),
                          ),
                        ),
                      ],
                    ),
        ],
      ),
      onNext: () {
        ref.read(drugIdentificationProvider.notifier).updateShapes(selectedShapes);
        widget.onNext();
      },
      onReset: () {
        setState(() {
          selectedShapes.clear();
        });
      },
      nextText: selectedShapes.isEmpty ? '모양 선택' : '다음',
      isNextEnabled: selectedShapes.isNotEmpty,
      isResetEnabled: selectedShapes.isNotEmpty,
    );
  }
}

/// SVG 모양 카드 위젯
class _ShapeCardSvg extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLarge;

  const _ShapeCardSvg({
    required this.svgPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLarge = false,
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
          height: isLarge ? 110 : 80,
          padding: EdgeInsets.all(isLarge ? AppSpacing.md : AppSpacing.sm),
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
              SizedBox(
                width: isLarge ? 50 : 35,
                height: isLarge ? 50 : 35,
                child: CustomPaint(
                  painter: _ShapePainter(
                    svgPath: svgPath,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: isLarge ? 13 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SVG 경로를 그리는 CustomPainter
class _ShapePainter extends CustomPainter {
  final String svgPath;
  final Color color;

  _ShapePainter({
    required this.svgPath,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
      
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final path = Path();
    
    // SVG 경로를 100x100 좌표계에서 실제 사이즈로 스케일링
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    
    // SVG 경로 파싱 (간단한 구현)
    final commands = svgPath.split(' ');
    var i = 0;
    while (i < commands.length) {
      switch (commands[i]) {
        case 'M':
          path.moveTo(
            double.parse(commands[i + 1]) * scaleX,
            double.parse(commands[i + 2]) * scaleY,
          );
          i += 3;
          break;
        case 'L':
          path.lineTo(
            double.parse(commands[i + 1]) * scaleX,
            double.parse(commands[i + 2]) * scaleY,
          );
          i += 3;
          break;
        case 'A':
          // 간단한 arc 구현
          final rx = double.parse(commands[i + 1]) * scaleX;
          final ry = double.parse(commands[i + 2]) * scaleY;
          final endX = double.parse(commands[i + 6]) * scaleX;
          final endY = double.parse(commands[i + 7]) * scaleY;
          path.arcToPoint(
            Offset(endX, endY),
            radius: Radius.elliptical(rx, ry),
            largeArc: commands[i + 4] == '1',
            clockwise: commands[i + 5] == '1',
          );
          i += 8;
          break;
        case 'Z':
          path.close();
          i++;
          break;
        default:
          i++;
      }
    }
    
    // 먼저 연한 회색으로 채우기
    canvas.drawPath(path, fillPaint);
    // 그 다음 테두리 그리기
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) {
    return oldDelegate.svgPath != svgPath || oldDelegate.color != color;
  }
}