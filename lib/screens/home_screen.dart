// TODO: wire real data
import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/common/pill_app_bar.dart';
import '../components/cards/capture_card.dart';
import '../components/bottom_nav/curved_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == 1) {
      // 카메라 버튼 - 약품 식별 정보 수집 플로우로 이동
      Navigator.pushNamed(context, '/drug/identification');
    } else if (index == 2) {
      // 설정 버튼
      Navigator.pushNamed(context, '/SETTING_SCREEN');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PillAppBar(
        showLogo: true,
        showSettings: true,
        onSettingsTap: () {
          Navigator.pushNamed(context, '/SETTING_SCREEN');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서브헤딩
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사진 한 장으로 의약품을 식별하는',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '현직 약사 검증 AI서비스',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // 캡처 카드들
            CaptureCard(
              title: '단일 약품 촬영',
              subtitle: '하나의 약품을 정확하게',
              description: '가장 정확한 식별 결과를 제공합니다',
              icon: Icons.camera_alt_rounded,
              large: true,
              onTap: () {
                Navigator.pushNamed(context, '/drug/identification');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CaptureCard(
              title: '여러 약품 촬영',
              subtitle: '최대 4개까지 한 번에',
              description: '참고용으로 활용하세요',
              icon: Icons.photo_library_rounded,
              isDark: true,
              showInfoTooltip: true,
              onTap: () {
                Navigator.pushNamed(context, '/CAMERA_SCREEN');
              },
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // 최근 촬영 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 촬영',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // 추가 버튼
                        _RecentItem(
                          isAddButton: true,
                          onTap: () {
                            Navigator.pushNamed(context, '/drug/identification');
                          },
                        ),
                        // 더미 최근 항목들
                        _RecentItem(
                          imagePath: 'assets/00.Intro.png',
                          onTap: () {},
                        ),
                        _RecentItem(
                          imagePath: 'assets/00.Intro.png',
                          onTap: () {},
                        ),
                        _RecentItem(
                          imagePath: 'assets/00.Intro.png',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // 하단 네비게이션 공간
          ],
        ),
      ),
      bottomNavigationBar: CurvedNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String? imagePath;
  final bool isAddButton;
  final VoidCallback onTap;

  const _RecentItem({
    this.imagePath,
    this.isAddButton = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: isAddButton ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isAddButton
              ? Border.all(
                  color: AppColors.border,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                )
              : null,
        ),
        child: isAddButton
            ? const Icon(
                Icons.add_rounded,
                size: 32,
                color: AppColors.textTertiary,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: imagePath != null
                    ? Image.asset(
                        imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.medication,
                              size: 32,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.medication,
                          size: 32,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
      ),
    );
  }
}