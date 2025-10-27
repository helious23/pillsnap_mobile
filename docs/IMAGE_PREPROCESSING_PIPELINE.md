# 이미지 전처리 파이프라인 문서

작성일: 2025-09-06  
버전: 1.0.0

## 📋 개요

PillSnap 프론트엔드의 이미지 전처리 파이프라인은 카메라/갤러리에서 취득한 고해상도 원본 이미지를 표준화된 업로드 규격으로 변환합니다.

## 🎯 핵심 원칙

### 책임 분리

- **프론트엔드**: 이미지 표준화 (2048px, JPEG Q95, EXIF 처리)
- **BFF**: 매직넘버 검증, 재인코딩 여부 판단
- **추론서버**: 모델별 전처리 (center-crop 768, letterbox 1024, 정규화)

### 업로드 단위 계약

프론트엔드는 카메라/갤러리 원본을 다음 규격으로 표준화:
- **긴 변**: ≤ 2048px (대부분 2048로 다운스케일)
- **포맷**: JPEG (Q=95)
- **EXIF**: 픽셀에 반영 (bakeOrientation)
- **메타데이터**: 제거
- **경로**: `/tmp/upload_ready_*.jpg`

## 📐 표준 규격 (UploadImageSpec)

```dart
class UploadImageSpec {
  static const int targetLongEdge = 2048;     // 목표 긴 변 (대부분 이 크기로 다운스케일)
  static const int minLongEdge = 1024;        // 최소 긴 변 (업스케일 금지)
  static const int maxLongEdge = 4096;        // 최대 긴 변 (초대형 보호)
  static const int jpegQuality = 95;          // JPEG 품질 (92-95 권장)
  
  // 서버 전처리 목표 (참고)
  static const int classificationTargetSize = 768;  // 분류: center-crop
  static const int detectionTargetSize = 1024;      // 감지: letterbox
  static const int roiSize = 512;                   // ROI: 중앙 정사각형
}
```

## 🔄 전처리 파이프라인

### 1. 이미지 캡처/선택
- **카메라**: `ResolutionPreset.max` → 네이티브 고해상도 (예: 4032×3024)
- **갤러리**: 원본 품질 유지

### 2. 전처리 단계 (_processImageInIsolate)

1. **파일 로드 & 디코드**
   - SHA256 해시 계산 (디버깅용)
   - 원본 크기/해상도 로깅

2. **EXIF Orientation 반영**
   - `img.bakeOrientation()` → 픽셀에 회전 적용
   - 메타데이터가 아닌 실제 픽셀 변환

3. **비율 유지 다운스케일**
   ```
   if (longEdge > 4096) → 4096으로 축소
   else if (longEdge > 2048) → 2048로 축소 (가장 흔함)
   else if (longEdge < 1024) → 원본 유지 (업스케일 금지)
   else → 원본 유지
   ```

4. **JPEG 재인코딩**
   - 품질: Q=95
   - 색공간: sRGB
   - 메타데이터: 제거

5. **임시 파일 저장**
   - 경로: `/tmp/upload_ready_<timestamp>.jpg`
   - 이 파일이 실제 업로드 대상

### 3. 결과 메타데이터 (ProcessedImageResult)

```dart
class ProcessedImageResult {
  final String path;          // 업로드 파일 경로
  final int width;            // 최종 너비
  final int height;           // 최종 높이
  final int fileSize;         // 파일 크기 (bytes)
  final String hash;          // SHA256 해시 (앞 12자)
  final bool wasResized;      // 리사이즈 여부
  final double scaleFactor;   // 스케일 팩터
  final bool exifFixed;       // EXIF 수정 여부
  final String traceId;       // 추적 ID
}
```

## 📊 로깅 시스템

### 구조화된 로그 (StructuredLogger)

