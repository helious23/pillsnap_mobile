import 'package:flutter/material.dart';
import '../theme.dart';

class OnboardingLast extends StatelessWidget {
  const OnboardingLast({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/HOME_SCREEN',
            ),
            child: const Text(
              '건너뛰기',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.info_outline,
                size: 96,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '상세하고 실용적 정보',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/HOME_SCREEN',
                  ),
                  child: const Text(
                    '시작하기',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
