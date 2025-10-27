import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import '../providers/signup_provider.dart';

/// 이메일 입력 페이지 (회원가입 1단계)
class EmailInputPage extends ConsumerStatefulWidget {
  const EmailInputPage({super.key});

  @override
  ConsumerState<EmailInputPage> createState() =>
      _EmailInputPageState();
}

class _EmailInputPageState extends ConsumerState<EmailInputPage> {
  final _emailController = TextEditingController();
  bool _isValidEmail = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _emailError;
  bool _hasTriedSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    String? error;

    if (email.isEmpty) {
      if (_hasTriedSubmit) {
        error = '이메일을 입력해주세요';
      }
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      error = '올바른 이메일 형식이 아닙니다';
    }

    setState(() {
      _isValidEmail = email.isNotEmpty && error == null;
      _emailError = error;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,  // 키보드가 나올 때 화면 조정
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '회원가입',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로그레스 바
                Text(
                  '이메일 입력',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProgressBar(1),
                const SizedBox(height: 40),
                // 컨텐츠 카드
                Expanded(
                  child: SingleChildScrollView(  // SingleChildScrollView 추가
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppRadius.lg,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          '이메일을 입력하세요',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '이메일',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: '이메일을 입력하세요',
                            hintStyle: AppTextStyles.body2.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            errorText: _emailError,
                            errorStyle: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              borderSide: _emailError != null
                                  ? const BorderSide(
                                      color: AppColors.error,
                                      width: 1.0,
                                    )
                                  : BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              borderSide: _emailError != null
                                  ? const BorderSide(
                                      color: AppColors.error,
                                      width: 1.0,
                                    )
                                  : BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              borderSide: BorderSide(
                                color: _emailError != null
                                    ? AppColors.error
                                    : AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 1.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 1.5,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 안내 문구
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: AppColors.textTertiary
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '이메일 인증이 필요하니 정확한 이메일을 입력해주세요',
                                  style: AppTextStyles.caption
                                      .copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (_isValidEmail && !_isLoading)
                                ? () async {
                                    setState(() {
                                      _hasTriedSubmit = true;
                                      _isLoading = true;
                                      _errorMessage = null;
                                      _emailError = null;
                                    });

                                    // 이메일 중복 체크는 제거 - Supabase 정책상 불가능
                                    // 대신 비밀번호 설정 페이지에서 실제 회원가입 시 처리
                                    debugPrint('이메일 입력: ${_emailController.text.trim()}');
                                      
                                    // 이메일을 회원가입 플로우 상태에 저장
                                    ref
                                        .read(
                                          signupFlowProvider.notifier,
                                        )
                                        .setEmail(
                                          _emailController.text
                                              .trim(),
                                        );

                                    // 비밀번호 설정 페이지로 이동
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      // ignore: use_build_context_synchronously
                                      await context.push(
                                        RoutePaths.passwordSetup,
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors
                                  .primary
                                  .withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            child: Text(
                              '다음',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                              border: Border.all(
                                color: AppColors.error.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.caption
                                        .copyWith(
                                          color: AppColors.error,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),  // Spacer 대신 고정 높이
                        Center(
                          child: Text(
                            '회원가입을 진행하면 이용약관 및 개인정보처리방침에 동의한\n것으로 간주됩니다.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentStep / 4, // 4단계 중 현재 단계
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
