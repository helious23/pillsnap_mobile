import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 다중 약품 촬영 모드 준비중 다이얼로그
class MultiModeUnavailableDialog extends StatefulWidget {
  const MultiModeUnavailableDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const MultiModeUnavailableDialog(),
    );
  }

  @override
  State<MultiModeUnavailableDialog> createState() => _MultiModeUnavailableDialogState();
}

class _MultiModeUnavailableDialogState extends State<MultiModeUnavailableDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 아이콘 컨테이너
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 배경 펄스 애니메이션
                            TweenAnimationBuilder<double>(
                              duration: const Duration(seconds: 2),
                              tween: Tween(begin: 0.8, end: 1.0),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 65,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(32.5),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // 메인 아이콘 - 여러 개의 약 표현
                            Stack(
                              children: [
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.medication,
                                    size: 24,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.medication,
                                    size: 24,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 16,
                                  right: 16,
                                  child: Icon(
                                    Icons.medication,
                                    size: 24,
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // 제목
                      Text(
                        '다중 약품 촬영',
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xs),
                      
                      // 준비중 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '준비중',
                              style: AppTextStyles.body2.copyWith(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // 설명
                      Text(
                        '여러 개의 약품을 한 번에 촬영하여\n식별하는 기능을 준비하고 있습니다',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // 기능 소개 카드
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '곧 만나볼 수 있는 기능',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildFeatureItem(
                              Icons.photo_camera,
                              '한 번의 촬영으로 여러 약품 인식',
                            ),
                            _buildFeatureItem(
                              Icons.check_circle_outline,
                              '빠르고 정확한 동시 식별',
                            ),
                            _buildFeatureItem(
                              Icons.format_list_bulleted,
                              '약품별 개별 결과 확인',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // 알림 받기 옵션 (버튼들 위에 배치)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            // 알림 설정으로 이동
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('출시 알림이 설정되었습니다'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 18,
                          ),
                          label: Text(
                            '출시 시 알림 받기',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // 버튼들
                      Row(
                        children: [
                          // 단일 촬영 버튼 - 주요 액션
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, 'single');
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 18,
                              ),
                              label: Text(
                                '단일 촬영으로 계속',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: AppSpacing.sm),
                          
                          // 닫기 버튼 - 보조 액션
                          Expanded(
                            flex: 2,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '닫기',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}