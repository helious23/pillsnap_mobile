import 'package:flutter/material.dart';
import '../../theme.dart';
import '../common/primary_button.dart';

class GuideDialog extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> checkList;
  final VoidCallback onStart;

  const GuideDialog({
    super.key,
    required this.title,
    required this.imagePath,
    required this.checkList,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // 이미지
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // 체크리스트
            ...checkList.map((item) => _CheckListItem(text: item)),
            const SizedBox(height: AppSpacing.xxl),
            // 시작 버튼
            PrimaryButton(
              text: '촬영 시작하기',
              onPressed: () {
                Navigator.of(context).pop();
                onStart();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckListItem extends StatelessWidget {
  final String text;

  const _CheckListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
}