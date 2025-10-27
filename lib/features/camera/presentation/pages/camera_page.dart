import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/camera/presentation/controllers/camera_controller.dart';
import 'package:pillsnap/features/camera/presentation/widgets/camera_controls.dart';
import 'package:pillsnap/features/camera/presentation/widgets/camera_overlay.dart';
import 'package:pillsnap/features/camera/presentation/widgets/camera_guide_modal.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 카메라 페이지
class CameraPage extends ConsumerStatefulWidget {
  final bool isMultiMode;
  
  const CameraPage({
    super.key,
    this.isMultiMode = false,
  });
  
  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with SingleTickerProviderStateMixin {
  // 최초 진입인지 추적하는 static 변수
  static bool _hasShownGuideInSession = false;
  
  // 포커스 애니메이션
  Offset? _focusPoint;
  AnimationController? _focusAnimationController;
  Animation<double>? _focusAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 포커스 애니메이션 초기화
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 1.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusAnimationController!,
      curve: Curves.easeOut,
    ));
    
    // 세션당 한 번만 가이드 표시
    if (!_hasShownGuideInSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CameraGuideModal(isMultiMode: widget.isMultiMode).show(context);
          _hasShownGuideInSession = true;
        }
      });
    }
  }
  
  @override
  void dispose() {
    _focusAnimationController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final identificationData = ref.watch(drugIdentificationProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,  // 앱바 뒤로 body 확장
      body: cameraState.when(
        data: (state) {
          if (state.errorMessage != null) {
            return _buildErrorView(context, state.errorMessage!);
          }
          
          if (!state.isInitialized || state.controller == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          
          return Stack(
            children: [
              // 배경 (검은색)
              Container(color: Colors.black),
              
              // 카메라 프리뷰 (정사각형)
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0, // 1:1 정사각형 비율
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 카메라 프리뷰
                      ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 1,
                              height: state.controller!.value.aspectRatio,
                              child: CameraPreview(state.controller!),
                            ),
                          ),
                        ),
                      ),
                      
                      // 탭 감지 레이어
                      Positioned.fill(
                        child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (TapUpDetails details) async {
                          debugPrint('Camera tap at: ${details.localPosition}');
                          
                          // 카메라 컨트롤러 가져오기
                          final controller = state.controller;
                          if (controller == null || !controller.value.isInitialized) {
                            return;
                          }
                          
                          // 화면 크기 가져오기
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final Size size = renderBox.size;
                          
                          // 탭 위치를 0.0~1.0 범위로 정규화
                          final double x = details.localPosition.dx / size.width;
                          final double y = details.localPosition.dy / size.height;
                          
                          final Offset point = Offset(x, y);
                          debugPrint('Setting focus to: $point');
                          
                          // 포커스 포인트 표시
                          setState(() {
                            _focusPoint = details.localPosition;
                          });
                          
                          // 애니메이션 시작
                          unawaited(_focusAnimationController?.forward().then((_) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (mounted) {
                                setState(() {
                                  _focusPoint = null;
                                });
                                _focusAnimationController?.reset();
                              }
                            });
                          }) ?? Future.value());
                          
                          try {
                            // camera notifier의 setFocusPoint 사용하여 실제로 작동하게 함
                            await ref.read(cameraProvider.notifier).setFocusPoint(point);
                          } catch (e) {
                            debugPrint('Failed to set focus: $e');
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    
                    // 포커스 인디케이터
                    if (_focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 30,
                        top: _focusPoint!.dy - 30,
                        child: AnimatedBuilder(
                          animation: _focusAnimation!,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _focusAnimation!.value,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.yellow,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 카메라 오버레이
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CameraOverlay(
                            isMultiMode: widget.isMultiMode,
                            pillCount: state.pillCount,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 하단 컨트롤
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black,
                  child: CameraControls(
                    currentZoom: state.currentZoom,
                    onZoomChanged: (zoom) {
                      ref.read(cameraProvider.notifier).setZoom(zoom);
                    },
                    onCapture: () async {
                      // 단일 모드에서는 ROI 포함 촬영
                      if (!widget.isMultiMode) {
                        final result = await ref.read(cameraProvider.notifier).takePictureWithROI(isMultiMode: false);
                        if (result != null && context.mounted) {
                          final mainPath = result['main'];
                          final roiPath = result['roi'];
                          // ROI 경로도 함께 전달
                          final queryParams = 'path=$mainPath&mode=single${roiPath != null ? '&roi=$roiPath' : ''}';
                          await context.push('/camera/confirm?$queryParams');
                        }
                      } else {
                        // 다중 모드에서는 기존 방식
                        final path = await ref.read(cameraProvider.notifier).takePicture();
                        if (path != null && context.mounted) {
                          await context.push('/camera/confirm?path=$path&mode=multi');
                        }
                      }
                    },
                    isCapturing: state.isCapturing,
                    isMultiMode: widget.isMultiMode,
                    pillCount: state.pillCount,
                    onPillCountChanged: (count) {
                      ref.read(cameraProvider.notifier).setPillCount(count);
                    },
                    isFlashOn: state.isFlashOn,
                    onFlashToggle: () {
                      ref.read(cameraProvider.notifier).toggleFlash();
                    },
                    onGalleryTap: () async {
                      // 갤러리에서 이미지 선택 (단일 모드에서는 ROI 포함)
                      if (!widget.isMultiMode) {
                        final result = await ref.read(cameraProvider.notifier).pickImageFromGallery(withROI: true);
                        if (result != null && context.mounted) {
                          if (result is Map<String, String>) {
                            // ROI 포함 결과
                            final mainPath = result['main'];
                            final roiPath = result['roi'];
                            final queryParams = 'path=$mainPath&mode=single${roiPath != null ? '&roi=$roiPath' : ''}';
                            await context.push('/camera/confirm?$queryParams');
                          } else {
                            // ROI 없는 결과 (fallback)
                            await context.push('/camera/confirm?path=$result&mode=single');
                          }
                        }
                      } else {
                        // 다중 모드에서는 기존 방식
                        final path = await ref.read(cameraProvider.notifier).pickImageFromGallery();
                        if (path != null && context.mounted) {
                          await context.push('/camera/confirm?path=$path&mode=multi');
                        }
                      }
                    },
                  ),
                ),
              ),
              
              // 상단 헤더
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                                onPressed: () => context.pop(),
                              ),
                              Expanded(
                                child: Text(
                                  '단일 약품 촬영',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline, color: Colors.white),
                                onPressed: () {
                                  CameraGuideModal(isMultiMode: widget.isMultiMode).show(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        // 식별 정보가 있을 때 표시
                        if (identificationData.completionScore > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: identificationData.estimatedAccuracy >= 80
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '예상 정확도: ${identificationData.estimatedAccuracy}%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 이미지 전처리 중 로딩 오버레이
              if (state.isProcessing)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '이미지 처리 중...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        error: (error, stack) => _buildErrorView(
          context, 
          '카메라를 시작할 수 없습니다.',
        ),
      ),
    );
  }
  
  Widget _buildErrorView(BuildContext context, String message) {
    final isPermissionError = message.contains('권한');
    final isPermanentlyDenied = message.contains('설정');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPermissionError ? Icons.camera_alt_outlined : Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isPermanentlyDenied) ...[
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('설정으로 이동'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextButton(
              onPressed: () {
                // go_router로 홈으로 이동 (카메라에서 왔음을 표시)
                context.go('/home', extra: 'camera');
              },
              child: Text(
                '홈으로 돌아가기',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}