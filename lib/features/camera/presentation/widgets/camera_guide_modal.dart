import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 카메라 촬영 가이드 모달
class CameraGuideModal extends StatelessWidget {
  final bool isMultiMode;

  const CameraGuideModal({super.key, required this.isMultiMode});

  void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: Navigator.of(context),
      ),
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // 제목
                  Text(
                    isMultiMode ? '여러 약품 촬영 방법' : '단일 약품 촬영 방법',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 부제목
                  Text(
                    '정확한 식별을 위한 촬영 가이드',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 이미지 영역
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // TODO: 실제 가이드 이미지로 교체 예정
                                // 예시:
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(12),
                                //   child: Image.asset(
                                //     isMultiMode
                                //       ? 'assets/guide/multi_guide.png'
                                //       : 'assets/guide/single_guide.png',
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),

                                // 임시 배경 그리드 패턴 (알약 블리스터 팩 표현)
                                CustomPaint(
                                  size: const Size(
                                    double.infinity,
                                    200,
                                  ),
                                  painter: _BlisterPackPainter(),
                                ),

                                // 가이드 오버레이
                                if (isMultiMode)
                                  CustomPaint(
                                    size: const Size(
                                      double.infinity,
                                      200,
                                    ),
                                    painter:
                                        _MultiGuideOverlayPainter(),
                                  )
                                else
                                  Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: AppColors.primary,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // 체크리스트 제목
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '촬영 체크리스트',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 체크리스트 아이템
                          if (isMultiMode) ...[
                            _buildCheckItem(
                              '두 약품을 중앙선 좌우에 하나씩 배치해주세요',
                            ),
                            _buildCheckItem(
                              '약품이 서로 겹치지 않도록 충분히 띄워주세요',
                            ),
                            _buildCheckItem(
                              '두 약품 모두 각인이 위를 향하도록 놓아주세요',
                            ),
                            _buildCheckItem(
                              '밝은 조명 아래서 촬영하면 인식률이 높아져요',
                            ),
                          ] else ...[
                            _buildCheckItem('약품을 화면 중앙 원 안에 배치해주세요'),
                            _buildCheckItem('카메라를 약품 위에서 수직으로 들어주세요'),
                            _buildCheckItem('밝은 곳에서 촬영하면 더 정확해요'),
                            _buildCheckItem(
                              '약품의 글씨가 선명히 보이도록 초점을 맞춰주세요',
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),

                  // 촬영 시작 버튼 - 스크롤 영역 밖에 고정
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xxl * 3,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          '촬영 시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 블리스터 팩 패인터 (배경)
class _BlisterPackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const pillWidth = 30.0;
    const pillHeight = 20.0;
    const spacing = 10.0;

    for (
      double y = spacing;
      y < size.height;
      y += pillHeight + spacing
    ) {
      for (
        double x = spacing;
        x < size.width;
        x += pillWidth + spacing
      ) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, pillWidth, pillHeight),
          const Radius.circular(10),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 여러 약품 가이드 오버레이 패인터
class _MultiGuideOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 2개 약품용 가이드 (좌우 분할)
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    // 중앙 세로선
    canvas.drawLine(
      Offset(halfWidth, 20),
      Offset(halfWidth, size.height - 20),
      paint,
    );

    // 각 영역에 원 표시 (좌우 각 1개)
    final positions = [
      Offset(halfWidth / 2, halfHeight), // 왼쪽 영역 중앙
      Offset(halfWidth * 1.5, halfHeight), // 오른쪽 영역 중앙
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 35, paint);
      // 원 내부에 작은 십자선
      canvas.drawLine(
        Offset(pos.dx - 15, pos.dy),
        Offset(pos.dx + 15, pos.dy),
        paint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy - 15),
        Offset(pos.dx, pos.dy + 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
