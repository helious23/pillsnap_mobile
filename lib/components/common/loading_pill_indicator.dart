import 'package:flutter/material.dart';
import '../../theme.dart';

class LoadingPillIndicator extends StatefulWidget {
  const LoadingPillIndicator({super.key});

  @override
  State<LoadingPillIndicator> createState() => _LoadingPillIndicatorState();
}

class _LoadingPillIndicatorState extends State<LoadingPillIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pillController;
  late AnimationController _dotsController;
  late Animation<double> _pillAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    
    // 알약 애니메이션
    _pillController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pillAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeInOut,
    ));
    
    // 점 애니메이션
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _dotsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_dotsController);
    
    _pillController.repeat(reverse: true);
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _pillController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 알약 아이콘
        AnimatedBuilder(
          animation: _pillAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_pillAnimation.value, 0),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        // 로딩 점들
        AnimatedBuilder(
          animation: _dotsAnimation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_dotsAnimation.value - delay).clamp(0.0, 1.0);
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: value > 0.5 ? 1.0 : 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}