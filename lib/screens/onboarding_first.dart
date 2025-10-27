import 'package:flutter/material.dart';
import '../theme.dart';

class OnboardingFirst extends StatelessWidget {
  const OnboardingFirst({super.key});

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
                Icons.camera_alt,
                size: 96,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '사진 한 장으로 빠른 확인',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/ONBOARDING_SECOND',
                  ),
                  child: const Text(
                    '다음',
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
