/// 이미지 전처리 예외 클래스
class ProcessingException implements Exception {
  final String message;
  final String? originalPath;
  final Map<String, dynamic>? metadata;
  
  ProcessingException(
    this.message, {
    this.originalPath,
    this.metadata,
  });
  
  @override
  String toString() {
    return 'ProcessingException: $message${originalPath != null ? ' (original: $originalPath)' : ''}';
  }
  
  /// JSON으로 변환 (로깅용)
  Map<String, dynamic> toJson() {
    return {
      'error': 'ProcessingException',
      'message': message,
      if (originalPath != null) 'originalPath': originalPath,
      if (metadata != null) ...metadata!,
    };
  }
}