```json
{
  "timestamp": "2025-09-06T10:00:00Z",
  "level": "info",
  "stage": "image_processing",
  "traceId": "uuid-v4",
  "data": {
    "phase": "final",
    "processed": {
      "width": 2048,
      "height": 1536,
      "size": 245760,
      "sizeKB": "240.0"
    },
    "wasResized": true,
    "scaleFactor": "0.51",
    "exifFixed": false,
    "decision": "larger_than_desired"
  }
}
```

### 로그 단계

1. **original**: 원본 이미지 정보
2. **exif_fixed**: EXIF 처리 후 (변경된 경우만)
3. **resize_decision**: 리사이즈 결정 (too_large/larger_than_desired/size_ok/too_small_keep_original)
4. **resized**: 리사이즈 후 (수행된 경우만)
5. **final**: 최종 결과
6. **compression**: 압축률 정보

## ⚠️ 에러 처리

### ProcessingException

```dart
class ProcessingException implements Exception {
  final String message;
  final String? originalPath;
  final Map<String, dynamic>? metadata;
}
```

- 원본 반환 대신 **명시적 예외** 발생
- UI에 적절한 에러 메시지 표시
- 재시도 로직 활성화

## 🔧 ROI (Region of Interest)

### 기본 정책
- **기본 비활성화** (네트워크 비용 절감)
- 저신뢰 폴백 경로에서만 활성화

### 활성화 조건 (향후 구현)
```dart
bool _shouldGenerateROI() {
  // TODO: 서버 응답 기반 판단
  // - 감지 신뢰도 < 0.35
  // - 분류 확률 < 0.65
  // - 배경 과노출/저대비
  return false;  // 현재는 항상 false
}
```

### ROI 생성
- 중앙 정사각형 크롭
- 512×512 리사이즈
- 별도 파일로 저장 (`roi_<timestamp>.jpg`)
- 메인 이미지와 별개 전송

## 📱 실제 예시

### 가로 사진 (iPhone)
```
원본: 4032×3024 (3.2MB)
  ↓ EXIF 처리
  ↓ 다운스케일 (larger_than_desired)
최종: 2048×1536 (240KB)
압축률: 92.5%
```

### 세로 사진 (Android)
```
원본: 2268×4032 (2.8MB)
  ↓ EXIF 처리 (90도 회전 반영)
  ↓ 다운스케일 (larger_than_desired)
최종: 2048×1152 (185KB)
압축률: 93.4%
```

## ✅ QA 체크리스트

### 테스트 시나리오

1. **고해상도 가로/세로 사진**
   - [ ] 긴 변이 2048로 다운스케일 확인
   - [ ] EXIF 회전이 픽셀에 반영 확인
   - [ ] 메타데이터 제거 확인

2. **저해상도 사진 (<1024px)**
   - [ ] 업스케일 되지 않음 확인
   - [ ] 원본 크기 유지 확인

3. **갤러리 선택**
   - [ ] 카메라와 동일한 파이프라인 적용
   - [ ] 일관된 품질/크기

4. **로그 확인**
   - [ ] 각 단계별 구조화된 로그 출력
   - [ ] traceId로 전체 흐름 추적 가능

## 🚀 향후 개선 사항

1. **적응형 품질 조정**
   - 네트워크 상태에 따른 JPEG 품질 동적 조정
   - 5G: Q95, 4G: Q90, 3G: Q85

2. **ROI 지능형 활성화**
   - 서버 피드백 기반 자동 판단
   - 히스토그램 분석으로 저대비 감지

3. **병렬 처리**
   - 다중 이미지 동시 처리
   - 업로드 큐 관리

4. **캐싱 전략**
   - 처리된 이미지 임시 캐싱
   - 재전송 시 재처리 방지

## 📚 참고 문서

- [API_INTEGRATION.md](./API_INTEGRATION.md)
- [ARCHITECTURE.md](./ARCHITECTURE.md)
- [IMAGE_OPTIMIZATION_GUIDE.md](./IMAGE_OPTIMIZATION_GUIDE.md)