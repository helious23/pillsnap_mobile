import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import '../../../../core/utils/structured_logger.dart';
import '../../data/services/macro_camera_service.dart';
import '../../domain/constants/upload_image_spec.dart';
import '../../domain/entities/processed_image_result.dart';
import '../../domain/exceptions/processing_exception.dart';

/// 업로드 이미지 표준 규격 (프론트-BFF-추론서버 공통 계약)
/// 
/// 프론트엔드 책임:
/// - 카메라/갤러리 원본을 표준 규격으로 변환
/// - 긴 변 2048px, JPEG Q95, EXIF→픽셀, 메타데이터 제거
/// - 업로드 단위: /tmp/upload_ready_*.jpg
/// 
/// 서버 책임:
/// - 분류: center-crop(768x768) + ImageNet 정규화
/// - 감지: letterbox(1024x1024, stride=32) + 패딩
const int kMinLongEdge = UploadImageSpec.minLongEdge;
const int kDesiredLongEdge = UploadImageSpec.targetLongEdge;
const int kMaxLongEdge = UploadImageSpec.maxLongEdge;
const int kJpegQuality = UploadImageSpec.jpegQuality;

// Isolate로 전달할 이미지 처리 파라미터
class _ImageProcessParams {
  final String imagePath;
  final int desiredLongEdge;
  final int minLongEdge;
  final int maxLongEdge;
  final int quality;
  final String traceId;
  
  _ImageProcessParams({
    required this.imagePath,
    required this.desiredLongEdge,
    required this.minLongEdge,
    required this.maxLongEdge,
    required this.quality,
    required this.traceId,
  });
}

