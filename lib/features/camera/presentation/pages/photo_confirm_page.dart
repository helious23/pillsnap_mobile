import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 사진 확인 페이지
class PhotoConfirmPage extends ConsumerWidget {
  final String imagePath;
  final String? roiPath;  // ROI 이미지 경로 추가
  final bool isMultiMode;
  
  const PhotoConfirmPage({
    super.key,
    required this.imagePath,
    this.roiPath,
    this.isMultiMode = false,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identificationData = ref.watch(drugIdentificationProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Text(
                        '사진 확인',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 48), // 균형을 위한 빈 공간
                    ],
                  ),
                  // 식별 정보가 있을 때 정확도 표시
                  if (identificationData.completionScore > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: identificationData.estimatedAccuracy >= 80
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '예상 정확도: ${identificationData.estimatedAccuracy}%',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (identificationData.text != null && identificationData.text!.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                Icons.text_fields,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  identificationData.text!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 이미지 미리보기
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '이미지를 불러올 수 없습니다',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // 안내 메시지
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                '약품이 선명하게 보이나요?',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 버튼
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // 다시 찍기 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 카메라 화면으로 돌아가기
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '다시 찍기',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // 전송 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 로딩 화면으로 이동 (ROI 경로도 함께 전달)
                        final mode = isMultiMode ? 'multi' : 'single';
                        final queryParams = 'path=$imagePath&mode=$mode${roiPath != null ? '&roi=$roiPath' : ''}';
                        context.pushReplacement('/camera/loading?$queryParams');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.send,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '분석하기',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}