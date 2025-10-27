import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/input_validator.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

/// 전화번호 자동 포맷팅 클래스
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 11; i++) {
      // 010-0000-0000 형식
      if (i == 3 ||
          (i == 7 && text.length > 10) ||
          (i == 6 && text.length <= 10)) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditMode = false;
  bool? _emailNotification; // null로 초기화하여 DB 값 로드 대기
  bool? _pushNotification; // null로 초기화하여 DB 값 로드 대기
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 프로필 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final profileAsync = ref.read(currentProfileProvider);
    profileAsync.whenData((profile) {
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile.displayName ?? '';
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
          // DB에서 알림 설정 값을 정확히 로드
          _emailNotification = profile.emailNotification;
          _pushNotification = profile.pushNotification;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 프로필 데이터 실시간 감지
    final profileAsync = ref.watch(currentProfileProvider);

    // 프로필 데이터가 로드되면 필드 업데이트 (편집 모드가 아닐 때만)
    profileAsync.whenData((profile) {
      if (profile != null && !_isEditMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // 텍스트 필드 업데이트
            if (_nameController.text != (profile.displayName ?? '')) {
              _nameController.text = profile.displayName ?? '';
            }
            if (_emailController.text != profile.email) {
              _emailController.text = profile.email;
            }
            if (_phoneController.text != (profile.phone ?? '')) {
              _phoneController.text = profile.phone ?? '';
            }
            // 알림 설정도 초기값이 null일 때만 업데이트 (초기 로드)
            if (_emailNotification == null ||
                _pushNotification == null) {
              setState(() {
                _emailNotification = profile.emailNotification;
                _pushNotification = profile.pushNotification;
              });
            }
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '프로필',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_isEditMode) {
                  // 저장 로직
                  _saveProfile();
                }
                _isEditMode = !_isEditMode;
              });
            },
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    _isEditMode ? '저장' : '편집',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 프로필 이미지
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                        size: 40,
                      ),
                    ),
                    if (_isEditMode)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 계정 정보 섹션
              _buildSectionTitle('계정 정보'),
              const SizedBox(height: 12),
              _buildInfoCard(
                children: [
                  _buildNicknameField(),
                  _buildDivider(),
                  _buildEmailField(),
                  _buildDivider(),
                  _buildPhoneField(),
                ],
              ),

              const SizedBox(height: 24),

              // 알림 설정 섹션
              _buildSectionTitle('알림 설정'),
              const SizedBox(height: 12),
              _buildInfoCard(
                children: [
                  _buildSwitchTile(
                    title: '이메일 알림',
                    subtitle: '새로운 기능 및 업데이트 소식',
                    value:
                        _emailNotification ??
                        false, // null인 경우 false 표시
                    onChanged: _emailNotification == null
                        ? null
                        : (value) {
                            // 로딩 중에는 비활성화
                            if (!value) {
                              _showNotificationConfirmDialog(
                                title: '이메일 알림 해제',
                                message:
                                    '이메일 알림을 해제하면 새로운 기능과\n중요한 공지사항을 받을 수 없습니다.\n\n정말 끄시겠습니까?',
                                onConfirm: () =>
                                    _updateNotificationSetting(
                                      emailNotification: false,
                                    ),
                              );
                            } else {
                              _updateNotificationSetting(
                                emailNotification: true,
                              );
                            }
                          },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: '푸시 알림',
                    subtitle: '복약 알림 및 중요 공지',
                    value:
                        _pushNotification ??
                        false, // null인 경우 false 표시
                    onChanged: _pushNotification == null
                        ? null
                        : (value) {
                            // 로딩 중에는 비활성화
                            if (!value) {
                              _showNotificationConfirmDialog(
                                title: '푸시 알림 해제',
                                message:
                                    '푸시 알림을 해제하면 복약 시간과\n중요한 알림을 놓칠 수 있습니다.\n\n정말 끄시겠습니까?',
                                onConfirm: () =>
                                    _updateNotificationSetting(
                                      pushNotification: false,
                                    ),
                              );
                            } else {
                              _updateNotificationSetting(
                                pushNotification: true,
                              );
                            }
                          },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 계정 관리 섹션
              _buildSectionTitle('계정 관리'),
              const SizedBox(height: 12),
              _buildInfoCard(
                children: [
                  _buildActionTile(
                    title: '비밀번호 변경',
                    icon: Icons.lock_outline,
                    onTap: () {
                      _showPasswordChangeDialog();
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    title: '계정 삭제',
                    icon: Icons.delete_outline,
                    textColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: () {
                      _showAccountDeleteDialog();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 100), // 바텀 네비게이션 공간
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
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
      child: Column(children: children),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_outlined,
            color: _isEditMode
                ? AppColors.primary
                : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전화번호',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isEditMode)
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _phoneController.text.isNotEmpty &&
                                !_isValidPhoneNumber(_phoneController.text)
                            ? AppColors.error.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: _isEditMode,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9-]'),
                        ),
                        _PhoneNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: '010-0000-0000',
                        hintStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        setState(() {}); // 에러 메시지 업데이트를 위해
                      },
                    ),
                  )
                else
                  Text(
                    _phoneController.text.isEmpty
                        ? '-'
                        : _phoneController.text,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                if (_isEditMode &&
                    _phoneController.text.isNotEmpty &&
                    !_isValidPhoneNumber(_phoneController.text)) ...[
                  const SizedBox(height: 2),
                  Text(
                    '올바른 전화번호 형식이 아닙니다',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidPhoneNumber(String phone) {
    // InputValidator 사용하여 검증
    final sanitized = InputValidator.sanitizePhone(phone);
    return sanitized != null;
  }

  bool _isValidNickname(String nickname) {
    // 닉네임 길이 체크
    if (nickname.length < 2 || nickname.length > 10) {
      return false;
    }

    // 한글, 영문, 숫자만 허용
    final nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    return nicknameRegex.hasMatch(nickname);
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.email_outlined,
            color: AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이메일',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text.isEmpty
                      ? '-'
                      : _emailController.text,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: _isEditMode
                ? AppColors.primary
                : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '닉네임',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isEditMode)
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _nameController.text.isNotEmpty &&
                                !_isValidNickname(_nameController.text)
                            ? AppColors.error.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      enabled: _isEditMode,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력하세요',
                        hintStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        isDense: true,
                        counterText: '',
                      ),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  )
                else
                  Text(
                    _nameController.text.isEmpty
                        ? '-'
                        : _nameController.text,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                if (_isEditMode &&
                    _nameController.text.isNotEmpty &&
                    !_isValidNickname(_nameController.text)) ...[
                  const SizedBox(height: 2),
                  Text(
                    '2-10자의 한글, 영문, 숫자만 가능합니다',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged, // nullable로 변경
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
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

  void _saveProfile() async {
    // 닉네임 validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요', textAlign: TextAlign.center),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_isValidNickname(_nameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '닉네임은 2-10자의 한글, 영문, 숫자만 가능합니다',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 전화번호 validation
    if (_phoneController.text.isNotEmpty) {
      final sanitizedPhone = InputValidator.sanitizePhone(
        _phoneController.text,
      );
      if (sanitizedPhone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '올바른 전화번호 형식이 아닙니다',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateMyProfile(
        displayName: _nameController.text,
        phone: _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
      );

      // 프로필 프로바이더 갱신
      ref.invalidate(currentProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '프로필이 저장되었습니다',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e', textAlign: TextAlign.center),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPasswordChangeDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('비밀번호 변경'),
        content: const Text('비밀번호 변경 기능은 준비 중입니다'),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNotificationSetting({
    bool? emailNotification,
    bool? pushNotification,
  }) async {
    // null 체크 - DB 값이 로드되지 않았으면 리턴
    if (_emailNotification == null || _pushNotification == null) {
      return;
    }

    // UI 업데이트 전 현재 상태 저장 (롤백용)
    final previousEmail = _emailNotification;
    final previousPush = _pushNotification;

    // 먼저 UI를 즉시 업데이트
    setState(() {
      if (emailNotification != null) {
        _emailNotification = emailNotification;
      }
      if (pushNotification != null) {
        _pushNotification = pushNotification;
      }
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateNotificationSettings(
        emailNotification: emailNotification ?? _emailNotification,
        pushNotification: pushNotification ?? _pushNotification,
      );

      // DB 업데이트 성공 후 프로바이더 갱신
      ref.invalidate(currentProfileProvider);

      // 성공 시 짧은 피드백
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '알림 설정이 변경되었습니다',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
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
      // 오류 발생 시 이전 상태로 롤백
      setState(() {
        _emailNotification = previousEmail;
        _pushNotification = previousPush;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '알림 설정 변경 실패',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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

  void _showNotificationConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('끄기'),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  void _showAccountDeleteDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('계정 삭제'),
        content: const Text('정말로 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('삭제'),
            onPressed: () async {
              Navigator.pop(context);
              // TODO: BFF 서버가 활성화되면 계정 삭제 API 호출
              // 현재는 BFF가 내려가 있어서 실제 삭제 불가
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '계정 삭제 기능은 현재 준비 중입니다',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
