# 🎯 PillSnap 프론트엔드 이미지 최적화 긴급 가이드

**⚠️ 현재 문제: 검출률이 매우 낮음 - 이미지 전처리 최적화 필수**

프론트엔드 Claude Code님, 현재 알약 검출률이 엉망입니다.
이미지가 제대로 전달되지 않아 추론 서버가 알약을 찾지 못하고 있습니다.
아래 가이드를 **반드시 순서대로** 적용해주세요.

## 🚨 핵심 문제점

1. **이미지 품질 손실** - 과도한 압축 또는 리사이징
2. **잘못된 종횡비** - 원본 비율 유지 안 됨
3. **EXIF 회전 미처리** - 모바일 사진이 뒤집혀 전송
4. **해상도 부족** - 너무 작게 리사이징

## ✅ 필수 이미지 전처리 요구사항

### 📐 1. 최적 해상도 설정

```javascript
// ⚠️ 중요: 추론 서버는 다음 크기를 기대합니다
const INFERENCE_CONFIG = {
  // Detection 모델 입력 크기
  DETECTION_SIZE: 1024, // 정사각형 1024x1024
  DETECTION_STRIDE: 32, // 32의 배수로 패딩

  // Classification 모델 입력 크기
  CLASSIFICATION_SIZE: 384, // 정사각형 384x384

  // 최소/최대 제약
  MIN_DIMENSION: 640, // 최소 640px (이보다 작으면 검출 실패)
  MAX_DIMENSION: 2048, // 최대 2048px (메모리 효율)

  // JPEG 품질 (중요!)
  JPEG_QUALITY: 0.92, // 92% 품질 (너무 낮으면 알약 텍스트 손실)
};
```

### 🖼️ 2. 올바른 이미지 전처리 함수