/// Isolate에서 실행될 이미지 처리 함수 (top-level 함수여야 함)
/// 
/// 전처리 단계:
/// 1. 파일 바이트 로드 & 디코드
/// 2. EXIF Orientation을 픽셀에 반영 (bakeOrientation)
/// 3. 비율 유지 다운스케일 (업스케일 금지)
/// 4. JPEG 재인코딩 (Q=95, 메타데이터 제거)
/// 5. 임시 파일 저장 (/tmp/upload_ready_*.jpg)
/// 
/// @return ProcessedImageResult 전처리 결과 메타데이터
/// @throws ProcessingException 전처리 실패 시
Future<ProcessedImageResult> _processImageInIsolate(_ImageProcessParams params) async {
  try {
    // 1. 파일 바이트 로드 & 디코드
    final originalFile = File(params.imagePath);
    final originalSize = await originalFile.length();
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw ProcessingException(
        'Failed to decode image',
        originalPath: params.imagePath,
        metadata: {'reason': 'decode_failed'},
      );
    }
    
    // SHA256 해시 계산 (디버깅용, 앞 12자만)
    final hash = sha256.convert(bytes);
    final hashPrefix = hash.toString().substring(0, 12);
    
    final originalWidth = image.width;
    final originalHeight = image.height;
    
    // 구조화된 로깅
    StructuredLogger.logImageProcessing(
      traceId: params.traceId,
      phase: 'original',
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      originalSize: originalSize,
    );
    
    // 2. EXIF 회전 반영 (픽셀에 회전 적용)
    final beforeExifWidth = image.width;
    final beforeExifHeight = image.height;
    image = img.bakeOrientation(image);
    final exifFixed = (image.width != beforeExifWidth || image.height != beforeExifHeight);
    
    if (exifFixed) {
      StructuredLogger.logImageProcessing(
        traceId: params.traceId,
        phase: 'exif_fixed',
        processedWidth: image.width,
        processedHeight: image.height,
        exifFixed: true,
      );
    }
    
    // 3. 비율 유지 다운스케일 (업스케일 금지)
    final longEdge = image.width > image.height ? image.width : image.height;
    
    bool needsResize = false;
    int targetLongEdge = longEdge;
    String resizeDecision = '';
    
    // maxLongEdge 초과시 강제 축소
    if (longEdge > params.maxLongEdge) {
      targetLongEdge = params.maxLongEdge;
      needsResize = true;
      resizeDecision = 'too_large';
    } 
    // desiredLongEdge 초과시 권장 크기로 축소 (대부분의 케이스)
    else if (longEdge > params.desiredLongEdge) {
      targetLongEdge = params.desiredLongEdge;
      needsResize = true;
      resizeDecision = 'larger_than_desired';
    }
    // minLongEdge 미만시 원본 유지 (업스케일 금지)
    else if (longEdge < params.minLongEdge) {
      needsResize = false;
      resizeDecision = 'too_small_keep_original';
    } else {
      needsResize = false;
      resizeDecision = 'size_ok';
    }
    
    StructuredLogger.logImageProcessing(
      traceId: params.traceId,
      phase: 'resize_decision',
      decision: resizeDecision,
      originalWidth: image.width,
      originalHeight: image.height,
    );
    
    // 리사이징 수행
    double scaleFactor = 1.0;
    if (needsResize) {
      scaleFactor = targetLongEdge / longEdge;
      final newWidth = (image.width * scaleFactor).round();
      final newHeight = (image.height * scaleFactor).round();
      
      image = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic, // 고품질 보간
      );
      
      StructuredLogger.logImageProcessing(
        traceId: params.traceId,
        phase: 'resized',
        processedWidth: image.width,
        processedHeight: image.height,
        scaleFactor: scaleFactor,
        wasResized: true,
      );
    }
    
    // 4. JPEG 인코딩 (sRGB, 메타 제거)
    final encodedBytes = img.encodeJpg(image, quality: params.quality);
    
    // 5. 임시 파일로 저장 (업로드 단위)
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final processedFile = File('${tempDir.path}/upload_ready_$timestamp.jpg');
    await processedFile.writeAsBytes(encodedBytes, flush: true);
    
    final processedSize = encodedBytes.length;
    
    // 최종 로그
    String? warning;
    if (image.width < 640 || image.height < 640) {
      warning = 'Image too small (<640px), detection may fail';
    }
    
    StructuredLogger.logImageProcessing(
      traceId: params.traceId,
      phase: 'final',
      processedWidth: image.width,
      processedHeight: image.height,
      processedSize: processedSize,
      wasResized: needsResize,
      scaleFactor: scaleFactor,
      exifFixed: exifFixed,
      warning: warning,
    );
    
    // 압축률 정보
    if (needsResize || originalSize != processedSize) {
      final compressionRatio = ((1 - processedSize / originalSize) * 100);
      StructuredLogger.log(
        stage: 'compression',
        traceId: params.traceId,
        data: {
          'originalSize': originalSize,
          'processedSize': processedSize,
          'compressionRatio': '${compressionRatio.toStringAsFixed(1)}%',
        },
      );
    }
    
    // 결과 메타데이터 생성
    return ProcessedImageResult(
      path: processedFile.path,
      width: image.width,
      height: image.height,
      fileSize: processedSize,
      hash: hashPrefix,
      wasResized: needsResize,
      scaleFactor: scaleFactor,
      exifFixed: exifFixed,
      processedAt: DateTime.now(),
      traceId: params.traceId,
    );
    
  } catch (e) {
    // 명시적 예외 처리
    if (e is ProcessingException) {
      rethrow;
    }
    
    StructuredLogger.logError(
      traceId: params.traceId,
      stage: 'image_processing',
      error: e.toString(),
      additionalData: {
        'originalPath': params.imagePath,
      },
    );
    
    throw ProcessingException(
      'Image processing failed: $e',
      originalPath: params.imagePath,
      metadata: {
        'error': e.toString(),
        'traceId': params.traceId,
      },
    );
  }
}

/// 사용 가능한 카메라 목록
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

/// 카메라 권한 상태
final cameraPermissionProvider = FutureProvider<bool>((ref) async {
  final status = await Permission.camera.request();
  return status.isGranted;
});


