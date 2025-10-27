import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 이메일 인증 확인 페이지
class EmailConfirmationPage extends StatefulWidget {
  final String email;
  final String password;
  final bool isResend;
  final int? rateLimitSeconds;

  const EmailConfirmationPage({
    super.key,
    required this.email,
    required this.password,
    this.isResend = false,
    this.rateLimitSeconds,
  });

  @override
  State<EmailConfirmationPage> createState() =>
      _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends State<EmailConfirmationPage> {
  final supabase = Supabase.instance.client;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  StreamSubscription<AuthState>? _authSubscription;
  int _cooldownSeconds = 0;
  int _remainingSeconds = 3600;
  
  final bool _isDebugMode = const bool.fromEnvironment(
    'DEBUG',
    defaultValue: false,
  );

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 [EMAIL_CONFIRM.initState] 시작');
    debugPrint('  - email: ${widget.email}');
    debugPrint('  - isResend: ${widget.isResend}');
    debugPrint('  - rateLimitSeconds: ${widget.rateLimitSeconds}');
    
    // 비동기 초기화
    _initialize();
    
    // 폴링 및 리스너 시작
    _startPolling();
    _listenToAuthChanges();
    _startCountdown();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('🔍 [EMAIL_CONFIRM._initialize] 시작');
      
      // 0. 비밀번호 잠금 저장 (인증 페이지 진입 = 회원가입 진행 중)
      await _saveLockedPassword();
      
      // 1. 전달받은 rate limit이 있으면 우선 적용
      if (widget.rateLimitSeconds != null && widget.rateLimitSeconds! > 0) {
        debugPrint('📍 [EMAIL_CONFIRM] 전달받은 rate limit: ${widget.rateLimitSeconds}초');
        
        if (mounted) {
          setState(() {
            _cooldownSeconds = widget.rateLimitSeconds!;
          });
        }
        
        // 저장
        await _saveRateLimitTime(widget.rateLimitSeconds!);
      } else {
        // 2. 전달받은 값이 없으면 저장된 값 확인
        await _loadRateLimitTime();
      }
      
      // 3. 재전송 처리
      if (widget.isResend && mounted) {
        // 초기화 완료 대기
        await Future<void>.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        debugPrint('📧 [EMAIL_CONFIRM] 재전송 처리 - 현재 cooldown: $_cooldownSeconds초');
        
        if (_cooldownSeconds == 0) {
          debugPrint('✅ [EMAIL_CONFIRM] 쿨다운 없음, 이메일 재발송 시도');
          await _resendEmail();
        } else {
          debugPrint('⏰ [EMAIL_CONFIRM] Rate limit 활성: $_cooldownSeconds초 대기 필요');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$_cooldownSeconds초 후에 이메일을 다시 보낼 수 있습니다',
                  textAlign: TextAlign.center,
                ),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 3),
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
      }
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM._initialize] 에러: $e');
      // 에러 발생해도 앱이 충돌하지 않도록
      if (mounted) {
        setState(() {
          _cooldownSeconds = 0;
        });
      }
    }
  }

  /// SharedPreferences에서 rate limit 시간 로드
  Future<void> _loadRateLimitTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getInt('rate_limit_time_${widget.email}');
      final savedWaitSeconds = prefs.getInt('rate_limit_wait_${widget.email}');
      
      debugPrint('🔍 [EMAIL_CONFIRM._loadRateLimitTime] 저장된 값 확인');
      debugPrint('  - savedTime: $savedTime');
      debugPrint('  - savedWaitSeconds: $savedWaitSeconds');
      
      if (savedTime != null && savedWaitSeconds != null && savedWaitSeconds > 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = (now - savedTime) ~/ 1000;
        
        debugPrint('  - 현재 시간: $now');
        debugPrint('  - 경과 시간: $elapsed초');
        
        if (elapsed < savedWaitSeconds) {
          final remaining = savedWaitSeconds - elapsed;
          
          if (mounted) {
            setState(() {
              _cooldownSeconds = remaining;
            });
          }
          
          debugPrint('✅ [EMAIL_CONFIRM] Rate limit 복구: $remaining초 남음');
        } else {
          // 시간이 지났으면 초기화
          if (mounted) {
            setState(() {
              _cooldownSeconds = 0;
            });
          }
          
          await prefs.remove('rate_limit_time_${widget.email}');
          await prefs.remove('rate_limit_wait_${widget.email}');
          
          debugPrint('✅ [EMAIL_CONFIRM] Rate limit 만료, 초기화됨');
        }
      } else {
        if (mounted) {
          setState(() {
            _cooldownSeconds = 0;
          });
        }
        debugPrint('ℹ️ [EMAIL_CONFIRM] 저장된 rate limit 없음');
      }
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM._loadRateLimitTime] 에러: $e');
      if (mounted) {
        setState(() {
          _cooldownSeconds = 0;
        });
      }
    }
  }

  /// 비밀번호 잠금 저장 (인증 페이지 진입 시)
  Future<void> _saveLockedPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 무조건 현재 비밀번호로 업데이트 (매번 갱신)
      await prefs.setString('locked_password_${widget.email}', widget.password);
      await prefs.reload(); // 강제 동기화
      
      debugPrint('🔒 [EMAIL_CONFIRM] 비밀번호 잠금 저장: ${widget.password.length}자');
      debugPrint('  - 저장 키: locked_password_${widget.email}');
      debugPrint('  - 저장 후 모든 키: ${prefs.getKeys()}');
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM._saveLockedPassword] 에러: $e');
    }
  }

  /// Rate limit 시간을 SharedPreferences에 저장
  Future<void> _saveRateLimitTime(int waitSeconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setInt('rate_limit_time_${widget.email}', now);
      await prefs.setInt('rate_limit_wait_${widget.email}', waitSeconds);
      
      debugPrint('💾 [EMAIL_CONFIRM._saveRateLimitTime] 저장 완료');
      debugPrint('  - 현재 시간: $now');
      debugPrint('  - 대기 시간: $waitSeconds초');
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM._saveRateLimitTime] 에러: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        // 로그인 시도하여 최신 정보 가져오기
        final response = await supabase.auth.signInWithPassword(
          email: widget.email,
          password: widget.password,
        );

        if (response.user != null &&
            response.user!.emailConfirmedAt != null) {
          _handleVerificationSuccess();
        }
      } catch (e) {
        // 에러 무시 (이미 로그인된 상태일 수 있음)
      }
    });
  }

  void _listenToAuthChanges() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && user.emailConfirmedAt != null) {
        _handleVerificationSuccess();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          }
          if (_cooldownSeconds > 0) {
            _cooldownSeconds--;
            
            // 쿨다운이 끝났을 때 SharedPreferences 정리
            if (_cooldownSeconds == 0) {
              _clearRateLimitData();
            }
          }
        });
      }
    });
  }

  Future<void> _clearRateLimitData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rate_limit_time_${widget.email}');
      await prefs.remove('rate_limit_wait_${widget.email}');
      debugPrint('🗑️ [EMAIL_CONFIRM] Rate limit 데이터 삭제됨');
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM._clearRateLimitData] 에러: $e');
    }
  }

  void _handleVerificationSuccess() async {
    _pollingTimer?.cancel();
    await _authSubscription?.cancel();
    _countdownTimer?.cancel();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '이메일 인증이 완료되었습니다!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.success,
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

      // 자동 로그인 수행
      try {
        await supabase.auth.signInWithPassword(
          email: widget.email,
          password: widget.password,
        );
      } catch (e) {
        debugPrint('Auto login failed: $e');
      }

      // 프로필 설정 페이지로 이동
      if (mounted) {
        context.go(RoutePaths.profileSetup);
      }
    }
  }

  /// 에러 메시지에서 rate limit 시간 추출
  int _extractSecondsFromError(String errorString) {
    debugPrint('🔍 [EMAIL_CONFIRM._extractSecondsFromError] 에러 메시지 분석');
    debugPrint('  - 원본: $errorString');
    
    // 다양한 패턴 시도
    final patterns = [
      RegExp(r'(\d+)\s*seconds?'),  // "54 seconds", "1 second"
      RegExp(r'wait\s+(\d+)\s*seconds?'),  // "wait 30 seconds"
      RegExp(r'after\s+(\d+)\s*seconds?'),  // "after 60 seconds"
      RegExp(r'in\s+(\d+)\s*seconds?'),  // "in 45 seconds"
      RegExp(r'(\d+)\s*초'),  // 한글 "60초"
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(errorString.toLowerCase());
      if (match != null) {
        final seconds = int.tryParse(match.group(1) ?? '60') ?? 60;
        debugPrint('  - 패턴 매칭 성공: $seconds초');
        
        // 합리적인 범위 체크 (1초 ~ 10분)
        if (seconds >= 1 && seconds <= 600) {
          return seconds;
        }
      }
    }
    
    // 숫자만 있는 경우 체크
    final numberMatch = RegExp(r'(\d+)').firstMatch(errorString);
    if (numberMatch != null) {
      final num = int.tryParse(numberMatch.group(1) ?? '60') ?? 60;
      if (num >= 1 && num <= 600) {
        debugPrint('  - 숫자 추출: $num초');
        return num;
      }
    }
    
    debugPrint('  - 기본값 사용: 60초');
    return 60;  // 기본값
  }

  Future<void> _resendEmail() async {
    debugPrint('🔍 [EMAIL_CONFIRM._resendEmail] 호출');
    
    if (_cooldownSeconds > 0) {
      debugPrint('⚠️ [EMAIL_CONFIRM] 쿨다운 중: $_cooldownSeconds초 남음');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_cooldownSeconds초 후에 다시 시도해주세요',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.warning,
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
      return;
    }

    // 남은 시간 리셋
    setState(() {
      _remainingSeconds = 3600;
    });

    try {
      debugPrint('📧 [EMAIL_CONFIRM] 인증 메일 재발송 시도');
      debugPrint('  - 이메일: ${widget.email}');
      debugPrint('  - 비밀번호 길이: ${widget.password.length}');
      
      // 먼저 비밀번호가 맞는지 확인 (이미 가입된 경우)
      try {
        debugPrint('🔑 [EMAIL_CONFIRM] 비밀번호 검증 시도');
        await supabase.auth.signInWithPassword(
          email: widget.email,
          password: widget.password,
        );
        debugPrint('✅ [EMAIL_CONFIRM] 비밀번호 일치 - 계속 진행');
        
        // 로그아웃 (다음 단계를 위해)
        await supabase.auth.signOut();
      } catch (loginError) {
        final loginErrorStr = loginError.toString().toLowerCase();
        debugPrint('⚠️ [EMAIL_CONFIRM] 로그인 실패: $loginErrorStr');
        
        // 이메일 미인증은 무시하고 계속
        if (!loginErrorStr.contains('email not confirmed') && 
            !loginErrorStr.contains('email_not_confirmed')) {
          // 비밀번호 불일치 또는 다른 에러
          if (loginErrorStr.contains('invalid') || 
              loginErrorStr.contains('credentials') ||
              loginErrorStr.contains('password')) {
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '비밀번호가 일치하지 않습니다.\n처음 가입 시 입력한 비밀번호를 사용해주세요.',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 3),
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
            return; // 비밀번호 불일치 시 중단
          }
        }
      }
      
      // signUp을 다시 호출 (이미 가입된 경우 이메일만 재전송됨)
      await supabase.auth.signUp(
        email: widget.email,
        password: widget.password,
      );
      
      debugPrint('✅ [EMAIL_CONFIRM] 인증 메일 재발송 성공');

      // 성공 시 기본 쿨다운 설정
      if (mounted) {
        setState(() {
          _cooldownSeconds = 60;
        });
        
        await _saveRateLimitTime(60);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '인증 이메일을 다시 보냈습니다',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.success,
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
    } catch (e) {
      debugPrint('❌ [EMAIL_CONFIRM] 이메일 재발송 실패: $e');
      
      final errorString = e.toString().toLowerCase();
      String errorMessage = '이메일 전송 실패';
      
      // 이미 등록된 사용자 처리
      if (errorString.contains('user already registered')) {
        if (mounted) {
          setState(() {
            _cooldownSeconds = 60;
          });
          
          await _saveRateLimitTime(60);
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '인증 이메일을 다시 보냈습니다',
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppColors.success,
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
        return;
      }
      
      // Rate limit 에러 처리
      if (errorString.contains('rate limit') || 
          errorString.contains('too many requests') ||
          errorString.contains('for security purposes') ||
          errorString.contains('email rate limit exceeded')) {
        
        final extractedSeconds = _extractSecondsFromError(errorString);
        
        debugPrint('✅ [EMAIL_CONFIRM] Rate limit 감지: $extractedSeconds초');
        
        if (mounted) {
          setState(() {
            _cooldownSeconds = extractedSeconds;
          });
          
          await _saveRateLimitTime(extractedSeconds);
          
          errorMessage = '$extractedSeconds초 후에 다시 시도해주세요';
        }
      }
      
      if (mounted) {
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
  }

  void _checkVerificationManually() async {
    try {
      // 다시 로그인하여 최신 정보 가져오기
      final response = await supabase.auth.signInWithPassword(
        email: widget.email,
        password: widget.password,
      );

      if (response.user != null &&
          response.user!.emailConfirmedAt != null) {
        _handleVerificationSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '아직 이메일 인증이 완료되지 않았습니다',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '인증 확인 중 오류가 발생했습니다',
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
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이메일 인증',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 3 / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 컨텐츠
                Expanded(
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 이메일 아이콘
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mark_email_unread_outlined,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 제목
                          Text(
                            '이메일을 확인해주세요',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 설명
                          Text(
                            '인증 이메일을 보냈습니다',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 이메일 주소
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.email,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 남은 시간
                          Container(
                            padding: const EdgeInsets.all(16),
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
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '남은 시간: ${_formatTime(_remainingSeconds)}',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 다시 보내기 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _cooldownSeconds > 0
                                  ? null
                                  : _resendEmail,
                              icon: Icon(
                                Icons.refresh,
                                color: _cooldownSeconds > 0
                                    ? AppColors.textTertiary
                                    : AppColors.primary,
                              ),
                              label: Text(
                                _cooldownSeconds > 0
                                    ? '$_cooldownSeconds초 후 다시 보내기 가능'
                                    : '인증 이메일 다시 보내기',
                                style: AppTextStyles.button.copyWith(
                                  color: _cooldownSeconds > 0
                                      ? AppColors.textTertiary
                                      : AppColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _cooldownSeconds > 0
                                      ? AppColors.border
                                      : AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 이메일 인증했어요 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _checkVerificationManually,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              child: Text(
                                '이메일 인증했어요',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // 개발 모드에서만 표시
                          if (_isDebugMode) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: TextButton(
                                onPressed: _handleVerificationSuccess,
                                child: Text(
                                  '개발용: 인증 건너뛰기',
                                  style: AppTextStyles.button
                                      .copyWith(
                                        color:
                                            AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // 안내 메시지
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '이메일이 오지 않나요?',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.info,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• 스팸 메일함을 확인해주세요\n'
                                  '• 이메일 주소가 올바른지 확인해주세요\n'
                                  '• 잠시 후 다시 시도해주세요',
                                  style: AppTextStyles.caption
                                      .copyWith(
                                        color:
                                            AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 대기 중 메시지
                          CircularProgressIndicator(
                            color: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '이메일 인증 대기 중...',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
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