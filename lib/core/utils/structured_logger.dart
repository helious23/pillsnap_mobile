import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// 구조화된 로깅 유틸리티
/// 프론트-BFF-추론서버 간 추적 가능한 로그 생성
class StructuredLogger {
  static const _uuid = Uuid();
  
  /// 추적 ID 생성 (요청 전체 생명주기 추적용)
  static String generateTraceId() {
    return _uuid.v4();
  }
  
  /// 구조화된 로그 출력
  static void log({
    required String stage,
    required String traceId,
    required Map<String, dynamic> data,
    LogLevel level = LogLevel.info,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'stage': stage,
      'traceId': traceId,
      'data': data,
    };
    
    if (kDebugMode) {
      // 개발 모드: 읽기 쉬운 형태로 출력
      debugPrint('[${level.name.toUpperCase()}] $stage');
      debugPrint('TraceID: $traceId');
      debugPrint('Data: ${const JsonEncoder.withIndent('  ').convert(data)}');
    } else {
      // 프로덕션: 한 줄 JSON
      debugPrint(jsonEncode(logEntry));
    }
  }
  
  /// 이미지 전처리 로그
  static void logImageProcessing({
    required String traceId,
    required String phase,
    int? originalWidth,
    int? originalHeight,
    int? originalSize,
    int? processedWidth,
    int? processedHeight,
    int? processedSize,
    bool? wasResized,
    double? scaleFactor,
    bool? exifFixed,
    String? decision,
    String? warning,
  }) {
    log(
      stage: 'image_processing',
      traceId: traceId,
      data: {
        'phase': phase,
        if (originalWidth != null) 'original': {
          'width': originalWidth,
          'height': originalHeight,
          'size': originalSize,
          'sizeKB': originalSize != null ? (originalSize / 1024).toStringAsFixed(1) : null,
        },
        if (processedWidth != null) 'processed': {
          'width': processedWidth,
          'height': processedHeight,
          'size': processedSize,
          'sizeKB': processedSize != null ? (processedSize / 1024).toStringAsFixed(1) : null,
        },
        if (wasResized != null) 'wasResized': wasResized,
        if (scaleFactor != null) 'scaleFactor': scaleFactor.toStringAsFixed(2),
        if (exifFixed != null) 'exifFixed': exifFixed,
        if (decision != null) 'decision': decision,
        if (warning != null) 'warning': warning,
      },
      level: warning != null ? LogLevel.warning : LogLevel.info,
    );
  }
  
  /// 에러 로그
  static void logError({
    required String traceId,
    required String stage,
    required String error,
    Map<String, dynamic>? additionalData,
  }) {
    log(
      stage: stage,
      traceId: traceId,
      data: {
        'error': error,
        if (additionalData != null) ...additionalData,
      },
      level: LogLevel.error,
    );
  }
}

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
}