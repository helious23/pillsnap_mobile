/// 업로드 이미지 표준 규격
/// 
/// 프론트엔드-BFF-추론서버 간 공통 계약:
/// - 프론트엔드: 원본을 이 규격으로 표준화하여 업로드
/// - BFF: 이미 표준화된 이미지는 재처리하지 않음 (no-op)
/// - 추론서버: 분류는 center-crop(768), 감지는 letterbox(1024) 수행
class UploadImageSpec {
  /// 목표 긴 변 길이 (픽셀)
  /// - 대부분의 고해상도 이미지(4032x3024 등)가 이 크기로 다운스케일됨
  /// - 서버는 이 크기를 기준으로 전처리 파라미터 최적화
  static const int targetLongEdge = 2048;
  
  /// 최소 긴 변 길이 (픽셀)
  /// - 이보다 작은 이미지는 업스케일하지 않고 원본 유지
  /// - 서버가 후처리로 대응
  static const int minLongEdge = 1024;
  
  /// 최대 긴 변 길이 (픽셀)
  /// - 초대형 이미지(>4096) 보호용 상한
  /// - 메모리 및 처리 시간 제한
  static const int maxLongEdge = 4096;
  
  /// JPEG 인코딩 품질 (0-100)
  /// - 92-95 권장 범위
  /// - 분류/감지에 시각적 손실 없이 용량 절감
  static const int jpegQuality = 95;
  
  /// 서버 전처리 목표 (참고용)
  /// - 분류 모델 입력: 768x768 (center-crop)
  /// - 감지 모델 입력: 1024x1024 (letterbox with padding)
  static const int classificationTargetSize = 768;
  static const int detectionTargetSize = 1024;
  
  /// ROI (Region of Interest) 크기
  /// - 단일 모드 저신뢰 폴백용
  /// - 중앙 정사각형 크롭 후 리사이즈
  static const int roiSize = 512;
  
  /// ROI 전송 조건 (기본 비활성)
  /// - 단일 촬영 모드에서만 고려
  /// - 감지 신뢰도 < 0.35 또는 분류 확률 < 0.65일 때
  static const double roiConfidenceThreshold = 0.65;
  static const double roiDetectionThreshold = 0.35;
}