/// 카메라 상태 관리
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isCapturing;
  final bool isProcessing; // 이미지 전처리 중
  final double currentZoom;
  final bool isFlashOn;
  final String? errorMessage;
  final int pillCount; // 여러 약품 촬영 시 약품 개수
  final Offset? lastFocusPoint; // 마지막 탭 포커스 좌표
  // final MacroCameraInfo? macroCameraInfo; // iOS 매크로 카메라 정보 (임시 비활성화)
  // final bool isMacroModeActive; // 매크로 모드 활성화 여부 (임시 비활성화)
  
  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isCapturing = false,
    this.isProcessing = false,
    this.currentZoom = 1.0,
    this.isFlashOn = false,
    this.errorMessage,
    this.pillCount = 2,
    this.lastFocusPoint,
    // this.macroCameraInfo,
    // this.isMacroModeActive = false,
  });
  
  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isCapturing,
    bool? isProcessing,
    double? currentZoom,
    bool? isFlashOn,
    String? errorMessage,
    int? pillCount,
    Offset? lastFocusPoint,
    // MacroCameraInfo? macroCameraInfo,
    // bool? isMacroModeActive,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      isProcessing: isProcessing ?? this.isProcessing,
      currentZoom: currentZoom ?? this.currentZoom,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      errorMessage: errorMessage ?? this.errorMessage,
      pillCount: pillCount ?? this.pillCount,
      lastFocusPoint: lastFocusPoint ?? this.lastFocusPoint,
      // macroCameraInfo: macroCameraInfo ?? this.macroCameraInfo,
      // isMacroModeActive: isMacroModeActive ?? this.isMacroModeActive,
    );
  }
}

/// 카메라 컨트롤러
class CameraNotifier extends AsyncNotifier<CameraState> {
  final MacroCameraService _macroService = MacroCameraService();
  String? _nativeCameraId; // iOS 네이티브 카메라 ID
  
  /// 근접 촬영에 최적화된 카메라 선택
  Future<CameraDescription?> _selectBestCameraForMacro(List<CameraDescription> cameras) async {
    debugPrint('[Camera] Available cameras: ${cameras.length}');
    
    for (int i = 0; i < cameras.length; i++) {
      final camera = cameras[i];
      debugPrint('[Camera] Camera $i: ${camera.name}, Direction: ${camera.lensDirection}');
      
      if (camera.lensDirection == CameraLensDirection.back) {
        // iOS: Wide 렌즈 우선 (Telephoto, Ultra Wide 제외)
        if (Platform.isIOS) {
          final nameLower = camera.name.toLowerCase();
          if (!nameLower.contains('telephoto') && 
              !nameLower.contains('ultra') &&
              !nameLower.contains('tele')) {
            debugPrint('[Camera] Selected for macro (iOS): ${camera.name}');
            return camera;
          }
        } else {
          // Android: 첫 번째 후면 카메라가 보통 메인
          debugPrint('[Camera] Selected main camera (Android): ${camera.name}');
          return camera;
        }
      }
    }
    
    // Fallback: 첫 번째 후면 카메라
    return cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }
  @override
  Future<CameraState> build() async {
    // 권한 상태 확인
    var status = await Permission.camera.status;
    debugPrint('Camera permission status: $status');
    
    // 권한이 아직 요청되지 않았거나 거부된 경우
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        // 영구 거부된 경우
        return const CameraState(
          errorMessage: '카메라 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
        );
      }
      
