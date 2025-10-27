import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// PillSnap 추론 서버에 최적화된 이미지 전처리
class ImageProcessor {
  // 추론 서버/BFF 문서 합의값
  static const int kMinLongEdge = 1024; // 절대 최소
  static const int kDesiredLongEdge = 2048; // 권장 목표
  static const int kMaxLongEdge = 4096; // 안전 상한
  static const int kStride = 32; // detection padding stride
  static const int kJpegQuality = 95; // 92~95 권장, 기본 95

  // ===== 공통 유틸리티 함수 =====
  
  /// EXIF 회전 정보를 픽셀에 반영
  static img.Image _bakeOrientation(img.Image im) => img.bakeOrientation(im);
  
  /// 비율 유지하며 리사이즈 (업스케일 금지)
  static img.Image _resizeKeepingAspect(
    img.Image im, {
    required int minEdge,
    required int desiredEdge,
    required int maxEdge,
  }) {
    final w = im.width;
    final h = im.height;
    final long = w > h ? w : h;
    
    // maxEdge 초과 시 maxEdge로 제한, 아니면 desiredEdge 목표
    int targetLong;
    if (long > maxEdge) {
      // 너무 크면 maxEdge로 제한
      targetLong = maxEdge;
    } else if (long < minEdge) {
      // 너무 작으면 그대로 (업스케일 금지)
      targetLong = long;
    } else {
      // minEdge ~ maxEdge 범위 내에서 desiredEdge 목표
      targetLong = long.clamp(minEdge, desiredEdge);
    }
    
    final scale = targetLong / long;
    if (scale >= 1.0) return im; // 업스케일 금지
    
    final nw = (w * scale).round();
    final nh = (h * scale).round();
    
    return img.copyResize(
      im,
      width: nw,
      height: nh,
      interpolation: img.Interpolation.cubic,
    );
  }
  
  /// Stride 배수로 패딩 (중앙 정렬) - 현재 미사용 (서버 letterbox가 처리)
  /// 남겨둔 이유: 추후 필요시 활용 가능
  /// 참고: YOLO 기본 패딩 색상은 (114, 114, 114)
  static img.Image _padToStrideCenter(
    img.Image im, {
    required int stride,
    int r = 114,  // YOLO 기본 패딩 색상
    int g = 114,
    int b = 114,
  }) {
    final padW = ((im.width + stride - 1) ~/ stride) * stride;
    final padH = ((im.height + stride - 1) ~/ stride) * stride;
    
    if (padW == im.width && padH == im.height) return im;
    
    final canvas = img.Image(
      width: padW,
      height: padH,
      numChannels: 3,
    );
    
    img.fill(canvas, color: img.ColorRgb8(r, g, b));
    
    final dx = (padW - im.width) ~/ 2;
    final dy = (padH - im.height) ~/ 2;
    
    img.compositeImage(canvas, im, dstX: dx, dstY: dy);
    
    return canvas;
  }
  
  // ===== Public API =====
  
  /// 분류(단일) — 고해상도 유지 + 비율유지 리사이즈, 패딩 없음
  static Future<File> preprocessForClassification(File imageFile) async {
    return _process(
      imageFile,
      applyStridePadding: false,
    );
  }
  
  /// 검출(다중) — 고해상도 유지 + 비율유지 리사이즈 (패딩은 서버에서 처리)
  static Future<File> preprocessForDetection(File imageFile) async {
    return _process(
      imageFile,
      applyStridePadding: false,  // 서버의 letterbox가 처리하므로 프론트 패딩 제거
    );
  }

