import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/identification_action_buttons.dart';

/// 약품 식별 정보 입력 화면의 하단 버튼 영역 위젯
class IdentificationBottomSheet extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onReset;
  final bool isNextEnabled;
  final bool isResetEnabled;
  final String? nextText;
  
  const IdentificationBottomSheet({
    super.key,
    required this.onNext,
    this.onReset,
    this.isNextEnabled = true,
    this.isResetEnabled = false,
    this.nextText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: IdentificationActionButtons(
        onNext: onNext,
        onReset: onReset,
        isNextEnabled: isNextEnabled,
        isResetEnabled: isResetEnabled,
        nextText: nextText ?? '다음',
      ),
    );
  }
}