import 'package:flutter/material.dart';

/// 카메라 오버레이 (십자선)
class CameraOverlay extends StatelessWidget {
  final bool isMultiMode;
  final int pillCount;
  
  const CameraOverlay({
    super.key,
    this.isMultiMode = false,
    this.pillCount = 2,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _CrosshairPainter(
            isMultiMode: isMultiMode,
            pillCount: pillCount,
          ),
        ),
        // 안내 텍스트와 반투명 박스를 함께 (카메라 프리뷰 영역 하단)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMultiMode 
                    ? '약품 $pillCount개를 각 영역에 배치하세요'
                    : '약품을 화면 중앙에 위치시켜주세요',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final bool isMultiMode;
  final int pillCount;
  
  _CrosshairPainter({
    required this.isMultiMode,
    this.pillCount = 2,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.15; // 화면 너비의 15%
    
    if (isMultiMode) {
      // 여러 약품 모드
      final halfWidth = size.width / 2;
      final halfHeight = size.height / 2;
      final smallRadius = size.width * 0.15;
      
      if (pillCount == 2) {
        // 2개 - 양분
        canvas.drawLine(
          Offset(halfWidth, size.height * 0.2),
          Offset(halfWidth, size.height * 0.8),
          paint,
        );
        
        final positions = [
          Offset(halfWidth / 2, halfHeight),
          Offset(halfWidth * 1.5, halfHeight),
        ];
        
        for (final pos in positions) {
          // 원형 가이드 추가
          canvas.drawCircle(pos, smallRadius * 0.7, paint);
          // 십자선 추가
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
          // 코너 가이드
          _drawCorners(canvas, pos, smallRadius, paint);
        }
      } else if (pillCount == 3) {
        // 3개 - 120도씩 3분할
        // 정확한 120도 Y형 분할선
        final centerY = size.height * 0.5;
        final lineLength = size.width * 0.4;
        
        // 아래쪽 선 (수직)
        canvas.drawLine(
          Offset(halfWidth, centerY),
          Offset(halfWidth, size.height * 0.8),
          paint,
        );
        
        // 왼쪽 위 선 (120도)
        final leftEndX = halfWidth - lineLength * 0.866; // cos(30도) = 0.866
        final leftEndY = centerY - lineLength * 0.5; // sin(30도) = 0.5
        canvas.drawLine(
          Offset(halfWidth, centerY),
          Offset(leftEndX, leftEndY),
          paint,
        );
        
        // 오른쪽 위 선 (120도)
        final rightEndX = halfWidth + lineLength * 0.866;
        final rightEndY = centerY - lineLength * 0.5;
        canvas.drawLine(
          Offset(halfWidth, centerY),
          Offset(rightEndX, rightEndY),
          paint,
        );
        
        // 각 영역의 중심점 계산 - 간격 더 넓게
        final positions = [
          Offset(halfWidth, centerY - size.height * 0.25), // 상단 영역 중심 (더 위로)
          Offset(halfWidth - size.width * 0.25, centerY + size.height * 0.18), // 좌하 영역 중심 (더 옆으로)
          Offset(halfWidth + size.width * 0.25, centerY + size.height * 0.18), // 우하 영역 중심 (더 옆으로)
        ];
        
        // 더 작은 가이드로 간격 확보
        final smallerRadius = smallRadius * 0.8;
        
        for (final pos in positions) {
          // 원형 가이드 추가
          canvas.drawCircle(pos, smallerRadius * 0.7, paint);
          // 십자선 추가
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
          // 코너 가이드
          _drawCorners(canvas, pos, smallerRadius, paint);
        }
      } else {
        // 4개 - 4분할 (기본값)
        // 중앙 십자선
        canvas.drawLine(
          Offset(0, halfHeight),
          Offset(size.width, halfHeight),
          paint,
        );
        canvas.drawLine(
          Offset(halfWidth, size.height * 0.2),
          Offset(halfWidth, size.height * 0.8),
          paint,
        );
        
        // 4개 영역 표시
        final positions = [
          Offset(halfWidth / 2, halfHeight / 2),
          Offset(halfWidth * 1.5, halfHeight / 2),
          Offset(halfWidth / 2, halfHeight * 1.5),
          Offset(halfWidth * 1.5, halfHeight * 1.5),
        ];
        
        for (final pos in positions) {
          // 원형 가이드 추가
          canvas.drawCircle(pos, smallRadius * 0.7, paint);
          // 십자선 추가
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
          // 코너 가이드
          _drawCorners(canvas, pos, smallRadius, paint);
        }
      }
    } else {
      // 단일 약품 모드 - 중앙 원
      canvas.drawCircle(center, radius, paint);
      
      // 중앙 십자선
      canvas.drawLine(
        Offset(center.dx - 20, center.dy),
        Offset(center.dx + 20, center.dy),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - 20),
        Offset(center.dx, center.dy + 20),
        paint,
      );
      
      // 코너 마크 - 화면 크기에 비례하는 고정 크기
      final cornerRadius = size.width * 0.25; // 코너 마크용 별도 크기
      _drawCorners(canvas, center, cornerRadius, paint);
    }
  }
  
  void _drawCorners(Canvas canvas, Offset center, double radius, Paint paint) {
    const cornerLength = 30.0;
    
    // 좌상단
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius + cornerLength, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius, center.dy - radius + cornerLength),
      paint,
    );
    
    // 우상단
    canvas.drawLine(
      Offset(center.dx + radius - cornerLength, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius + cornerLength),
      paint,
    );
    
    // 좌하단
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius - cornerLength),
      Offset(center.dx - radius, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius),
      Offset(center.dx - radius + cornerLength, center.dy + radius),
      paint,
    );
    
    // 우하단
    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius - cornerLength),
      Offset(center.dx + radius, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius - cornerLength, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}