```javascript
// src/lib/utils/imageProcessor.js

/**
 * PillSnap 추론 서버에 최적화된 이미지 전처리
 * ⚠️ 이 함수를 반드시 사용하세요!
 */
export async function preprocessImageForInference(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      const img = new Image();

      img.onload = async () => {
        try {
          // 1. EXIF 회전 처리 (중요!)
          const orientation = await getExifOrientation(file);

          // 2. 캔버스 생성
          const canvas = document.createElement("canvas");
          const ctx = canvas.getContext("2d");

          // 3. 원본 크기 확인
          let width = img.width;
          let height = img.height;

          console.log(`원본 이미지: ${width}x${height}`);

          // 4. EXIF 회전 적용
          if (orientation && orientation !== 1) {
            // 회전이 필요한 경우 (90도, 180도, 270도)
            if (orientation === 6 || orientation === 8) {
              // 90도 또는 270도 회전 - 가로세로 바꿈
              [width, height] = [height, width];
            }
          }

          // 5. 레터박스 방식으로 리사이징 (종횡비 유지!)
          const targetSize = INFERENCE_CONFIG.DETECTION_SIZE;
          const scale = Math.min(targetSize / width, targetSize / height);

          // 너무 작은 이미지는 확대하지 않음 (품질 손실 방지)
          const finalScale = Math.min(scale, 1.0);

          const newWidth = Math.round(width * finalScale);
          const newHeight = Math.round(height * finalScale);

          // 6. 32의 배수로 패딩 (Detection 모델 요구사항)
          const stride = INFERENCE_CONFIG.DETECTION_STRIDE;
          const paddedWidth = Math.ceil(newWidth / stride) * stride;
          const paddedHeight = Math.ceil(newHeight / stride) * stride;

          // 7. 캔버스 크기 설정 (패딩 포함)
          canvas.width = paddedWidth;
          canvas.height = paddedHeight;

          // 8. 배경을 흰색으로 채움 (중요!)
          ctx.fillStyle = "#FFFFFF";
          ctx.fillRect(0, 0, paddedWidth, paddedHeight);

          // 9. 중앙 정렬
          const offsetX = (paddedWidth - newWidth) / 2;
          const offsetY = (paddedHeight - newHeight) / 2;

          // 10. EXIF 회전 변환 적용
          ctx.save();
          ctx.translate(paddedWidth / 2, paddedHeight / 2);

          switch (orientation) {
            case 2: // 수평 뒤집기
              ctx.scale(-1, 1);
              break;
            case 3: // 180도 회전
              ctx.rotate(Math.PI);
              break;
            case 4: // 수직 뒤집기
              ctx.scale(1, -1);
              break;
            case 5: // 수직 뒤집기 + 90도 회전
              ctx.rotate(Math.PI / 2);
              ctx.scale(1, -1);
              break;
            case 6: // 90도 회전
              ctx.rotate(Math.PI / 2);
              break;
            case 7: // 수평 뒤집기 + 90도 회전
              ctx.rotate(Math.PI / 2);
              ctx.scale(-1, 1);
              break;
            case 8: // 270도 회전
              ctx.rotate(-Math.PI / 2);
              break;
          }

          ctx.translate(-paddedWidth / 2, -paddedHeight / 2);

          // 11. 이미지 그리기 (안티앨리어싱 활성화)
          ctx.imageSmoothingEnabled = true;
          ctx.imageSmoothingQuality = "high";
          ctx.drawImage(img, offsetX, offsetY, newWidth, newHeight);

          ctx.restore();

          // 12. 디버그 정보 출력
          console.log(`최종 출력: ${paddedWidth}x${paddedHeight}`);
          console.log(`스케일: ${finalScale.toFixed(2)}x`);
          console.log(`패딩: ${offsetX.toFixed(0)}, ${offsetY.toFixed(0)}`);

          // 13. Blob 생성 (JPEG, 높은 품질)
          canvas.toBlob(
            (blob) => {
              if (blob) {
                // 파일명 유지
                const processedFile = new File([blob], file.name, {
                  type: "image/jpeg",
                });

                console.log(`처리 완료: ${(blob.size / 1024).toFixed(1)}KB`);
                resolve(processedFile);
              } else {
                reject(new Error("이미지 처리 실패"));
              }
            },
            "image/jpeg",
            INFERENCE_CONFIG.JPEG_QUALITY
          );
        } catch (error) {
          console.error("이미지 전처리 오류:", error);
          reject(error);
        }
      };

      img.onerror = () => reject(new Error("이미지 로드 실패"));
      img.src = e.target.result;
    };

    reader.onerror = () => reject(new Error("파일 읽기 실패"));
    reader.readAsDataURL(file);
  });
}

/**
 * EXIF Orientation 태그 읽기
 * 모바일 카메라 사진의 회전 정보 추출
 */
async function getExifOrientation(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      const view = new DataView(e.target.result);

      if (view.getUint16(0, false) !== 0xffd8) {
        // JPEG가 아니면 회전 없음
        resolve(1);
        return;
      }

      const length = view.byteLength;
      let offset = 2;

      while (offset < length) {
        const marker = view.getUint16(offset, false);
        offset += 2;

        if (marker === 0xffe1) {
          // EXIF 마커 찾음
          if (view.getUint32(offset + 2, false) !== 0x45786966) {
            // "Exif" 문자열이 아님
            resolve(1);
            return;
          }

          const little = view.getUint16(offset + 6, false) === 0x4949;
          offset += view.getUint32(offset + 10, little);
          const tags = view.getUint16(offset, little);
          offset += 2;

          for (let i = 0; i < tags; i++) {
            if (view.getUint16(offset + i * 12, little) === 0x0112) {
              // Orientation 태그 찾음
              resolve(view.getUint16(offset + i * 12 + 8, little));
              return;
            }
          }
        } else if ((marker & 0xff00) !== 0xff00) {
          break;
        } else {
          offset += view.getUint16(offset, false);
        }
      }

      resolve(1); // 기본값: 회전 없음
    };

    reader.readAsArrayBuffer(file.slice(0, 64 * 1024)); // 처음 64KB만 읽음
  });
}
```

### 🔄 3. API 호출 수정

```javascript
// src/components/DrugAnalyzer.jsx 수정

import { preprocessImageForInference } from "@/lib/utils/imageProcessor";
import { pillSnapAPI } from "@/lib/api/client";

export default function DrugAnalyzer() {
  const [loading, setLoading] = useState(false);
  const [originalFile, setOriginalFile] = useState(null);
  const [processedFile, setProcessedFile] = useState(null);

  // 파일 선택 시 전처리
  const handleFileSelect = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setOriginalFile(file);
    setLoading(true);

    try {
      // ⚠️ 중요: 반드시 전처리 수행
      console.log("이미지 전처리 시작...");
      const processed = await preprocessImageForInference(file);
      setProcessedFile(processed);

      // 전처리 전후 크기 비교
      console.log(`원본: ${(file.size / 1024).toFixed(1)}KB`);
      console.log(`처리후: ${(processed.size / 1024).toFixed(1)}KB`);

      // 미리보기용 URL 생성
      const previewUrl = URL.createObjectURL(processed);
      setPreviewUrl(previewUrl);
    } catch (error) {
      console.error("이미지 전처리 실패:", error);
      setError("이미지 처리 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // 분석 실행
  const handleAnalyze = async () => {
    if (!processedFile) {
      setError("이미지를 먼저 선택해주세요.");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // 전처리된 이미지로 API 호출
      const result = await pillSnapAPI.analyzeImage(
        processedFile,
        "detect_cls"
      );

      console.log("분석 성공:", result);
      setResult(result);
    } catch (err) {
      console.error("분석 실패:", err);
      setError(err.message || "분석 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // ... 나머지 컴포넌트 코드
}
```

