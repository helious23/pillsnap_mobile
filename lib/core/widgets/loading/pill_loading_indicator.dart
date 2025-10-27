import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pillsnap/theme.dart';

/// 알약 모양 로딩 인디케이터
/// 360도 회전하며 내부 패턴은 반대로 회전
class PillLoadingIndicator extends StatefulWidget {
  final String? message;
  final String? subMessage;
  final Duration duration;
  
  const PillLoadingIndicator({
    super.key,
    this.message = '분석 중...',
    this.subMessage = '의약품을 식별하고 있습니다',
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<PillLoadingIndicator> createState() => _PillLoadingIndicatorState();
}

class _PillLoadingIndicatorState extends State<PillLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pillRotationController;
  late AnimationController _patternRotationController;
  late AnimationController _dotsAnimationController;
  late Animation<double> _pillRotation;
  late Animation<double> _patternRotation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    
    // 알약 회전 애니메이션 (시계방향)
    _pillRotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pillRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _pillRotationController,
      curve: Curves.linear,
    ));
    
    // 패턴 회전 애니메이션 (반시계방향)
    _patternRotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _patternRotation = Tween<double>(
      begin: 0,
      end: -2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _patternRotationController,
      curve: Curves.linear,
    ));
    
    // 점 애니메이션
    _dotsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _dotsAnimation = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(CurvedAnimation(
      parent: _dotsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pillRotationController.dispose();
    _patternRotationController.dispose();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 알약 애니메이션
            SizedBox(
              width: 120,
              height: 120,
              child: AnimatedBuilder(
                animation: Listenable.merge([_pillRotation, _patternRotation]),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _pillRotation.value,
                    child: CustomPaint(
                      painter: PillPainter(
                        patternAngle: _patternRotation.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // 메시지
            if (widget.message != null)
              Text(
                widget.message!,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            
            if (widget.subMessage != null)
              Text(
                widget.subMessage!,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.xl),
            
            // 애니메이션 점들
            AnimatedBuilder(
              animation: _dotsAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final dotIndex = _dotsAnimation.value.floor() % 3;
                    final isActive = index == dotIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 12 : 8,
                      height: isActive ? 12 : 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 알약 모양 커스텀 페인터
class PillPainter extends CustomPainter {
  final double patternAngle;
  
  PillPainter({required this.patternAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    // 알약 외곽선 그리기
    final pillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // 그림자
    final shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(0, 2), width: radius * 2, height: radius),
        Radius.circular(radius / 2),
      ));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // 알약 본체
    final pillPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 2, height: radius),
        Radius.circular(radius / 2),
      ));
    canvas.drawPath(pillPath, pillPaint);
    
    // 중앙선
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(center.dx - radius + 10, center.dy),
      Offset(center.dx + radius - 10, center.dy),
      linePaint,
    );
    
    // 내부 패턴 (회전하는 원형 패턴)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(patternAngle);
    
    // 패턴 그리기
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    // 작은 원들로 패턴 생성
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2) * i;
      final x = math.cos(angle) * radius * 0.5;
      final y = math.sin(angle) * radius * 0.3;
      canvas.drawCircle(Offset(x, y), 8, patternPaint);
    }
    
    // 중앙 원
    canvas.drawCircle(Offset.zero, 6, patternPaint);
    
    canvas.restore();
    
    // 하이라이트 효과
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(center: center, width: radius * 2, height: radius))
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 1.5, height: radius * 0.7),
        Radius.circular(radius / 2),
      ));
    
    canvas.save();
    canvas.clipPath(pillPath);
    canvas.drawPath(highlightPath, highlightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PillPainter oldDelegate) {
    return oldDelegate.patternAngle != patternAngle;
  }
}