      // 권한 요청
      debugPrint('Requesting camera permission...');
      status = await Permission.camera.request();
      debugPrint('Camera permission result: $status');
      
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          return const CameraState(
            errorMessage: '카메라 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
          );
        }
        return const CameraState(
          errorMessage: '카메라 권한이 필요합니다.\n권한을 허용해주세요.',
        );
      }
    }
    
    // 카메라 초기화
    try {
      // iOS: 매크로 카메라 정보
      MacroCameraInfo? macroInfo;
      if (Platform.isIOS) {
        debugPrint('[Camera Init] Checking native macro capabilities...');
        macroInfo = await _macroService.selectBestCameraForMacro();
        if (macroInfo != null) {
          _nativeCameraId = macroInfo.deviceId;
          debugPrint('[Camera Init] Native macro camera found: ${macroInfo.deviceId}');
          debugPrint('[Camera Init] Supports macro: ${macroInfo.supportsMacro}');
          debugPrint('[Camera Init] Min focus: ${macroInfo.minimumFocusDistance}cm');
        }
      }
      
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraState(
          errorMessage: '사용 가능한 카메라가 없습니다.',
        );
      }
      
      // 근접 촬영용 최적 카메라 선택
      final selectedCamera = await _selectBestCameraForMacro(cameras) ?? cameras.first;
      debugPrint('[Camera Init] Using camera: ${selectedCamera.name}');
      
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.max,  // 최대 해상도로 변경
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,  // JPEG 직접 지정
      );
      
      await controller.initialize();
      
      // 근접 촬영 최적화 설정
      try {
        // 포커스 모드: 연속 자동 초점
        await controller.setFocusMode(FocusMode.auto);
        debugPrint('[Camera Init] Focus mode set to auto');
        
        // 노출: 자동 (매크로에 적합)
        await controller.setExposureMode(ExposureMode.auto);
        debugPrint('[Camera Init] Exposure mode set to auto');
        
        // 줌: 1.0x 고정 (디지털 줌 비활성화)
        await controller.setZoomLevel(1.0);
        
        // iOS 전용 설정
        if (Platform.isIOS) {
          // 중앙 포커스로 시작
          await controller.setFocusPoint(const Offset(0.5, 0.5));
          await controller.setExposurePoint(const Offset(0.5, 0.5));
          
          // 줌 범위 확인 및 최적 줌 설정
          final minZoom = await controller.getMinZoomLevel();
          final maxZoom = await controller.getMaxZoomLevel();
          debugPrint('[Camera Init] iOS zoom range: $minZoom - $maxZoom');
          
          // 근접 촬영을 위한 미세 줌 조정 (1.0x ~ 1.2x 범위)
          // 약간의 줌인이 더 선명한 촬영을 가능하게 함
          if (maxZoom >= 1.2) {
            await controller.setZoomLevel(1.1);
            debugPrint('[Camera Init] Macro zoom set to 1.1x for better clarity');
          }
          
          // 네이티브 매크로 모드 활성화
          if (_nativeCameraId != null) {
            final macroConfigured = await _macroService.configureMacroMode(_nativeCameraId!);
            debugPrint('[Camera Init] Native macro mode configured: $macroConfigured');
          }
          
          debugPrint('[Camera Init] iOS macro mode configured');
        }
        
        debugPrint('[Camera Init] Macro optimizations applied');
      } catch (e) {
        debugPrint('[Camera Init] Optimization warning: $e');
      }
      
      // Dispose 시 컨트롤러 정리
      ref.onDispose(() {
        controller.dispose();
      });
      
      return CameraState(
        controller: controller,
        isInitialized: true,
        currentZoom: 1.0,
        // macroCameraInfo: macroInfo,
        // isMacroModeActive: macroInfo != null && macroInfo.supportsMacro,
      );
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      return CameraState(
        errorMessage: '카메라 초기화 실패: $e',
      );
    }
  }
  
  /// 사진 촬영 (렌즈 보정 로직 포함)
  Future<String?> takePicture() async {
    final currentState = state.valueOrNull;
    if (currentState == null || 
        currentState.controller == null || 
        !currentState.isInitialized) {
      return null;
    }
    
    if (currentState.isCapturing || currentState.isProcessing) return null;
    
    
    // 포커스 설정 및 안정화
    if (currentState.lastFocusPoint == null) {
      debugPrint('[Capture] No focus point set, using center');
      await setFocusPoint(const Offset(0.5, 0.5));
    } else if (Platform.isIOS) {
      // iOS: 촬영 직전 포커스 락
      try {
        debugPrint('[Capture] Locking focus before capture');
        await currentState.controller!.setFocusMode(FocusMode.locked);
        await currentState.controller!.setFocusPoint(currentState.lastFocusPoint!);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('[Capture] Focus lock failed: $e');
      }
    }
    
    state = AsyncValue.data(
      currentState.copyWith(isCapturing: true),
    );
    
    try {
      final XFile photo = await currentState.controller!.takePicture();
      
      // iOS: 포커스 모드 복원
      if (Platform.isIOS) {
        try {
          await currentState.controller!.setFocusMode(FocusMode.auto);
          debugPrint('[Capture] Focus mode restored to auto');
        } catch (e) {
          debugPrint('[Capture] Focus restore failed: $e');
        }
      }
      
      // 전처리 시작 - 로딩 표시
      state = AsyncValue.data(
        currentState.copyWith(
          isCapturing: false,
          isProcessing: true,
        ),
      );
      
      // EXIF 반영 + 비율 유지 다운스케일 + 고품질 JPEG 인코딩
      final processedResult = await _prepareJpegForUpload(photo.path);
      
      // 플래시가 켜져 있었다면 촬영 후 자동으로 끄기
      if (currentState.isFlashOn) {
        try {
          await currentState.controller!.setFlashMode(FlashMode.off);
          state = AsyncValue.data(
            currentState.copyWith(
              isProcessing: false,
              isFlashOn: false,  // 플래시 상태도 false로 변경
            ),
          );
        } catch (e) {
          debugPrint('플래시 끄기 실패: $e');
          state = AsyncValue.data(
            currentState.copyWith(isProcessing: false),
          );
        }
      } else {
        state = AsyncValue.data(
          currentState.copyWith(isProcessing: false),
        );
      }
      
      return processedResult.path;
    } catch (e) {
      // 구조화된 에러 로깅
      final traceId = StructuredLogger.generateTraceId();
      StructuredLogger.logError(
        traceId: traceId,
        stage: 'camera_capture',
        error: e.toString(),
      );
      
      String errorMessage = '사진 촬영 실패';
      if (e is ProcessingException) {
        errorMessage = e.message;
      }
      
      state = AsyncValue.data(
        currentState.copyWith(
          isCapturing: false,
          isProcessing: false,
          errorMessage: errorMessage,
        ),
      );
      return null;
    }
  }
  
  /// ROI (Region of Interest) 생성 - 중앙 512px 정사각형
  /// - 단일 촬영 모드에서 분류 정확도 향상을 위해 사용
  /// - 흰색 배경의 알약 등 저대비 상황에서 효과적
  Future<String?> _generateROI(String imagePath, {int targetSize = 512}) async {
    try {
      debugPrint('[ROI Generation] Starting for: $imagePath');
      
      // 이미지 읽기
      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        debugPrint('[ROI Generation] Failed to decode image');
        return null;
      }
      
      // EXIF 회전 정보 처리
      image = img.bakeOrientation(image);
      debugPrint('[ROI Generation] Image size after EXIF: ${image.width}x${image.height}');
      
      // 중앙 정사각형 크롭
      final cropSize = image.width < image.height ? image.width : image.height;
      final offsetX = (image.width - cropSize) ~/ 2;
      final offsetY = (image.height - cropSize) ~/ 2;
      
      var roiImage = img.copyCrop(
        image,
        x: offsetX,
        y: offsetY,
        width: cropSize,
        height: cropSize,
      );
      
      debugPrint('[ROI Generation] Cropped to: ${roiImage.width}x${roiImage.height}');
      
      // 512px로 리사이즈 (업스케일 또는 다운스케일)
      if (roiImage.width != targetSize) {
        roiImage = img.copyResize(
          roiImage,
          width: targetSize,
          height: targetSize,
          interpolation: img.Interpolation.cubic,
        );
        debugPrint('[ROI Generation] Resized to: ${roiImage.width}x${roiImage.height}');
      }
      
      // 임시 파일로 저장 (고품질 JPEG)
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final roiFile = File('${tempDir.path}/roi_$timestamp.jpg');
      await roiFile.writeAsBytes(
        img.encodeJpg(roiImage, quality: 95)  // Q95 유지
      );
      
      debugPrint('[ROI Generation] Saved to: ${roiFile.path}');
      final fileSize = await roiFile.length();
      debugPrint('[ROI Generation] File size: ${(fileSize / 1024).toStringAsFixed(1)}KB');
      
      return roiFile.path;
    } catch (e) {
      debugPrint('[ROI Generation] Error: $e');
      return null;
    }
  }
  
  /// EXIF 반영 + 비율 유지 다운스케일 + 고품질 JPEG 인코딩
  /// 
  /// 업로드 단위 생성:
  /// - 카메라 원본(4032x3024 등) → 표준 규격(2048px) → /tmp/upload_ready_*.jpg
  /// - 모든 이미지는 이 파이프라인을 통과하여 일관된 형식으로 업로드
  /// 
  /// @return ProcessedImageResult 전처리 결과 메타데이터
  /// @throws ProcessingException 전처리 실패 시
  Future<ProcessedImageResult> _prepareJpegForUpload(
    String imagePath, {
    int desiredLongEdge = kDesiredLongEdge,
    int minLongEdge = kMinLongEdge,
    int maxLongEdge = kMaxLongEdge,
    int quality = kJpegQuality,
    String? traceId,
  }) async {
    // 추적 ID 생성 (전달되지 않으면 새로 생성)
    final tid = traceId ?? StructuredLogger.generateTraceId();
    
    // Isolate로 전달할 파라미터 묶음
    final params = _ImageProcessParams(
      imagePath: imagePath,
      desiredLongEdge: desiredLongEdge,
      minLongEdge: minLongEdge,
      maxLongEdge: maxLongEdge,
      quality: quality,
      traceId: tid,
    );
    
    try {
      // compute를 사용하여 별도 스레드에서 처리
      final result = await compute(_processImageInIsolate, params);
      
      // 결과 로그
      StructuredLogger.log(
        stage: 'upload_prep_complete',
        traceId: tid,
        data: result.toJson(),
      );
      
      return result;
    } catch (e) {
      // 에러 로깅 및 재스로우
      StructuredLogger.logError(
        traceId: tid,
        stage: 'upload_prep_failed',
        error: e.toString(),
        additionalData: {'imagePath': imagePath},
      );
      
      if (e is ProcessingException) {
        rethrow;
      }
      
      throw ProcessingException(
        'Failed to prepare image for upload',
        originalPath: imagePath,
        metadata: {'error': e.toString(), 'traceId': tid},
      );
    }
  }
  
  /// 줌 레벨 변경 (실제 작동 버전)
  Future<void> setZoom(double zoom) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isInitialized) return;
    
    try {
      await currentState.controller!.setZoomLevel(zoom);
      state = AsyncValue.data(
        currentState.copyWith(currentZoom: zoom),
      );
    } catch (e) {
      debugPrint('줌 설정 실패: $e');
    }
  }
  
  /// 약품 개수 설정 (여러 약품 모드)
  void setPillCount(int count) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    state = AsyncValue.data(
      currentState.copyWith(pillCount: count),
    );
  }
  
  /// 플래시 토글
  Future<void> toggleFlash() async {
    final currentState = state.valueOrNull;
    if (currentState?.controller == null) return;
    
    try {
      final newFlashMode = currentState!.isFlashOn 
          ? FlashMode.off 
          : FlashMode.torch;
      
      await currentState.controller!.setFlashMode(newFlashMode);
      
      state = AsyncValue.data(
        currentState.copyWith(isFlashOn: !currentState.isFlashOn),
      );
    } catch (e) {
      debugPrint('플래시 설정 실패: $e');
    }
  }
  
  /// 탭하여 포커스 설정 (개선된 버전)
  Future<void> setFocusPoint(Offset point) async {
    final currentState = state.valueOrNull;
    if (currentState?.controller == null || !currentState!.isInitialized) return;
    
    try {
      // 포커스/노출 포인트 설정
      await currentState.controller!.setFocusPoint(point);
      await currentState.controller!.setExposurePoint(point);
      
      // iOS: 네이티브 매크로 포커스 설정
      if (Platform.isIOS && _nativeCameraId != null) {
        await _macroService.setMacroFocus(_nativeCameraId!, point.dx, point.dy);
        debugPrint('[Focus] Native macro focus set');
      }
      
      // iOS: 포커스 리셋으로 정확도 향상
      if (Platform.isIOS) {
        try {
          await currentState.controller!.setFocusMode(FocusMode.locked);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await currentState.controller!.setFocusMode(FocusMode.auto);
          debugPrint('[Focus] Reset to continuous autofocus at $point');
        } catch (e) {
          debugPrint('[Focus] Mode reset skipped: $e');
        }
      }
      
      // 포커스 안정화 대기 시간 증가 (200ms → 500ms)
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      // 마지막 포커스 포인트 저장
      state = AsyncValue.data(
        currentState.copyWith(lastFocusPoint: point),
      );
      
      debugPrint('[Focus] Set to $point and stabilized');
    } catch (e) {
      debugPrint('포커스 설정 실패: $e');
    }
  }
  
  /// 사진 촬영 (ROI 포함 - 단일 모드용)
  /// 메인 이미지와 ROI를 모두 반환
  Future<Map<String, String>?> takePictureWithROI({bool isMultiMode = false}) async {
    final currentState = state.valueOrNull;
    if (currentState == null || 
        currentState.controller == null || 
        !currentState.isInitialized) {
      return null;
    }
    
    if (currentState.isCapturing || currentState.isProcessing) return null;
    
    
    // 포커스 설정 및 안정화
    if (currentState.lastFocusPoint == null) {
      debugPrint('[Capture] No focus point set, using center');
      await setFocusPoint(const Offset(0.5, 0.5));
    } else if (Platform.isIOS) {
      // iOS: 촬영 직전 포커스 락
      try {
        debugPrint('[Capture] Locking focus before capture');
        await currentState.controller!.setFocusMode(FocusMode.locked);
        await currentState.controller!.setFocusPoint(currentState.lastFocusPoint!);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('[Capture] Focus lock failed: $e');
      }
    }
    
    state = AsyncValue.data(
      currentState.copyWith(isCapturing: true),
    );
    
    try {
      final XFile photo = await currentState.controller!.takePicture();
      
      // iOS: 포커스 모드 복원
      if (Platform.isIOS) {
        try {
          await currentState.controller!.setFocusMode(FocusMode.auto);
          debugPrint('[Capture] Focus mode restored to auto');
        } catch (e) {
          debugPrint('[Capture] Focus restore failed: $e');
        }
      }
      
      // 전처리 시작 - 로딩 표시
      state = AsyncValue.data(
        currentState.copyWith(
          isCapturing: false,
          isProcessing: true,
        ),
      );
      
      // 메인 이미지 전처리
      final processedResult = await _prepareJpegForUpload(photo.path);
      
      // 단일 모드인 경우 ROI 생성 (기본 비활성화, 필요시만)
      String? roiPath;
      if (!isMultiMode && _shouldGenerateROI()) {
        debugPrint('[Camera] Single mode with low confidence - generating ROI');
        roiPath = await _generateROI(processedResult.path);
        if (roiPath != null) {
          StructuredLogger.log(
            stage: 'roi_generated',
            traceId: processedResult.traceId,
            data: {'roiPath': roiPath, 'mainPath': processedResult.path},
          );
        } else {
          debugPrint('[Camera] ROI generation failed, continuing with main image only');
        }
      }
      
      // 플래시가 켜져 있었다면 촬영 후 자동으로 끄기
      if (currentState.isFlashOn) {
        try {
          await currentState.controller!.setFlashMode(FlashMode.off);
          state = AsyncValue.data(
            currentState.copyWith(
              isProcessing: false,
              isFlashOn: false,
            ),
          );
        } catch (e) {
          debugPrint('플래시 끄기 실패: $e');
          state = AsyncValue.data(
            currentState.copyWith(isProcessing: false),
          );
        }
      } else {
        state = AsyncValue.data(
          currentState.copyWith(isProcessing: false),
        );
      }
      
      return {
        'main': processedResult.path,
        if (roiPath != null) 'roi': roiPath,
      };
    } catch (e) {
      // 구조화된 에러 로깅
      final traceId = StructuredLogger.generateTraceId();
      StructuredLogger.logError(
        traceId: traceId,
        stage: 'camera_capture_with_roi',
        error: e.toString(),
      );
      
      String errorMessage = '사진 촬영 실패';
      if (e is ProcessingException) {
        errorMessage = e.message;
      }
      
      state = AsyncValue.data(
        currentState.copyWith(
          isCapturing: false,
          isProcessing: false,
          errorMessage: errorMessage,
        ),
      );
      return null;
    }
  }
  
  /// ROI 생성 여부 결정 (기본 false)
  /// TODO: 서버 응답 기반으로 저신뢰 폴백 로직 구현
  bool _shouldGenerateROI() {
    // 현재는 항상 false (네트워크 비용 절감)
    // 향후: 감지 conf < 0.35 또는 분류 prob < 0.65일 때 true
    return false;
  }
  
  // /// 매크로 모드 토글 (임시 비활성화)
  // Future<void> toggleMacroMode() async {
  //   final currentState = state.valueOrNull;
  //   if (currentState == null || !Platform.isIOS || _nativeCameraId == null) return;
  //   
  //   final newMacroState = !currentState.isMacroModeActive;
  //   
  //   if (newMacroState) {
  //     // 매크로 모드 활성화
  //     await _macroService.configureMacroMode(_nativeCameraId!);
  //     debugPrint('[Camera] Macro mode activated');
  //   } else {
  //     // 일반 모드로 전환
  //     try {
  //       await currentState.controller!.setFocusMode(FocusMode.auto);
  //       debugPrint('[Camera] Switched to normal mode');
  //     } catch (e) {
  //       debugPrint('[Camera] Error switching mode: $e');
  //     }
  //   }
  //   
  //   state = AsyncValue.data(
  //     currentState.copyWith(isMacroModeActive: newMacroState),
  //   );
  // }
  // 
  // /// 디바이스 매크로 기능 확인
  // Future<MacroCapabilities?> checkMacroCapabilities() async {
  //   if (!Platform.isIOS) return null;
  //   
  //   final capabilities = await _macroService.getMacroCapabilities();
  //   debugPrint('[Camera] Device: ${capabilities.deviceModel}');
  //   debugPrint('[Camera] Macro support: ${capabilities.supportsMacroMode}');
  //   debugPrint('[Camera] Min focus: ${capabilities.minimumFocusDistance}cm');
  //   
  //   return capabilities;
  // }
  
  /// 갤러리에서 이미지 선택 (ROI 포함 옵션)
  Future<dynamic> pickImageFromGallery({bool withROI = false}) async {
    final currentState = state.valueOrNull;
    
    // 이미 처리 중이면 무시
    if (currentState != null && currentState.isProcessing) return null;
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // imageQuality 파라미터 제거 - 원본 품질 보존
        // 어차피 _prepareJpegForUpload에서 일관된 인코딩 수행
      );
      
      if (image != null) {
        debugPrint('Gallery image selected: ${image.path}');
        
        // 전처리 시작 - 로딩 표시
        if (currentState != null) {
          state = AsyncValue.data(
            currentState.copyWith(isProcessing: true),
          );
        }
        
        // 메인 이미지 전처리
        final processedResult = await _prepareJpegForUpload(image.path);
        
        // ROI 생성 (옵션 - 기본 비활성화)
        String? roiPath;
        if (withROI && _shouldGenerateROI()) {
          debugPrint('[Gallery] Generating ROI for single mode');
          roiPath = await _generateROI(processedResult.path);
          if (roiPath != null) {
            StructuredLogger.log(
              stage: 'gallery_roi_generated',
              traceId: processedResult.traceId,
              data: {'roiPath': roiPath, 'mainPath': processedResult.path},
            );
          } else {
            debugPrint('[Gallery] ROI generation failed, continuing with main image only');
          }
        }
        
        // 전처리 완료 - 로딩 해제
        if (currentState != null) {
          state = AsyncValue.data(
            currentState.copyWith(isProcessing: false),
          );
        }
        
        // ROI가 있으면 Map으로 반환, 없으면 String 반환
        if (withROI && roiPath != null) {
          return {
            'main': processedResult.path,
            'roi': roiPath,
          };
        }
        return processedResult.path;
      }
      return null;
    } catch (e) {
      // 구조화된 에러 로깅
      final traceId = StructuredLogger.generateTraceId();
      StructuredLogger.logError(
        traceId: traceId,
        stage: 'gallery_pick',
        error: e.toString(),
      );
      
      // 에러 발생 시 로딩 해제
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(isProcessing: false),
        );
      }
      
      return null;
    }
  }
}

/// 카메라 프로바이더
final cameraProvider = AsyncNotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);