  /// 메인 처리 루틴
  static Future<File> _process(
    File imageFile, {
    required bool applyStridePadding,
  }) async {
    try {
      debugPrint('=== [ImageProcessor] start ===');
      debugPrint('src: ${imageFile.path}');
      final srcSize = await imageFile.length();
      debugPrint('size(src): ${(srcSize / 1024).toStringAsFixed(1)}KB');

      // decode
      final bytes = await imageFile.readAsBytes();
      img.Image? im = img.decodeImage(bytes);
      if (im == null) throw Exception('decode failed');
      
      debugPrint('orig: ${im.width}x${im.height}');

      // EXIF → 픽셀 반영
      im = _bakeOrientation(im);
      debugPrint('after EXIF: ${im.width}x${im.height}');

      // 비율 유지 다운스케일 (업스케일 금지)
      final before = im;
      im = _resizeKeepingAspect(
        im,
        minEdge: kMinLongEdge,
        desiredEdge: kDesiredLongEdge,
        maxEdge: kMaxLongEdge,
      );
      
      if (im.width != before.width || im.height != before.height) {
        debugPrint('resize -> ${im.width}x${im.height}');
      } else {
        debugPrint('resize skipped (no upscale)');
      }

      // 패딩 처리 (현재 비활성화 - 서버의 letterbox가 처리)
      // 참고: applyStridePadding은 항상 false로 전달되므로 실행되지 않음
      if (applyStridePadding) {
        final w0 = im.width, h0 = im.height;
        im = _padToStrideCenter(im, stride: kStride);  // 기본값 114,114,114 사용
        
        if (im.width != w0 || im.height != h0) {
          debugPrint('padded to stride $kStride -> ${im.width}x${im.height}');
        }
      }

      // 안전성 경고
      if (im.width < 640 || im.height < 640) {
        debugPrint('⚠️ too small (<640) — detection may fail');
      }
      
      final strideOk = (im.width % kStride == 0 && im.height % kStride == 0);
      debugPrint('stride32: ${strideOk ? "OK" : "NO"}');

      // JPEG encode (sRGB, no EXIF)
      final out = img.encodeJpg(im, quality: kJpegQuality);
      
      final tmp = File('${Directory.systemTemp.path}/ps_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmp.writeAsBytes(out, flush: true);  // flush: true로 저장 안정성 확보
      
      debugPrint('size(out): ${(out.length / 1024).toStringAsFixed(1)}KB');
      debugPrint('=== [ImageProcessor] done ===');
      
      return tmp;
      
    } catch (e, st) {
      debugPrint('ImageProcessor error: $e\n$st');
      return imageFile; // fail-safe
    }
  }

  /// (선택) 중앙 정사각 ROI 512px 유틸 - 단일 촬영시 업로드 보조
  static Uint8List makeCenterSquareJpeg(
    Uint8List jpegBytes, {
    int side = 512,
    int quality = 95,
  }) {
    final im = img.decodeImage(jpegBytes)!;
    final s = im.width < im.height ? im.width : im.height;
    final x = (im.width - s) ~/ 2;
    final y = (im.height - s) ~/ 2;
    
    final crop = img.copyCrop(im, x: x, y: y, width: s, height: s);
    final resized = img.copyResize(crop, width: side, height: side);
    
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  /// 이미지 검증 (디버깅용)
  static Future<void> validateImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        debugPrint('❌ 이미지 검증 실패: 디코딩 불가');
        return;
      }

      debugPrint('📸 이미지 검증');
      debugPrint('✅ 파일명: ${imageFile.path.split('/').last}');
      debugPrint('✅ 파일 크기: ${(bytes.length / 1024).toStringAsFixed(1)}KB');
      debugPrint('✅ 이미지 크기: ${image.width}x${image.height}');
      debugPrint('✅ 종횡비: ${(image.width / image.height).toStringAsFixed(2)}');
      debugPrint('✅ 32의 배수: ${image.width % kStride == 0 && image.height % kStride == 0 ? "YES" : "NO (검출 모드만 필요)"}');
      
      if (image.width < 640 || image.height < 640) {
        debugPrint('⚠️ 경고: 이미지가 너무 작습니다! (<640px) 검출 실패 가능성 높음');
      }
      
      if (bytes.length < 50 * 1024) {
        debugPrint('⚠️ 경고: 파일 크기가 너무 작습니다! 품질 손실 의심');
      }

    } catch (e) {
      debugPrint('이미지 검증 오류: $e');
    }
  }
}