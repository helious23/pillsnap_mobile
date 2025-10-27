import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pillsnap/core/router/route_paths.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_dimensions.dart';
import '../providers/auth_provider.dart';

/// 프로필 설정 페이지 (회원가입 3단계)
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _otherAllergyController = TextEditingController();
  
  bool _isValid = false;
  bool _isLoading = false;
  String? _nicknameError;
  String? _phoneError;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _showOtherAllergyInput = false;
  
  // 현재 단계 (총 4단계 중 4단계)
  int currentStep = 4;
  
  // 알레르기 정보 (선택)
  final List<String> _commonAllergies = [
    '페니실린',
    '아스피린',
    '설파제',
    '요오드',
    '라텍스',
    '기타',
    '없음',
  ];
  final Set<String> _selectedAllergies = {};

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _nicknameError = null;
      _phoneError = null;
      
      // 닉네임 검증 (2-20자)
      if (_nicknameController.text.isNotEmpty && 
          (_nicknameController.text.length < 2 || _nicknameController.text.length > 20)) {
        _nicknameError = '닉네임은 2-20자 사이여야 합니다';
      }
      
      // 전화번호 검증 (010으로 시작, 11자리)
      final phone = _phoneController.text.replaceAll('-', '');
      if (phone.isNotEmpty) {
        if (!phone.startsWith('010')) {
          _phoneError = '010으로 시작하는 번호를 입력하세요';
        } else if (phone.length != 11) {
          _phoneError = '올바른 전화번호를 입력하세요 (11자리)';
        } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
          _phoneError = '숫자만 입력 가능합니다';
        }
      }
      
      _isValid = _nicknameController.text.length >= 2 && 
                 _nicknameController.text.length <= 20 &&
                 phone.startsWith('010') &&
                 phone.length == 11 &&
                 RegExp(r'^[0-9]+$').hasMatch(phone);
    });
  }


  // 날짜 선택
  Future<void> _selectBirthDate() async {
    // 현재 날짜 기준 20살을 기본값으로
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 20, now.month, now.day);
    DateTime? tempPickedDate = _selectedBirthDate ?? initialDate;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '취소',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '생년월일 선택',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (tempPickedDate != null) {
                              setState(() {
                                _selectedBirthDate = tempPickedDate;
                                _birthDateController.text = 
                                  DateFormat('yyyy년 MM월 dd일').format(tempPickedDate!);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            '확인',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // 년도 선택 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 이전 년도 버튼
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              final newDate = DateTime(
                                tempPickedDate!.year - 1,
                                tempPickedDate!.month,
                                tempPickedDate!.day,
                              );
                              if (newDate.isAfter(DateTime(1899, 12, 31))) {
                                tempPickedDate = newDate;
                              }
                            });
                          },
                          icon: const Icon(Icons.keyboard_double_arrow_left),
                          color: AppColors.primary,
                        ),
                        // 년도 표시 (클릭 가능)
                        InkWell(
                          onTap: () async {
                            // 년도 선택 다이얼로그
                            final selectedYear = await showDialog<int>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('년도 선택'),
                                  content: SizedBox(
                                    width: double.minPositive,
                                    height: 300,
                                    child: YearPicker(
                                      firstDate: DateTime(1900),
                                      lastDate: now,
                                      selectedDate: tempPickedDate ?? initialDate,
                                      onChanged: (DateTime value) {
                                        Navigator.pop(context, value.year);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                            
                            if (selectedYear != null) {
                              setModalState(() {
                                tempPickedDate = DateTime(
                                  selectedYear,
                                  tempPickedDate!.month,
                                  tempPickedDate!.day,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${tempPickedDate?.year ?? initialDate.year}년',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 다음 년도 버튼
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              final newDate = DateTime(
                                tempPickedDate!.year + 1,
                                tempPickedDate!.month,
                                tempPickedDate!.day,
                              );
                              if (newDate.isBefore(now)) {
                                tempPickedDate = newDate;
                              }
                            });
                          },
                          icon: const Icon(Icons.keyboard_double_arrow_right),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  // 캘린더
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TableCalendar<dynamic>(
                        firstDay: DateTime(1900, 1, 1),
                        lastDay: now,
                        focusedDay: tempPickedDate ?? initialDate,
                        selectedDayPredicate: (day) {
                          return isSameDay(tempPickedDate, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setModalState(() {
                            tempPickedDate = selectedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setModalState(() {
                            tempPickedDate = focusedDay;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '월',
                        },
                        locale: 'ko_KR',
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextFormatter: (date, locale) {
                            return DateFormat.yMMMM(locale).format(date);
                          },
                          titleTextStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: AppColors.primary,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: AppTextStyles.body2.copyWith(
                            color: Colors.red,
                          ),
                          outsideDaysVisible: false,
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          weekendStyle: AppTextStyles.caption.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _otherAllergyController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // 뒤로가기 방지 (이메일 인증 완료 후에는 뒤로 갈 수 없음)
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
            title: Text(
              '회원가입',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                  '프로필 설정',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // 프로그레스 바
                _buildProgressBar(currentStep),
                const SizedBox(height: 40),
                // 컨텐츠 카드
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프로필 정보',
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '서비스 이용을 위한 기본 정보를 입력해주세요',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // 닉네임 (필수)
                          _buildTextField(
                            label: '닉네임',
                            controller: _nicknameController,
                            hint: '2-20자 사이의 닉네임',
                            error: _nicknameError,
                            required: true,
                          ),
                          const SizedBox(height: 20),
                          
                          // 전화번호 (필수)
                          _buildTextField(
                            label: '전화번호',
                            controller: _phoneController,
                            hint: '010-1234-5678',
                            error: _phoneError,
                            required: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _PhoneNumberFormatter(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // 생년월일 (선택)
                          _buildTextField(
                            label: '생년월일',
                            controller: _birthDateController,
                            hint: '생년월일 선택',
                            readOnly: true,
                            onTap: _selectBirthDate,
                            suffixIcon: Icons.calendar_today,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: AppColors.textTertiary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '연령대별 안전한 복용량 확인을 위해 사용됩니다',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // 성별 (선택)
                          _buildGenderSelection(),
                          const SizedBox(height: 20),
                          
                          // 알레르기 정보 (선택)
                          _buildAllergySection(),
                          const SizedBox(height: 32),
                          
                          // 다음 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isValid && !_isLoading
                                  ? () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      
                                      try {
                                        // 프로필 업데이트
                                        final profileRepo = ref.read(profileRepositoryProvider);
                                        
                                        // 알레르기 정보 처리
                                        final allergiesList = <String>[];
                                        for (var allergy in _selectedAllergies) {
                                          if (allergy != '기타') {
                                            allergiesList.add(allergy);
                                          }
                                        }
                                        if (_selectedAllergies.contains('기타') && _otherAllergyController.text.isNotEmpty) {
                                          allergiesList.add(_otherAllergyController.text);
                                        }
                                        
                                        // 모든 프로필 정보를 한 번에 업데이트
                                        await profileRepo.updateMyProfile(
                                          displayName: _nicknameController.text,
                                          phone: _phoneController.text,
                                        );
                                        
                                        debugPrint('🏁 [PROFILE_SETUP] profile_completed: false → true 업데이트 시작');
                                        await profileRepo.updateProfile(
                                          phoneNumber: _phoneController.text,
                                          birthDate: _selectedBirthDate,
                                          gender: _selectedGender,
                                          allergies: allergiesList.isNotEmpty ? allergiesList : null,
                                          profileCompleted: true,
                                        );
                                        debugPrint('✅ [PROFILE_SETUP] profile_completed 업데이트 완료');
                                        
                                        // profileCompletedProvider 캐시 무효화
                                        ref.invalidate(profileCompletedProvider);
                                        ref.invalidate(currentProfileProvider);
                                        
                                        // 짧은 지연을 주어 provider가 업데이트되도록 함
                                        await Future<void>.delayed(const Duration(milliseconds: 200));
                                        
                                        // 온보딩으로 이동
                                        if (context.mounted) {
                                          debugPrint('🧭 [PROFILE_SETUP] 온보딩으로 이동');
                                          context.go(RoutePaths.onboarding);
                                        }
                                      } catch (e) {
                                        // 에러 처리
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '프로필 업데이트 실패: $e',
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
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '프로필 완성',
                                    style: AppTextStyles.button.copyWith(
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
    ),
  );
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? error,
    bool required = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: error != null ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (!required) ...[
              const SizedBox(width: 4),
              Text(
                '(선택)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: error,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : Colors.transparent,
                width: error != null ? 1.0 : 0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : Colors.transparent,
                width: error != null ? 1.0 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.textTertiary, size: 20)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '성별',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(선택)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('남성', 'male'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('여성', 'female'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('기타', 'other'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = isSelected ? null : value;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '알레르기 정보',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(선택)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonAllergies.map((allergy) {
            final isSelected = _selectedAllergies.contains(allergy);
            return InkWell(
              onTap: () {
                setState(() {
                  if (allergy == '없음') {
                    _selectedAllergies.clear();
                    _selectedAllergies.add('없음');
                    _showOtherAllergyInput = false;
                    _otherAllergyController.clear();
                  } else if (allergy == '기타') {
                    _selectedAllergies.remove('없음');
                    if (isSelected) {
                      _selectedAllergies.remove(allergy);
                      _showOtherAllergyInput = false;
                      _otherAllergyController.clear();
                    } else {
                      _selectedAllergies.add(allergy);
                      _showOtherAllergyInput = true;
                    }
                  } else {
                    _selectedAllergies.remove('없음');
                    if (isSelected) {
                      _selectedAllergies.remove(allergy);
                    } else {
                      _selectedAllergies.add(allergy);
                    }
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1) 
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  allergy,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_showOtherAllergyInput) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _otherAllergyController,
            decoration: InputDecoration(
              hintText: '기타 알레르기를 입력하세요',
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// 전화번호 포맷터 (010으로만 시작 가능)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 첫 번째 문자가 0이 아니면 거부
    if (newText.isNotEmpty && !newText.startsWith('0')) {
      return oldValue;
    }
    
    // 두 번째 문자가 1이 아니면 거부
    if (newText.length >= 2 && !newText.startsWith('01')) {
      return oldValue;
    }
    
    // 세 번째 문자가 0이 아니면 거부 (010만 허용)
    if (newText.length >= 3 && !newText.startsWith('010')) {
      return oldValue;
    }
    
    // 11자리 초과 제한
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }
    
    // 포맷팅
    if (newText.length <= 3) {
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else if (newText.length <= 7) {
      final formatted = '${newText.substring(0, 3)}-${newText.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (newText.length <= 11) {
      final formatted = '${newText.substring(0, 3)}-'
          '${newText.substring(3, newText.length > 7 ? 7 : newText.length)}'
          '${newText.length > 7 ? '-${newText.substring(7)}' : ''}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}