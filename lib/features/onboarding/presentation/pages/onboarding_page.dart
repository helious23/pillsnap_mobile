import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import 'package:pillsnap/features/onboarding/presentation/controllers/onboarding_controller.dart';

/// 온보딩 페이지 (3개 화면 통합)
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = const [
    OnboardingContent(
      icon: Icons.camera_alt_outlined,
      title: '사진 한 장으로 의약품 확인',
      subtitle: '촬영만으로 즉시 의약품 정보를 확인하세요',
    ),
    OnboardingContent(
      icon: Icons.verified_outlined,
      title: '약사 검증 AI 서비스',
      subtitle: 'AI와 함께 약사가 검증한 신뢰할 수 있는 정보',
    ),
    OnboardingContent(
      icon: Icons.description_outlined,
      title: '상세하고 정확한 정보',
      subtitle: '효능 용법 주의사항 등 전문가급 정보 제공',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    debugPrint('🏁 [ONBOARDING] onboarding_completed: false → true 업데이트 시작');
    
    // 온보딩 완료 상태 저장
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    debugPrint('✅ [ONBOARDING] onboarding_completed 업데이트 완료');
    
    // onboardingCompletedProvider 캐시 무효화
    ref.invalidate(onboardingCompletedProvider);
    
    // 짧은 지연을 주어 provider가 업데이트되도록 함
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    // 홈 화면으로 이동 (건너뛰기든 완료든 상관없이)
    if (mounted) {
      debugPrint('🧭 [ONBOARDING] 홈으로 이동');
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PillSnap',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // 건너뛰기 버튼 공간 - 마지막 페이지에서는 투명하게 처리
                    _currentPage < 2
                        ? TextButton(
                            onPressed: _skipOnboarding,
                            child: Text(
                              '건너뛰기',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : const SizedBox(
                            width: 72, // TextButton과 동일한 너비 유지
                            height: 40,
                          ),
                  ],
                ),
              ),
            ),
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
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
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                }),
              ),
            ),
            // 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _buildPage(_contents[index]);
                },
              ),
            ),
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? '시작하기' : '다음',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (_currentPage < 2) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 컨테이너
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              content.icon,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 48),
          // 타이틀
          Text(
            content.title,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 서브타이틀
          Text(
            content.subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 온보딩 콘텐츠 모델
class OnboardingContent {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardingContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}