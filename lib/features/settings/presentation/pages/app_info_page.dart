import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme.dart';

class AppInfoPage extends ConsumerWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '앱 정보',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 앱 로고
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              
              // 앱 이름 및 버전
              Text(
                'PillSnap',
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0 (MVP)',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Build 2025.09.04',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 정보 카드들
              _buildInfoCard(
                title: '서비스 소개',
                children: [
                  _buildInfoItem(
                    icon: Icons.info_outline,
                    title: 'AI 기반 약품 식별',
                    subtitle: '최신 AI 기술로 정확한 약품 정보를 제공합니다',
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    icon: Icons.security,
                    title: '안전한 정보 관리',
                    subtitle: '개인정보는 안전하게 보호됩니다',
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    icon: Icons.update,
                    title: '지속적인 업데이트',
                    subtitle: '더 나은 서비스를 위해 계속 발전합니다',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 법적 고지
              _buildInfoCard(
                title: '약관 및 정책',
                children: [
                  _buildLinkItem(
                    title: '서비스 이용약관',
                    onTap: () => _showTermsDialog(context, '서비스 이용약관'),
                  ),
                  _buildDivider(),
                  _buildLinkItem(
                    title: '개인정보 처리방침',
                    onTap: () => _showTermsDialog(context, '개인정보 처리방침'),
                  ),
                  _buildDivider(),
                  _buildLinkItem(
                    title: '오픈소스 라이선스',
                    onTap: () => _showLicensesPage(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 지원 및 피드백
              _buildInfoCard(
                title: '지원',
                children: [
                  _buildLinkItem(
                    title: '문의하기',
                    subtitle: 'support@pillsnap.co.kr',
                    onTap: () => _showContactDialog(context),
                  ),
                  _buildDivider(),
                  _buildLinkItem(
                    title: '버그 신고',
                    subtitle: '문제를 발견하셨나요?',
                    onTap: () => _showBugReportDialog(context),
                  ),
                  _buildDivider(),
                  _buildLinkItem(
                    title: '평가하기',
                    subtitle: '앱 스토어에서 평가 남기기',
                    onTap: () => _showRatingDialog(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 저작권
              Text(
                '© 2025 PillSnap. All rights reserved.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // 개발팀
              Text(
                'Made with ❤️ by PillSnap Team',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 100), // 바텀 네비게이션 공간
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLinkItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: AppColors.divider,
    );
  }
  
  void _showTermsDialog(BuildContext context, String title) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              _getDummyTermsText(),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              _getDummyTermsText(),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showLicensesPage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'PillSnap',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
  
  void _showContactDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('문의하기'),
          content: const Text('support@pillsnap.co.kr로\n문의 사항을 보내주세요.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('문의하기'),
          content: const Text('support@pillsnap.co.kr로\n문의 사항을 보내주세요.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showBugReportDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('버그 신고'),
          content: const Text('발견하신 문제를\nsupport@pillsnap.co.kr로 알려주세요.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('버그 신고'),
          content: const Text('발견하신 문제를\nsupport@pillsnap.co.kr로 알려주세요.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showRatingDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('평가하기'),
          content: const Text('앱 스토어에서 평가를 남겨주시면\n더 나은 서비스를 만드는데 큰 도움이 됩니다!'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                // TODO: 앱 스토어로 이동
              },
              child: const Text('평가하기'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('평가하기'),
          content: const Text('앱 스토어에서 평가를 남겨주시면\n더 나은 서비스를 만드는데 큰 도움이 됩니다!'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 앱 스토어로 이동
              },
              child: const Text('평가하기'),
            ),
          ],
        ),
      );
    }
  }
  
  String _getDummyTermsText() {
    return '''본 약관은 PillSnap(이하 "서비스")의 이용에 관한 조건 및 절차를 규정합니다.

제 1조 (목적)
본 약관은 서비스 이용에 관한 조건 및 절차, 이용자와 회사의 권리, 의무 및 책임 사항 등을 규정함을 목적으로 합니다.

제 2조 (정의)
1. "서비스"란 회사가 제공하는 약품 식별 서비스를 의미합니다.
2. "이용자"란 본 약관에 동의하고 서비스를 이용하는 자를 의미합니다.

제 3조 (약관의 효력 및 변경)
1. 본 약관은 서비스 화면에 공지함으로써 효력이 발생합니다.
2. 회사는 필요시 약관을 변경할 수 있으며, 변경된 약관은 공지사항을 통해 공지합니다.

제 4조 (서비스의 제공)
회사는 다음과 같은 서비스를 제공합니다:
- AI 기반 약품 식별
- 약품 정보 제공
- 복약 관리 기능''';
  }
}