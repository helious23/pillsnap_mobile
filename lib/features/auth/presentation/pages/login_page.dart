import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import '../providers/auth_provider.dart';

/// 로그인 페이지
class LoginPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  
  const LoginPage({super.key, this.extra});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _hasTriedLogin = false;

  @override
  void initState() {
    super.initState();
    debugPrint('LoginPage initState - extra: ${widget.extra}');
    
    // 전달된 이메일이 있으면 설정
    if (widget.extra != null && widget.extra!['email'] != null) {
      final email = widget.extra!['email'] as String;
      debugPrint('이메일 자동 입력: $email');
      _emailController.text = email;
      // 비밀번호는 항상 비우기
      _passwordController.clear();
    } else {
      debugPrint('extra가 없음 - 모든 필드 비우기');
      // extra가 없으면 모든 필드 비우기
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    setState(() {
      _hasTriedLogin = true;
      _emailError = null;
      _passwordError = null;
    });

    // 이메일 검증
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = '이메일을 입력하세요';
      });
      return;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailError = '올바른 이메일 형식이 아닙니다';
      });
      return;
    }

    // 비밀번호 검증
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = '비밀번호를 입력하세요';
      });
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = '비밀번호는 8자 이상이어야 합니다';
      });
      return;
    }
    // Supabase 비밀번호 요구사항: 대문자, 소문자, 숫자, 특수문자 모두 포함
    final password = _passwordController.text;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!hasUppercase ||
        !hasLowercase ||
        !hasDigit ||
        !hasSpecialChar) {
      setState(() {
        _passwordError = '비밀번호는 대문자, 소문자, 숫자, 특수문자를 모두 포함해야 합니다';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 바로 로그인 시도
      await ref
          .read(authControllerProvider.notifier)
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // 로그인 성공 시 프로필 완료 여부에 따라 이동
      if (mounted) {
        // 프로필 완료 여부 체크
        final profileRepo = ref.read(profileRepositoryProvider);
        final profile = await profileRepo.fetchMyProfile();
        
        if (profile != null && profile.profileCompleted) {
          // 프로필이 완료된 경우 - 온보딩 체크
          final prefs = await SharedPreferences.getInstance();
          final onboardingDone = prefs.getBool('onboarding_completed') ?? false;
          
          if (mounted) {
            if (!onboardingDone) {
              context.go(RoutePaths.onboarding);
            } else {
              context.go(RoutePaths.home);
            }
          }
        } else {
          // 프로필이 미완료인 경우
          if (mounted) {
            context.go(RoutePaths.profileSetup);
          }
        }
      }
    } catch (e) {
      // 에러 처리
      debugPrint('=== 로그인 에러 발생 ===');
      debugPrint('에러 타입: ${e.runtimeType}');
      debugPrint('에러 메시지: $e');
      if (mounted) {
        String errorMessage = '';
        final errorString = e.toString().toLowerCase();
        final originalError = e.toString();
        debugPrint('원본 에러: $originalError');
        debugPrint('소문자 변환 에러: $errorString');
        
        // 이메일 인증 관련 에러 (원본과 소문자 둘 다 체크)
        debugPrint('원본 체크: originalError.contains("이메일 인증이 필요") = ${originalError.contains('이메일 인증이 필요')}');
        debugPrint('소문자 체크: errorString.contains("이메일 인증이 필요") = ${errorString.contains('이메일 인증이 필요')}');
        
        if (errorString.contains('email not confirmed') ||
            originalError.contains('이메일 인증이 필요') ||
            errorString.contains('이메일 확인') ||
            errorString.contains('확인메일')) {
          debugPrint('>>> 이메일 인증 필요 감지 - 페이지 이동 시작 <<<');
          errorMessage = '이메일 인증을 완료해주세요';
          
          // 토스트 제거 - 이메일 인증 페이지에서 표시할 것임
          
          // 이메일 인증 페이지로 이동
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              debugPrint('🧭 [LOGIN] 이메일 인증 페이지로 이동 - email: ${_emailController.text}');
              context.push(
                RoutePaths.emailConfirmation,
                extra: {
                  'email': _emailController.text,
                  'password': _passwordController.text,
                  'isResend': true,
                },
              );
            }
          });
          return;
        }
        
        // Invalid login credentials - 이메일 또는 비밀번호 오류
        else if (errorString.contains('invalid login credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다';
          
          // 이메일이 실제로 존재하는지 체크 시도
          // 비밀번호 필드에만 에러 표시 (실제로는 이메일이 없을 수도 있지만 보안상 비밀번호 에러처럼 표시)
          setState(() {
            _emailError = null;  
            _passwordError = '비밀번호를 확인해주세요';
          });
        }
        
        // 에러 메시지가 있을 때만 스낵바 표시
        if (errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 20,
              left: 20,
              right: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테스트 계정으로 빠른 로그인
  void _fillTestAccount() {
    _emailController.text = 'max16@naver.com';
    _passwordController.text = 'Password123!';
  }

  @override
  Widget build(BuildContext context) {
    // 인증 상태 감시
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,  // 키보드가 나올 때 화면 조정
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Spacer(flex: 1),
                  // 앱 타이틀
                  Text(
                    'PillSnap',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 서브타이틀
                  Text(
                    '의약품 식별의 새로운 기준',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI와 함께 약사가 검증',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 로그인 섹션
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '로그인',
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // 테스트 계정 버튼 (개발 중에만)
                            if (const bool.fromEnvironment(
                              'DEBUG',
                              defaultValue: true,
                            ))
                              TextButton(
                                onPressed: _fillTestAccount,
                                child: Text(
                                  '테스트 계정',
                                  style: AppTextStyles.caption
                                      .copyWith(
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 이메일 입력
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        // 비밀번호 입력
                        _buildPasswordField(),
                        const SizedBox(height: 24),
                        // 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors
                                  .primary
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            child: Text(
                              '로그인',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 비밀번호 찾기
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: 비밀번호 재설정 페이지로 이동
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    '비밀번호 재설정 기능은 준비 중입니다',
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                    left: 20,
                                    right: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '비밀번호를 잊으셨나요?',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 회원가입 링크
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '계정이 없으신가요?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(RoutePaths.emailInput);
                        },
                        child: Text(
                          '회원가입',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 이메일 입력 필드
  Widget _buildEmailField() {
    final hasError = _emailError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이메일',
          style: AppTextStyles.caption.copyWith(
            color: hasError
                ? AppColors.error
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_hasTriedLogin && _emailError != null && _emailError!.isNotEmpty) {
              setState(() {
                _emailError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: '이메일을 입력하세요',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: _emailError,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : Colors.transparent,
                width: hasError ? 1.0 : 0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : Colors.transparent,
                width: hasError ? 1.0 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// 비밀번호 입력 필드
  Widget _buildPasswordField() {
    final hasError = _passwordError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호',
          style: AppTextStyles.caption.copyWith(
            color: hasError
                ? AppColors.error
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          autocorrect: false,
          enabled: !_isLoading,
          onChanged: (_) {
            if (_hasTriedLogin && _passwordError != null && _passwordError!.isNotEmpty) {
              setState(() {
                _passwordError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: '비밀번호를 입력하세요',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: _passwordError,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : Colors.transparent,
                width: hasError ? 1.0 : 0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : Colors.transparent,
                width: hasError ? 1.0 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textTertiary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textTertiary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
