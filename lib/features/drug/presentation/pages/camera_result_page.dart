import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_result_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/drug_result_card.dart';

/// 카메라 결과 페이지
class CameraResultPage extends ConsumerStatefulWidget {
  const CameraResultPage({super.key});

  @override
  ConsumerState<CameraResultPage> createState() => _CameraResultPageState();
}

class _CameraResultPageState extends ConsumerState<CameraResultPage> {
  @override
  void initState() {
    super.initState();
    // API 결과는 이미 camera_loading_page에서 로드됨
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drugResultProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: Colors.white,
              child: Row(
                children: [
                  // 뒤로가기
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  
                  // 제목
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '검색 결과',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (state.results.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${state.results.length}개의 유사한 의약품을 찾았습니다',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 콘텐츠
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : state.error != null
                      ? _buildError(state.error!)
                      : state.results.isEmpty
                          ? _buildEmpty()
                          : _buildResults(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(DrugResultState state) {
    final topResult = state.results.first;
    final otherResults = state.results.skip(1).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // 최고 유사도 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              '최고 유사도',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          DrugResultCard(
            drug: topResult,
            isTopResult: true,
            onTap: () {
              // 약품 상세 페이지로 이동
              context.push('/drug/${topResult.itemSeq ?? 0}');
            },
          ),
          
          if (otherResults.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            
            // 기타 유사 의약품 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                '기타 유사 의약품',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            ...otherResults.map((drug) => DrugResultCard(
              drug: drug,
              onTap: () {
                // 약품 상세 페이지로 이동
                context.push('/drug/${drug.itemSeq ?? 0}');
              },
            )),
          ],
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 다시 촬영하기 버튼
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // 결과 초기화 후 카메라로 이동
                  ref.read(drugResultProvider.notifier).clearResults();
                  // pop을 사용하여 카메라로 돌아가기
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/camera');
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                  ),
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '다시 촬영하기',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '검색 결과가 없습니다',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '다시 촬영해보세요',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton(
              onPressed: () {
                context.go('/camera');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('다시 촬영하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () {
                // 카메라로 돌아가서 다시 촬영
                context.go('/camera');
              },
              child: const Text('다시 촬영'),
            ),
          ],
        ),
      ),
    );
  }
}