import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/signup_provider.dart';

/// 비밀번호 설정 페이지 (회원가입 2단계)
class PasswordSetupPage extends ConsumerStatefulWidget {
  const PasswordSetupPage({super.key});

  @override
  ConsumerState<PasswordSetupPage> createState() =>
      _PasswordSetupPageState();
}

class _PasswordSetupPageState
    extends ConsumerState<PasswordSetupPage> with WidgetsBindingObserver {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _signupError;
  bool _isPasswordLocked = false; // 비밀번호 잠금 상태
  // ignore: unused_field
  String? _lockedPassword; // 잠긴 비밀번호 (나중에 사용 예정)
  final FocusNode _pageFocusNode = FocusNode();
  bool _hasCheckedPassword = false; // 비밀번호 체크 완료 플래그

  // 현재 단계 (총 4단계 중 2단계)
  int currentStep = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
    
    // FocusNode 리스너 제거 (무한 루프 방지)
    
    // 비동기로 기존 비밀번호 체크 및 적용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingPassword();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 비밀번호 체크
      _checkExistingPassword();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 표시될 때마다 비밀번호 잠금 상태 확인
    // 플래그 리셋하여 다시 체크하도록
    _hasCheckedPassword = false;
    _checkExistingPassword();
  }

  // SharedPreferences에서 기존 비밀번호 확인
  Future<void> _checkExistingPassword() async {
    // 이미 체크했고 잠금 상태면 중복 체크 방지
    if (_hasCheckedPassword && _isPasswordLocked) {
      debugPrint('🔄 [PWD_SETUP._checkExistingPassword] 이미 체크 완료, 스킵');
      return;
    }
    
    final signupState = ref.read(signupFlowProvider);
    final email = signupState.email;
    
    debugPrint('🔍 [PWD_SETUP._checkExistingPassword] 시작');
    debugPrint('  - email: $email');
    debugPrint('  - _hasCheckedPassword: $_hasCheckedPassword');
    debugPrint('  - _isPasswordLocked: $_isPasswordLocked');
    
    if (email != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // 강제 동기화 - 다른 페이지에서 저장한 값 읽기
      
      // 디버깅: 모든 키 확인
      final allKeys = prefs.getKeys();
      debugPrint('  - SharedPreferences 모든 키: $allKeys');
      
      final existingPassword = prefs.getString('locked_password_$email');
      
      debugPrint('  - locked_password_$email = ${existingPassword != null ? "${existingPassword.length}자" : "없음"}');
      
      if (existingPassword != null && existingPassword.isNotEmpty) {
        // 기존 비밀번호가 있으면 자동 입력 및 잠금
        if (mounted) {
          setState(() {
            _isPasswordLocked = true;
            _lockedPassword = existingPassword;
            // 현재 컨트롤러 값과 다를 때만 업데이트
            if (_passwordController.text != existingPassword) {
              _passwordController.text = existingPassword;
            }
            if (_confirmPasswordController.text != existingPassword) {
              _confirmPasswordController.text = existingPassword;
            }
          });
          _hasCheckedPassword = true; // 체크 완료 표시
        }
        
        debugPrint('🔒 [PWD_SETUP] 비밀번호 잠금 활성화 - ${existingPassword.length}자');
      } else {
        // 잠금 해제 상태 확인
        if (mounted && _isPasswordLocked) {
          setState(() {
            _isPasswordLocked = false;
            _lockedPassword = null;
          });
          debugPrint('🔓 [PWD_SETUP] 비밀번호 잠금 해제');
        } else {
          debugPrint('ℹ️ [PWD_SETUP] 저장된 비밀번호 없음');
        }
      }
    } else {
      debugPrint('⚠️ [PWD_SETUP._checkExistingPassword] email이 null');
    }
  }


  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      _isPasswordValid =
          password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&  // 대문자
          password.contains(RegExp(r'[a-z]')) &&  // 소문자
          password.contains(RegExp(r'[0-9]')) &&  // 숫자
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // 특수문자
    });
    
    // 비밀번호가 변경될 때마다 비밀번호 확인 검증도 실행
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid =
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  List<Widget> _buildPasswordRequirements() {
    final password = _passwordController.text;
    final hasLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return [
      _buildRequirement('8글자 이상 입력해주세요', hasLength),
      _buildRequirement('영문 대문자를 포함해주세요 (예: A, B, C)', hasUppercase),
      _buildRequirement('영문 소문자를 포함해주세요 (예: a, b, c)', hasLowercase),
      _buildRequirement('숫자를 포함해주세요 (예: 1, 2, 3)', hasNumber),
      _buildRequirement('특수문자를 포함해주세요 (예: !, @, #)', hasSpecial),
    ];
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? Colors.green : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: isValid ? Colors.green : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () async {
              // 비밀번호가 입력되어 있으면 즉시 잠금 처리
              if (_passwordController.text.isNotEmpty && 
                  _isPasswordValid && 
                  !_isPasswordLocked) {
                final signupState = ref.read(signupFlowProvider);
                final email = signupState.email;
                
                if (email != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('locked_password_$email', _passwordController.text);
                  debugPrint('🔒 [PWD_SETUP] 뒤로가기 시 비밀번호 잠금 저장: ${_passwordController.text.length}자');
                }
              }
              
              // 비밀번호 잠금 상태일 때 뒤로가기 경고
              if (_isPasswordLocked || (_passwordController.text.isNotEmpty && _isPasswordValid)) {
                // iOS와 Android에 따라 다른 다이얼로그 사용
                if (Platform.isIOS) {
                  await showCupertinoDialog<void>(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('뒤로 가시겠습니까?'),
                      content: const Text(
                        '이미 가입이 진행 중입니다.\n'
                        '뒤로 가면 처음부터 다시 시작해야 할 수 있습니다.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.pop();
                          },
                          isDestructiveAction: true,
                          child: const Text('뒤로가기'),
                        ),
                      ],
                    ),
                  );
                } else {
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('뒤로 가시겠습니까?'),
                      content: const Text(
                        '이미 가입이 진행 중입니다.\n'
                        '뒤로 가면 처음부터 다시 시작해야 할 수 있습니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.pop();
                          },
                          child: const Text('뒤로가기'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                context.pop();
              }
            },
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
                // 단계 표시 텍스트
                Text(
                  '비밀번호 설정',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // 진행 상황 바
                Container(
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
                ),
                const SizedBox(height: 32),

                // 컨텐츠
                Expanded(
                  child: SingleChildScrollView(
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
                            '안전한 비밀번호를\n설정해주세요',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '계정 보안을 위해 안전한 비밀번호를 만들어주세요',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 비밀번호 잠김 안내
                          if (_isPasswordLocked) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                border: Border.all(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '이미 설정한 비밀번호입니다. 변경할 수 없습니다.',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 비밀번호 입력
                          Text(
                            '비밀번호',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  readOnly: _isPasswordLocked, // 비밀번호 잠김 시 수정 불가
                                  onChanged: _isPasswordLocked ? null : (_) {}, // 잠긴 상태에서는 변경 무시
                                  decoration: InputDecoration(
                                    hintText: _isPasswordLocked 
                                        ? '비밀번호가 잠겨 있습니다'
                                        : '대소문자, 숫자, 특수문자 포함 8자 이상',
                                    hintStyle: AppTextStyles.body2.copyWith(
                                      color: _isPasswordLocked 
                                          ? AppColors.warning
                                          : AppColors.textTertiary,
                                    ),
                                    filled: true,
                                    fillColor: _isPasswordLocked 
                                        ? AppColors.warning.withValues(alpha: 0.05)
                                        : AppColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                    suffixIcon: _isPasswordLocked
                                        ? const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Icons.lock,
                                              color: AppColors.warning,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textTertiary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible =
                                          !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호 확인
                          Text(
                            '비밀번호 확인',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  readOnly: _isPasswordLocked, // 비밀번호 확인도 잠김
                                  onChanged: _isPasswordLocked ? null : (_) {}, // 잠긴 상태에서는 변경 무시
                                  decoration: InputDecoration(
                                    hintText: _isPasswordLocked
                                        ? '비밀번호가 잠겨 있습니다'
                                        : '비밀번호를 다시 입력하세요',
                                    hintStyle: AppTextStyles.body2.copyWith(
                                      color: _isPasswordLocked
                                          ? AppColors.warning
                                          : AppColors.textTertiary,
                                    ),
                                    filled: true,
                                    fillColor: _isPasswordLocked
                                        ? AppColors.warning.withValues(alpha: 0.05)
                                        : AppColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                    suffixIcon: _isPasswordLocked
                                        ? const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Icons.lock,
                                              color: AppColors.warning,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textTertiary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (!_isConfirmPasswordValid &&
                              _confirmPasswordController
                                  .text
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '비밀번호가 일치하지 않습니다',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 비밀번호 요구사항
                          ..._buildPasswordRequirements(),

                          if (_signupError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
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
                                      _signupError!,
                                      style: AppTextStyles.body2
                                          .copyWith(
                                            color: AppColors.error,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),

                          // 회원가입 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  (_isPasswordValid &&
                                      _isConfirmPasswordValid &&
                                      !_isLoading)
                                  ? () async {
                                      setState(() {
                                        _isLoading = true;
                                        _signupError = null;
                                      });

                                      // 회원가입 플로우에서 이메일 가져오기
                                      final signupState = ref.read(
                                        signupFlowProvider,
                                      );
                                      final email = signupState.email;

                                      if (email == null) {
                                        setState(() {
                                          _signupError = '이메일 정보가 없습니다. 처음부터 다시 시작해주세요.';
                                          _isLoading = false;
                                        });
                                        return;
                                      }

                                      try {
                                        // Rate limit 체크
                                        final prefs = await SharedPreferences.getInstance();
                                        final savedTime = prefs.getInt('rate_limit_time_$email');
                                        final savedWaitSeconds = prefs.getInt('rate_limit_wait_$email') ?? 0;
                                        
                                        if (savedTime != null && savedWaitSeconds > 0) {
                                          final now = DateTime.now().millisecondsSinceEpoch;
                                          final elapsed = (now - savedTime) ~/ 1000;
                                          final remainingSeconds = savedWaitSeconds - elapsed;
                                          
                                          if (remainingSeconds > 0) {
                                            // 아직 대기 시간이 남음
                                            if (mounted) {
                                              setState(() {
                                                _signupError = '이메일 발송 제한: $remainingSeconds초 후 다시 시도해주세요';
                                                _isLoading = false;
                                              });
                                            }
                                            return;
                                          } else {
                                            // 대기 시간 완료, 초기화
                                            await prefs.remove('rate_limit_time_$email');
                                            await prefs.remove('rate_limit_wait_$email');
                                          }
                                        }
                                        
                                        // Supabase 회원가입 실행 (이메일과 비밀번호만)
                                        await ref
                                            .read(
                                              authControllerProvider
                                                  .notifier,
                                            )
                                            .signUp(
                                              email: email,
                                              password:
                                                  _passwordController
                                                      .text,
                                            );
                                        
                                        // 회원가입 성공
                                        debugPrint('✅ [회원가입 성공] 이메일 인증 페이지로 이동');
                                        
                                        // 비밀번호 잠금 저장 (처음 가입 시)
                                        if (!_isPasswordLocked) {
                                          await prefs.setString('locked_password_$email', _passwordController.text);
                                          debugPrint('🔒 [PWD_SETUP] 비밀번호 잠금 저장: ${_passwordController.text.length}자');
                                        }
                                        
                                        // Rate limit 초기화
                                        await prefs.remove('rate_limit_time_$email');
                                        await prefs.remove('rate_limit_wait_$email');
                                        
                                        if (!mounted) return;
                                        
                                        // ignore: use_build_context_synchronously
                                        await context.push(
                                          RoutePaths.emailConfirmation,
                                          extra: {
                                            'email': email,
                                            'password': _passwordController.text,
                                            'isResend': false,  // 처음 회원가입 시 이미 메일이 발송됨
                                          },
                                        );
                                      } catch (e) {
                                        debugPrint('🚨 [PWD_SETUP] 에러 캐치: $e');
                                        debugPrint('  - 타입: ${e.runtimeType}');
                                        
                                        // 에러 메시지 처리
                                        String errorMessage = '회원가입 실패';
                                        final errorString = e.toString().toLowerCase();
                                        debugPrint('  - 에러 문자열: $errorString');
                                        
                                        if (errorString.contains('rate limit') || 
                                            errorString.contains('for security purposes') ||
                                            errorString.contains('over_email_send_rate_limit')) {
                                          // 에러 메시지에서 시간 추출 시도
                                          RegExp timeRegex = RegExp(r'(\d+)\s*seconds?');
                                          Match? match = timeRegex.firstMatch(errorString);
                                          if (match != null) {
                                            String seconds = match.group(1)!;
                                            int waitSeconds = int.tryParse(seconds) ?? 60;
                                            errorMessage = '이메일 발송 제한: $waitSeconds초 후 다시 시도해주세요';
                                            
                                            // Rate limit 시간 저장
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setInt('rate_limit_wait_$email', waitSeconds);
                                            await prefs.setInt('rate_limit_time_$email', 
                                                               DateTime.now().millisecondsSinceEpoch);
                                            
                                            // 페이지 이동하지 않고 현재 화면에 머물기
                                            // 사용자가 직접 다시 시도하도록 유도
                                          } else {
                                            errorMessage = '잠시 후 다시 시도해주세요 (60초)';
                                            
                                            // 기본 60초 저장
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setInt('rate_limit_wait_$email', 60);
                                            await prefs.setInt('rate_limit_time_$email', 
                                                               DateTime.now().millisecondsSinceEpoch);
                                          }
                                        } else if (errorString.contains('invalid email')) {
                                          errorMessage = '올바른 이메일 형식이 아닙니다';
                                        } else if (errorString.contains('weak password')) {
                                          errorMessage = '비밀번호가 너무 약합니다';
                                        } else if (errorString.contains('user already registered')) {
                                          // 이미 가입된 계정 - 비밀번호 잠김 확인
                                          debugPrint('🧭 [PWD_SETUP] User already registered');
                                          
                                          // 비밀번호 잠김 설정
                                          if (!_isPasswordLocked) {
                                            final prefs = await SharedPreferences.getInstance();
                                            final lockedPwd = prefs.getString('locked_password_$email');
                                            
                                            if (lockedPwd != null && lockedPwd != _passwordController.text) {
                                              // 저장된 비밀번호와 다름 - 자동 복원
                                              setState(() {
                                                _isPasswordLocked = true;
                                                _lockedPassword = lockedPwd;
                                                _passwordController.text = lockedPwd;
                                                _confirmPasswordController.text = lockedPwd;
                                              });
                                              errorMessage = '처음 설정한 비밀번호로 자동 복원되었습니다.';
                                              debugPrint('🔒 [PWD_SETUP] 비밀번호 자동 복원');
                                            } else if (lockedPwd == null) {
                                              // 처음으로 비밀번호 잠금
                                              await prefs.setString('locked_password_$email', _passwordController.text);
                                              setState(() {
                                                _isPasswordLocked = true;
                                                _lockedPassword = _passwordController.text;
                                              });
                                              debugPrint('🔒 [PWD_SETUP] 비밀번호 잠금 설정');
                                            }
                                          }
                                          
                                          errorMessage = '이미 가입 진행 중인 계정입니다. 인증 메일을 확인해주세요.';
                                          
                                          // 인증 페이지로 이동
                                          if (mounted) {
                                            // ignore: use_build_context_synchronously
                                            await context.push(
                                              RoutePaths.emailConfirmation,
                                              extra: {
                                                'email': email,
                                                'password': _passwordController.text, // 현재(잠긴) 비밀번호
                                                'isResend': true,
                                              },
                                            );
                                          }
                                        } else if (errorString.contains('email_not_confirmed')) {
                                          // 이메일 미인증 계정 - Rate limit 체크 후 처리
                                          debugPrint('🧭 [PWD_SETUP] 이메일 미인증 계정 감지');
                                          
                                          // Rate limit 체크
                                          final prefs = await SharedPreferences.getInstance();
                                          final savedTime = prefs.getInt('rate_limit_time_$email');
                                          final savedWaitSeconds = prefs.getInt('rate_limit_wait_$email') ?? 0;
                                          
                                          if (savedTime != null && savedWaitSeconds > 0) {
                                            final now = DateTime.now().millisecondsSinceEpoch;
                                            final elapsed = (now - savedTime) ~/ 1000;
                                            final remainingSeconds = savedWaitSeconds - elapsed;
                                            
                                            if (remainingSeconds > 0) {
                                              // 아직 대기 시간이 남음
                                              errorMessage = '이메일 발송 제한: $remainingSeconds초 후 다시 시도해주세요';
                                              debugPrint('⏰ [PWD_SETUP] Rate limit 활성: $remainingSeconds초');
                                            } else {
                                              // 대기 시간 완료
                                              await prefs.remove('rate_limit_time_$email');
                                              await prefs.remove('rate_limit_wait_$email');
                                              errorMessage = '이메일 인증이 필요합니다. 다시 시도해주세요.';
                                              
                                              // 인증 페이지로 이동
                                              unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
                                                if (mounted) {
                                                  context.push(
                                                    RoutePaths.emailConfirmation,
                                                    extra: {
                                                      'email': email,
                                                      'password': _passwordController.text,
                                                      'isResend': false,  // 이미 인증 코드를 받았으므로 재발송 불필요
                                                    },
                                                  );
                                                }
                                              }));
                                            }
                                          } else {
                                            errorMessage = '이메일 인증이 필요합니다';
                                            
                                            // 인증 페이지로 이동
                                            unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
                                              if (mounted) {
                                                context.push(
                                                  RoutePaths.emailConfirmation,
                                                  extra: {
                                                    'email': email,
                                                    'password': _passwordController.text,
                                                    'isResend': false,  // 이미 인증 코드를 받았으므로 재발송 불필요
                                                  },
                                                );
                                              }
                                            }));
                                          }
                                        } else if (errorString.contains('이미 가입된 이메일')) {
                                          debugPrint('🧭 [PWD_SETUP] 이미 가입된 이메일 감지 - 로그인 페이지로 이동 예약');
                                          errorMessage = '이미 가입된 이메일입니다';
                                          // 로그인 페이지로 이동
                                          unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
                                            if (mounted) {
                                              debugPrint('🧭 [PWD_SETUP] 로그인 페이지로 이동 실행 - email: $email');
                                              context.go(RoutePaths.login, extra: {'email': email});
                                            }
                                          }));
                                        }
                                        
                                        setState(() {
                                          _signupError = errorMessage;
                                        });
                                      }
                                      
                                      // 로딩 해제
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
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
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                    )
                                  : Text(
                                      '인증 메일 받기',
                                      style: AppTextStyles.button
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
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
}
