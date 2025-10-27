import 'package:flutter/material.dart';
import '../../theme.dart';

class CurvedNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CurvedNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // 전체 높이 증가
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 곡선 배경만 따로 그리기
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90, // 곡선 부분 높이 증가
            child: CustomPaint(
              painter: _SimpleCurvedPainter(),
            ),
          ),
          // 네비게이션 버튼들
          Positioned(
            left: 0,
            right: 0,
            top: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 홈 버튼 - 화면 너비의 22% 위치
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: Center(
                    child: _NavButton(
                      icon: Icons.home_rounded,
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                ),
                // 가운데 공간 (FAB 공간) - 화면 너비의 36%
                SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                // 설정 버튼 - 화면 너비의 22% 위치
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: Center(
                    child: _NavButton(
                      icon: Icons.settings_rounded,
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 중앙 카메라 FAB
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 36,
            bottom: 54, // FAB 위치 조정
            child: _CameraFAB(
              onTap: () => onTap(1),
              isSelected: currentIndex == 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CameraFAB extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _CameraFAB({required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.9),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SimpleCurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 곡선 부분만 그리기
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 미묘한 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    
    // 시작점 (왼쪽 하단)
    path.moveTo(0, size.height);
    
    // 왼쪽 수직선 (0부터 시작)
    path.lineTo(0, 0);
    
    // 왼쪽 수평선
    path.lineTo(size.width * 0.35, 0);
    
    // 중앙 곡선 (위로 올라감) - 상대 위치 조정
    path.quadraticBezierTo(
      size.width * 0.40,
      -2,
      size.width * 0.42,
      -10,
    );
    path.quadraticBezierTo(size.width * 0.45, -22, size.width * 0.50, -22);
    path.quadraticBezierTo(size.width * 0.55, -22, size.width * 0.58, -10);
    path.quadraticBezierTo(
      size.width * 0.60,
      -2,
      size.width * 0.65,
      0,
    );
    
    // 오른쪽 수평선
    path.lineTo(size.width, 0);
    
    // 오른쪽 수직선
    path.lineTo(size.width, size.height);
    
    // 하단 수평선 (닫기)
    path.close();

    // 그림자 그리기
    canvas.drawPath(path, shadowPaint);
    // 곡선 배경 그리기
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
