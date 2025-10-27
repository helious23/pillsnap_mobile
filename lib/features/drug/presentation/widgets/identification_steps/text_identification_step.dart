import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 식별 문자 입력 단계 (Step 4)
class TextIdentificationStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback? onSkip;
  final bool shouldFocus;

  const TextIdentificationStep({
    super.key,
    required this.onNext,
    required this.onBack,
    this.onSkip,
    this.shouldFocus = false,
  });

  @override
  ConsumerState<TextIdentificationStep> createState() =>
      _TextIdentificationStepState();
}

class _TextIdentificationStepState
    extends ConsumerState<TextIdentificationStep> {
  final _firstTextController = TextEditingController();
  final _secondTextController = TextEditingController();
  final _firstTextFocusNode = FocusNode();
  final _secondTextFocusNode = FocusNode();
  bool _hasNoText = false;
  bool _cantSeeText = false;
  bool _hasShownSkipWarning = false; // 건너뛰기 경고를 이미 보여줬는지 추적

  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    _firstTextController.text = data.textFront ?? '';
    _secondTextController.text = data.textBack ?? '';
  }

  @override
  void didUpdateWidget(TextIdentificationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // shouldFocus가 false에서 true로 변경된 경우
    if (!oldWidget.shouldFocus && widget.shouldFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _firstTextFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _firstTextController.dispose();
    _secondTextController.dispose();
    _firstTextFocusNode.dispose();
    _secondTextFocusNode.dispose();
    super.dispose();
  }

  void _handleNext() async {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();
    
    final hasTextInput =
        _firstTextController.text.isNotEmpty ||
        _secondTextController.text.isNotEmpty;
    final hasOption = _hasNoText || _cantSeeText;

    // 아무것도 입력하지 않고 옵션도 선택하지 않은 경우
    if (!hasTextInput && !hasOption && !_hasShownSkipWarning) {
      final shouldInputText = await _showTextImportanceDialog(true);
      if (shouldInputText) {
        // 문자 입력을 선택한 경우 - 첫 번째 텍스트 필드에 포커스
        Future.delayed(const Duration(milliseconds: 100), () {
          _firstTextFocusNode.requestFocus();
        });
        return;
      } else {
        // 계속 진행을 선택한 경우 - 다시는 경고를 보여주지 않음
        _hasShownSkipWarning = true;
      }
    }

    if (_hasNoText || _cantSeeText) {
      ref
          .read(drugIdentificationProvider.notifier)
          .updateTexts(front: null, back: null);
    } else {
      ref
          .read(drugIdentificationProvider.notifier)
          .updateTexts(
            front: _firstTextController.text.trim().isEmpty
                ? null
                : _firstTextController.text.trim(),
            back: _secondTextController.text.trim().isEmpty
                ? null
                : _secondTextController.text.trim(),
          );
    }
    widget.onNext();
  }

  Future<bool> _showTextImportanceDialog(bool isNoText) async {
    if (Platform.isIOS) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(isNoText ? '문자 정보가 중요해요' : '식별 문자를 확인해주세요'),
          content: Text(
            isNoText
                ? '\n문자 정보는 AI 약품 식별에\n 가장 중요한 요소입니다.\n\n희미하게 보이는 문자라도 입력할 경우 \n AI가 더 정확하게 약을 찾을 수 있습니다.'
                : '\n희미하게 보이는 문자라도 입력해주세요.\n부분적인 정보라도 AI가 분석하여 \n약품을 찾을 수 있습니다. \n가능한 모든 문자를 입력해주세요.',
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('계속 진행'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('문자 입력'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
      return result ?? false;
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isNoText ? '문자 정보가 중요해요' : '식별 문자를 확인해주세요'),
          content: Text(
            isNoText
                ? '\n문자 정보는 AI 약품 식별에\n 가장 중요한 요소입니다.\n\n희미하게 보이는 문자라도 입력할 경우 \n AI가 더 정확하게 약을 찾을 수 있습니다.'
                : '\n희미하게 보이는 문자라도 입력해주세요.\n부분적인 정보라도 AI가 분석하여 \n약품을 찾을 수 있습니다. \n가능한 모든 문자를 입력해주세요.',
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: Text(
                '계속 진행',
                style: TextStyle(color: Colors.red[600]),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                '문자 입력',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
      return result ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText =
        _firstTextController.text.isNotEmpty ||
        _secondTextController.text.isNotEmpty;
    final hasOptions = _hasNoText || _cantSeeText;

    return GestureDetector(
      onTap: () {
        // 키보드 숨기기
        FocusScope.of(context).unfocus();
      },
      child: BaseIdentificationStep(
        title: '약에 새겨진 문자나 숫자가 있나요?',
        subtitle: '식별 문자는 약품 검색의 가장 중요한 정보입니다',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 첫 번째 문자
              Text(
                '첫 번째 문자',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _firstTextController,
                focusNode: _firstTextFocusNode,
                textCapitalization: TextCapitalization.characters,
                enabled: !_hasNoText && !_cantSeeText,
                decoration: InputDecoration(
                  hintText: '예: A123, 타이레놀, ㄱㄴ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: (_hasNoText || _cantSeeText)
                      ? AppColors.surfaceVariant
                      : Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // 두 번째 문자 (선택)
              Text(
                '두 번째 문자 (선택)',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _secondTextController,
                focusNode: _secondTextFocusNode,
                textCapitalization: TextCapitalization.characters,
                enabled: !_hasNoText && !_cantSeeText,
                decoration: InputDecoration(
                  hintText: '예: 500mg, B12...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: (_hasNoText || _cantSeeText)
                      ? AppColors.surfaceVariant
                      : Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),
              // 옵션 버튼들
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      label: '문자가 없어요',
                      isSelected: _hasNoText,
                      onTap: () async {
                        if (!_hasNoText) {
                          // 다이얼로그 표시하고 결과 받기
                          final shouldInputText =
                              await _showTextImportanceDialog(true);
                          if (shouldInputText) {
                            // 문자 입력을 선택한 경우 - 첫 번째 텍스트 필드에 포커스
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _firstTextFocusNode.requestFocus();
                              },
                            );
                            return;
                          }
                        }
                        // 계속 진행을 선택했거나, 이미 선택된 경우 토글
                        setState(() {
                          _hasNoText = !_hasNoText;
                          if (_hasNoText) {
                            _cantSeeText = false;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildOptionButton(
                      label: '잘 안보여요',
                      isSelected: _cantSeeText,
                      onTap: () async {
                        if (!_cantSeeText) {
                          // 다이얼로그 표시하고 결과 받기
                          final shouldInputText =
                              await _showTextImportanceDialog(false);
                          if (shouldInputText) {
                            // 문자 입력을 선택한 경우 - 첫 번째 텍스트 필드에 포커스
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _firstTextFocusNode.requestFocus();
                              },
                            );
                            return;
                          }
                        }
                        // 계속 진행을 선택했거나, 이미 선택된 경우 토글
                        setState(() {
                          _cantSeeText = !_cantSeeText;
                          if (_cantSeeText) {
                            _hasNoText = false;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        onNext: () {
          _handleNext();
        },
        onReset: () {
          setState(() {
            _firstTextController.clear();
            _secondTextController.clear();
            _hasNoText = false;
            _cantSeeText = false;
          });
        },
        nextText: '다음',
        isNextEnabled: true,
        isResetEnabled: hasText || hasOptions,
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