### 📸 4. 모바일 카메라 직접 촬영 최적화

```javascript
// 모바일 카메라 설정 (HTML5 capture)
<input
  type="file"
  accept="image/*"
  capture="environment" // 후면 카메라 사용
  onChange={handleFileSelect}
/>;

// 또는 getUserMedia API 사용 시
const constraints = {
  video: {
    facingMode: "environment", // 후면 카메라
    width: { ideal: 2048 }, // 충분한 해상도
    height: { ideal: 2048 },
  },
};
```

## 🧪 검증 체크리스트

이미지 전송 전 반드시 확인:

```javascript
// 디버깅용 검증 함수
function validateProcessedImage(file) {
  const img = new Image();
  const reader = new FileReader();

  reader.onload = (e) => {
    img.onload = () => {
      console.group("📸 이미지 검증");
      console.log("✅ 파일명:", file.name);
      console.log("✅ 파일 크기:", (file.size / 1024).toFixed(1), "KB");
      console.log("✅ MIME 타입:", file.type);
      console.log("✅ 이미지 크기:", img.width, "x", img.height);
      console.log("✅ 종횡비:", (img.width / img.height).toFixed(2));
      console.log(
        "✅ 32의 배수:",
        img.width % 32 === 0 && img.height % 32 === 0 ? "YES" : "NO"
      );
      console.groupEnd();

      // 경고 체크
      if (img.width < 640 || img.height < 640) {
        console.warn("⚠️ 이미지가 너무 작습니다! 검출 실패 가능성 높음");
      }
      if (file.size < 50 * 1024) {
        console.warn("⚠️ 파일 크기가 너무 작습니다! 품질 손실 의심");
      }
    };
    img.src = e.target.result;
  };

  reader.readAsDataURL(file);
}
```

## ⚡ 즉시 적용 가능한 빠른 수정

현재 코드에서 최소한 이것만이라도 수정하세요:

```javascript
// 기존 코드에서 찾아서 수정
// ❌ 잘못된 예
canvas.toBlob(resolve, "image/jpeg", 0.7); // 품질 70%는 너무 낮음!

// ✅ 수정
canvas.toBlob(resolve, "image/jpeg", 0.92); // 최소 90% 이상

// ❌ 잘못된 예
const MAX_WIDTH = 800; // 너무 작음!
const MAX_HEIGHT = 800;

// ✅ 수정
const MAX_WIDTH = 1024; // Detection 모델 입력 크기
const MAX_HEIGHT = 1024;

// ❌ 잘못된 예
ctx.imageSmoothingEnabled = false; // 앨리어싱 발생!

// ✅ 수정
ctx.imageSmoothingEnabled = true;
ctx.imageSmoothingQuality = "high";
```

## 🔍 문제 진단 방법

브라우저 콘솔에서:

```javascript
// 1. 처리된 이미지 크기 확인
console.log("처리된 이미지:", processedFile);
console.log("크기:", processedFile.size, "bytes");
console.log("타입:", processedFile.type);

// 2. Base64로 변환해서 직접 확인
const reader = new FileReader();
reader.onload = (e) => {
  const img = new Image();
  img.onload = () => {
    console.log("실제 크기:", img.width, "x", img.height);
    document.body.appendChild(img); // 화면에 표시
  };
  img.src = e.target.result;
  img.style.maxWidth = "300px";
};
reader.readAsDataURL(processedFile);

// 3. API 요청 확인 (Network 탭에서)
// - Request Payload 크기
// - 이미지가 제대로 전송되는지
// - Content-Type이 multipart/form-data인지
```

## 🚨 긴급 조치 사항

1. **즉시 수정**: 이미지 품질을 0.92 이상으로 설정
2. **즉시 수정**: 리사이징 목표 크기를 1024x1024로 변경
3. **즉시 추가**: EXIF 회전 처리 코드 추가
4. **즉시 추가**: 32의 배수 패딩 처리
5. **즉시 확인**: processedFile이 null이 아닌지 확인

## 📞 추가 지원

이 가이드 적용 후에도 검출률이 개선되지 않으면:

1. 처리된 이미지 파일을 다운로드해서 확인
2. Network 탭에서 실제 전송되는 데이터 확인
3. 백엔드 팀에 request_id와 함께 문의

---

**작성일**: 2025-09-03
**우선순위**: 🔴 긴급
**예상 소요시간**: 30분

이 문서의 코드를 복사-붙여넣기로 바로 적용하세요.
특히 `preprocessImageForInference` 함수는 **반드시 그대로** 사용해주세요!
