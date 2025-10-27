import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/form_selection_step.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/shape_selection_step.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/color_selection_step.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/text_identification_step.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/mark_selection_step.dart';
import 'package:pillsnap/features/drug/presentation/widgets/identification_steps/line_selection_step.dart';

/// 약품 식별 정보 수집 플로우 페이지
class DrugIdentificationFlowPage extends ConsumerStatefulWidget {
  const DrugIdentificationFlowPage({super.key});

  @override
  ConsumerState<DrugIdentificationFlowPage> createState() =>
      _DrugIdentificationFlowPageState();
}

class _DrugIdentificationFlowPageState
    extends ConsumerState<DrugIdentificationFlowPage> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  bool _shouldFocusTextInput = false;

  @override
  void initState() {
    super.initState();
    // 식별 데이터 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drugIdentificationProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _proceedToCamera();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipStep() async {
    // 문자 입력 단계(4단계)에서 건너뛰기를 누른 경우
    if (_currentStep == 4) {
      // 현재 입력된 텍스트 확인
      final data = ref.read(drugIdentificationProvider);
      final hasTextInput =
          (data.textFront?.isNotEmpty ?? false) ||
          (data.textBack?.isNotEmpty ?? false);

      // 텍스트가 없는 경우 경고 팝업 표시
      if (!hasTextInput) {
        final result = await (Platform.isIOS
            ? showCupertinoDialog<bool>(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('문자 정보가 중요해요'),
                  content: const Text(
                    '문자 정보는 약품 식별에 가장 중요한 요소입니다.\n\n희미하게 보이는 문자라도 입력하면 AI가 더 정확하게 약을 찾을 수 있습니다.',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('건너뛰기'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('문자 입력하기'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              )
            : showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('문자 정보가 중요해요'),
                  content: const Text(
                    '문자 정보는 약품 식별에 가장 중요한 요소입니다.\n\n희미하게 보이는 문자라도 입력하면 AI가 더 정확하게 약을 찾을 수 있습니다.',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text(
                        '문자 입력하기',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ));

        // 문자 입력하기를 선택한 경우 건너뛰지 않고 포커스 설정
        if (result == true) {
          setState(() {
            _shouldFocusTextInput = true;
          });
          return;
        }
      }
    }

    _goToNextStep();
  }

  void _proceedToCamera() {
    // 카메라로 이동 (식별 데이터가 provider에 저장됨)
    context.push('/camera');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 스와이프로 뒤로가기 비활성화
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 뒤로가기 시도 시 처리
        if (_currentStep > 1) {
          _goToPreviousStep();
        } else {
          showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('약품 정보 입력'),
              content: const Text(
                '정보 입력을 중단하시겠습니까?\n입력한 정보가 모두 사라집니다.',
              ),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  child: const Text('중단'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true, // 키보드가 나올 때 화면 자동 조정
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              _currentStep > 1 ? Icons.arrow_back : Icons.close,
            ),
            onPressed: () {
              if (_currentStep > 1) {
                // 텍스트 입력 단계에서 뒤로갈 때 키보드 숨기기
                if (_currentStep == 4) {
                  FocusScope.of(context).unfocus();
                }
                _goToPreviousStep();
              } else {
                showCupertinoDialog<void>(
                  context: context,
                  builder: (BuildContext context) =>
                      CupertinoAlertDialog(
                        title: const Text('약품 정보 입력'),
                        content: const Text(
                          '정보 입력을 중단하시겠습니까?\n입력한 정보가 모두 사라집니다.',
                        ),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('취소'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                              context.pop();
                            },
                            child: const Text('중단'),
                          ),
                        ],
                      ),
                );
              }
            },
          ),
          title: Text(
            '약품 정보 입력',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _currentStep < 6 ? _skipStep : null,
              child: Text(
                _currentStep < 6 ? '건너뛰기' : '',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 프로그레스 바
            _buildProgressBar(),
            // 단계별 컨텐츠
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FormSelectionStep(
                    onNext: _goToNextStep,
                    onBack: () => context.pop(),
                  ),
                  ShapeSelectionStep(
                    onNext: _goToNextStep,
                    onBack: _goToPreviousStep,
                  ),
                  ColorSelectionStep(
                    onNext: _goToNextStep,
                    onBack: _goToPreviousStep,
                  ),
                  TextIdentificationStep(
                    onNext: () {
                      setState(() {
                        _shouldFocusTextInput = false;
                      });
                      _goToNextStep();
                    },
                    onBack: () {
                      // 키보드 숨기기
                      FocusScope.of(context).unfocus();
                      _goToPreviousStep();
                    },
                    shouldFocus: _shouldFocusTextInput,
                  ),
                  MarkSelectionStep(
                    onNext: _goToNextStep,
                    onBack: _goToPreviousStep,
                  ),
                  LineSelectionStep(
                    onNext: _goToNextStep,
                    onBack: _goToPreviousStep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: double.infinity,
      height: 3,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 3,
            color: AppColors.surfaceVariant,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width:
                MediaQuery.of(context).size.width *
                (_currentStep / 6),
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
