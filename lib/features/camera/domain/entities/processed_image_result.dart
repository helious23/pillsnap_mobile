/// 전처리된 이미지 결과 메타데이터
class ProcessedImageResult {
  final String path;
  final int width;
  final int height;
  final int fileSize;
  final String hash;
  final bool wasResized;
  final double scaleFactor;
  final bool exifFixed;
  final DateTime processedAt;
  final String traceId;
  
  ProcessedImageResult({
    required this.path,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.hash,
    required this.wasResized,
    required this.scaleFactor,
    required this.exifFixed,
    required this.processedAt,
    required this.traceId,
  });
  
  /// JSON으로 변환 (서버 전송/로깅용)
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'hash': hash,
      'wasResized': wasResized,
      'scaleFactor': scaleFactor,
      'exifFixed': exifFixed,
      'processedAt': processedAt.toIso8601String(),
      'traceId': traceId,
    };
  }
  
  /// 로그용 간략 정보
  String toLogString() {
    return 'ProcessedImage[${width}x$height, ${(fileSize / 1024).toStringAsFixed(1)}KB, '
           'scale:${scaleFactor.toStringAsFixed(2)}, resized:$wasResized, exif:$exifFixed]';
  }
}