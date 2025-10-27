import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/theme.dart';

/// 카메라 정보 페이지 (약품 촬영 방법 안내)
/// 전체 화면으로 표시되는 상세 가이드
class CameraInfoPage extends StatefulWidget {
  const CameraInfoPage({super.key});

  @override
  State<CameraInfoPage> createState() => _CameraInfoPageState();
}

class _CameraInfoPageState extends State<CameraInfoPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    '촬영 가이드',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48), // 아이콘 버튼 크기 맞추기
                ],
              ),
            ),
            
            // 페이지 뷰
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSinglePillGuide(),
                  _buildMultiPillGuide(),
                  _buildTipsPage(),
                ],
              ),
            ),
            
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? AppColors.primary 
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    _currentPage < 2 ? '다음' : '촬영 시작하기',
                    style: const TextStyle(
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
    );
  }
  
  Widget _buildSinglePillGuide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // 제목
          Text(
            '단일 약품 촬영',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            '한 알의 약을 정확하게 촬영하는 방법',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 이미지 영역
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 그리드
                _buildGridPattern(),
                
                // 중앙 원형 가이드
                Container(
                  width: 120,
                  height: 120,
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
                      size: 40,
                    ),
                  ),
                ),
                
                // 안내 텍스트
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '원 안에 약품을 배치하세요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 체크리스트
          _buildCheckList([
            '약품을 화면 중앙에 배치',
            '카메라를 수직으로 들기',
            '밝은 조명 확보',
            '초점을 정확히 맞추기',
          ]),
        ],
      ),
    );
  }
  
  Widget _buildMultiPillGuide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // 제목
          Text(
            '여러 약품 촬영',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            '최대 2개의 약을 동시에 촬영하는 방법',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 이미지 영역
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 그리드
                _buildGridPattern(),
                
                // 중앙 구분선
                Container(
                  width: 2,
                  height: 200,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                
                // 좌우 원형 가이드
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleGuide(),
                    _buildCircleGuide(),
                  ],
                ),
                
                // 안내 텍스트
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '좌우에 하나씩 배치하세요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 체크리스트
          _buildCheckList([
            '두 약품을 좌우로 분리',
            '약품이 겹치지 않게 배치',
            '각인이 위를 향하도록',
            '충분한 간격 유지',
          ]),
        ],
      ),
    );
  }
  
  Widget _buildTipsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 제목
          Text(
            '촬영 팁',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            '더 정확한 식별을 위한 꿀팁',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 팁 카드들
          _buildTipCard(
            Icons.wb_sunny_outlined,
            '밝은 조명',
            '자연광이나 밝은 실내 조명 아래에서 촬영하면 인식률이 높아집니다.',
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildTipCard(
            Icons.center_focus_strong,
            '정확한 초점',
            '약품의 각인이 선명하게 보이도록 초점을 맞춰주세요.',
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildTipCard(
            Icons.straighten,
            '적절한 거리',
            '약품에서 10-15cm 정도 떨어진 위치에서 촬영하세요.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridPattern() {
    return CustomPaint(
      size: const Size(double.infinity, 250),
      painter: GridPainter(),
    );
  }
  
  Widget _buildCircleGuide() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }
  
  Widget _buildCheckList(List<String> items) {
    return Column(
      children: items.map((item) => _buildCheckItem(item)).toList(),
    );
  }
  
  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 그리드 패인터
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    const gridSize = 30.0;
    
    // 세로선
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // 가로선
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}