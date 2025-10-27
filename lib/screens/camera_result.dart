// TODO: wire real data
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../components/common/pill_app_bar.dart';
import '../components/cards/result_item_card.dart';
import '../components/common/outlined_button.dart';

class CameraResult extends StatelessWidget {
  const CameraResult({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final topResult = {
      'name': '타이레놀정 500mg',
      'manufacturer': '한국얀센',
      'accuracy': 92,
      'image': '',
    };

    final otherResults = [
      {
        'name': '게보린정',
        'manufacturer': '삼진제약',
        'accuracy': 78,
        'image': '',
      },
      {
        'name': '부루펜정 400mg',
        'manufacturer': '한미약품',
        'accuracy': 65,
        'image': '',
      },
      {
        'name': '아스피린정 100mg',
        'manufacturer': '바이엘코리아',
        'accuracy': 52,
        'image': '',
      },
      {
        'name': '판피린정',
        'manufacturer': '동아제약',
        'accuracy': 41,
        'image': '',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PillAppBar(
        showBack: true,
        showLogo: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서브헤딩
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Text(
                '유사한 의약품 5개를 찾았습니다',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // 최고 유사도 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                '최고 유사도',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ResultItemCard(
              imageUrl: topResult['image'] as String,
              drugName: topResult['name'] as String,
              manufacturer: topResult['manufacturer'] as String,
              accuracy: topResult['accuracy'] as int,
              showBadge: true,
              onTap: () {
                Navigator.pushNamed(context, '/DRUG_DETAIL');
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            // 기타 유사 의약품 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                '기타 유사 의약품',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...otherResults.map((drug) => ResultItemCard(
              imageUrl: drug['image'] as String,
              drugName: drug['name'] as String,
              manufacturer: drug['manufacturer'] as String,
              accuracy: drug['accuracy'] as int,
              onTap: () {
                Navigator.pushNamed(context, '/DRUG_DETAIL');
              },
            )),
            const SizedBox(height: AppSpacing.xxl),
            // 다시 촬영하기 버튼
            AppOutlinedButton(
              text: '다시 촬영하기',
              onPressed: () {
                // go_router로 카메라 화면으로 돌아가기
                context.go('/camera');
              },
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}