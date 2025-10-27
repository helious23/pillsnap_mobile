import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          '설정',
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
              const SizedBox(height: 20),
              // 사용자 프로필 카드
              _buildProfileCard(context, profileAsync, currentUser),
              const SizedBox(height: 16),
              // 설정 메뉴 카드
              _buildSettingsCard(context),
              const SizedBox(height: 32),
              // 로그아웃 버튼
              _buildLogoutButton(context, ref),
              const SizedBox(height: 24),
              // 앱 버전 정보
              _buildVersionInfo(),
              const SizedBox(height: 100), // 바텀 네비게이션 공간
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AsyncValue<Profile?> profileAsync, supa.User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
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
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // 사용자 정보
          Expanded(
            child: profileAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              error: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사용자',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '정보를 불러올 수 없습니다',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              data: (profile) {
                final displayName = profile?.displayName ?? '사용자';
                final email = profile?.email ?? currentUser?.email ?? '이메일 없음';
                
                // 가입일 포맷팅 (created_at from user metadata or profile)
                String joinDate = '가입일: -';
                if (currentUser?.createdAt != null) {
                  final date = DateTime.parse(currentUser!.createdAt);
                  joinDate = '가입일: ${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
                } else if (profile?.createdAt != null) {
                  final date = profile!.createdAt;
                  joinDate = '가입일: ${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      joinDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.person_outline,
            iconColor: AppColors.primary,
            title: '프로필',
            subtitle: '계정 정보 및 개인설정',
            onTap: () {
              context.push('/settings/profile');
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.history,
            iconColor: AppColors.primary,
            title: '촬영 내역',
            subtitle: '촬영한 약품 기록 조회',
            onTap: () {
              context.push('/settings/history');
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info_outline,
            iconColor: AppColors.primary,
            title: '앱 정보',
            subtitle: '버전 정보 및 이용약관',
            onTap: () {
              context.push('/settings/info');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // 로그아웃 확인 다이얼로그
          showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('로그아웃'),
              content: const Text('정말 로그아웃 하시겠습니까?'),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: false,
                  child: const Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('로그아웃'),
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    try {
                      // Supabase 로그아웃
                      await ref.read(authControllerProvider.notifier).signOut();
                      
                      // 로그인 페이지로 이동
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    } catch (e) {
                      // 로그아웃 실패 시 에러 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('로그아웃 실패: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '로그아웃',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'PillSnap v1.0.0 (MVP)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2025 PillSnap. All rights reserved.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}