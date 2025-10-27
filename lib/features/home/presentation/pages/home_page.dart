import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/home/presentation/widgets/capture_card.dart';
import 'package:pillsnap/features/home/presentation/widgets/recent_capture_item.dart';
import 'package:pillsnap/features/home/presentation/controllers/home_controller.dart';
import 'package:pillsnap/features/camera/presentation/widgets/multi_mode_unavailable_dialog.dart';

/// 홈 페이지
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentCaptures = ref.watch(recentCapturesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PillSnap',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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

              const SizedBox(height: AppSpacing.md),

              // 캡처 카드들
              CaptureCard(
                title: '단일 약품 촬영',
                subtitle: '하나의 약품을 정확하게',
                description: '가장 정확한 식별 결과를 제공합니다',
                icon: Icons.camera_alt_rounded,
                large: true,
                onTap: () {
                  // 약품 식별 정보 수집 플로우로 이동
                  debugPrint('🔴 [HOME] 단일 약품 촬영 클릭');
                  debugPrint('🔴 [HOME] 이동할 경로: ${RoutePaths.drugIdentification}');
                  context.push(RoutePaths.drugIdentification);
                  debugPrint('🔴 [HOME] push 완료');
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
                onTap: () async {
                  // 다중 모드 준비중 팝업 표시
                  final result = await MultiModeUnavailableDialog.show(context);
                  if (result == 'single' && context.mounted) {
                    // 단일 촬영으로 이동 (약품 식별 플로우)
                    await context.push(RoutePaths.drugIdentification);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // 최근 촬영 섹션
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '최근 촬영',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: 전체보기
                          },
                          child: Text(
                            '전체보기',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 최근 촬영 목록
                    recentCaptures.when(
                      data: (captures) {
                        if (captures.isEmpty) {
                          return _buildEmptyState();
                        }
                        return Column(
                          children: captures.map((capture) {
                            return RecentCaptureItem(
                              drugName: capture.drugName,
                              captureDate: capture.captureDate,
                              imageUrl: capture.imageUrl,
                              onTap: () {
                                // 약품 상세 페이지로 이동
                                context.push('/drug/${capture.id}');
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => _buildEmptyState(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 110), // Bottom navigation 공간 확보
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '아직 촬영한 약품이 없어요',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '약품을 촬영해서 정보를 확인해보세요',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
