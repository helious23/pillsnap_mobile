# 🚀 PillSnap 프론트엔드 API 연동 완전 가이드

**이 문서는 프론트엔드 Claude Code에게 전달할 프롬프트입니다**

안녕하세요! PillSnap 프론트엔드와 백엔드 API를 연결하는 작업을 도와드리겠습니다.
아래 단계를 순차적으로 따라가면 완벽하게 연동할 수 있습니다.

## 📋 작업 개요

PillSnap API 서버가 이미 구축되어 운영 중입니다:

- **Production API**: `https://api.pillsnap.co.kr`
- **상태**: 현재 정상 작동 중 (43시간 연속 운영)
- **인증 방식**: X-Api-Key 헤더 필수

## 🔧 Step 1: API 키 설정

### 1.1 환경 변수 파일 생성

프론트엔드 프로젝트 루트에 `.env.local` 파일을 생성하세요:

```bash
# .env.local
NEXT_PUBLIC_API_URL=https://api.pillsnap.co.kr
NEXT_PUBLIC_API_KEY=YOUR_API_KEY_HERE  # 실제 API 키
```

### 1.2 API 클라이언트 설정 파일 생성

`src/lib/api/client.js` 또는 `src/lib/api/client.ts` 파일을 생성:

```javascript
// src/lib/api/client.js

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "https://api.pillsnap.co.kr";
const API_KEY = process.env.NEXT_PUBLIC_API_KEY;

class PillSnapAPIClient {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.apiKey = API_KEY;
  }

  // 기본 헤더 설정
  getHeaders(includeAuth = true) {
    const headers = {
      Accept: "application/json",
    };

    if (includeAuth && this.apiKey) {
      headers["X-Api-Key"] = this.apiKey;
    }

    return headers;
  }

  // 이미지 분석 API
  async analyzeImage(imageFile, mode = "detect_cls") {
    const formData = new FormData();
    formData.append("image", imageFile);
    formData.append("mode", mode);

    try {
      const response = await fetch(`${this.baseURL}/v1/analyze`, {
        method: "POST",
        headers: this.getHeaders(),
        body: formData,
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "이미지 분석에 실패했습니다");
      }

      return await response.json();
    } catch (error) {
      console.error("Image analysis error:", error);
      throw error;
    }
  }

  // Base64 이미지 분석 (대체 방법)
  async analyzeImageBase64(base64Image, mode = "detect_cls") {
    try {
      const response = await fetch(`${this.baseURL}/v1/analyze`, {
        method: "POST",
        headers: {
          ...this.getHeaders(),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          image: base64Image,
          mode: mode,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "이미지 분석에 실패했습니다");
      }

      return await response.json();
    } catch (error) {
      console.error("Image analysis error:", error);
      throw error;
    }
  }

  // 개별 약품 정보 조회
  async getDrugInfo(itemSeq) {
    try {
      const response = await fetch(`${this.baseURL}/v1/drugs/item/${itemSeq}`, {
        method: "GET",
        headers: this.getHeaders(),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "약품 정보를 가져올 수 없습니다");
      }

      return await response.json();
    } catch (error) {
      console.error("Drug info error:", error);
      throw error;
    }
  }

  // 다중 약품 정보 일괄 조회
  async getDrugsBatch(itemSeqs) {
    try {
      const response = await fetch(`${this.baseURL}/v1/drugs/batch`, {
        method: "POST",
        headers: {
          ...this.getHeaders(),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          item_seqs: itemSeqs,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "약품 정보를 가져올 수 없습니다");
      }

      return await response.json();
    } catch (error) {
      console.error("Batch drug info error:", error);
      throw error;
    }
  }

  // 헬스체크 (인증 불필요)
  async checkHealth() {
    try {
      const response = await fetch(`${this.baseURL}/health`, {
        method: "GET",
        headers: this.getHeaders(false), // 인증 헤더 제외
      });

      if (!response.ok) {
        throw new Error("서버 상태를 확인할 수 없습니다");
      }

      return await response.json();
    } catch (error) {
      console.error("Health check error:", error);
      throw error;
    }
  }
}

// 싱글톤 인스턴스 export
export const pillSnapAPI = new PillSnapAPIClient();
```

## 🎯 Step 2: 컴포넌트와 API 연동

### 2.1 이미지 업로드 및 분석 컴포넌트

```jsx
// src/components/DrugAnalyzer.jsx
import { useState } from "react";
import { pillSnapAPI } from "@/lib/api/client";

export default function DrugAnalyzer() {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);

  // 파일 선택 핸들러
  const handleFileSelect = (e) => {
    const file = e.target.files[0];
    if (file) {
      // 파일 크기 체크 (10MB 제한)
      if (file.size > 10 * 1024 * 1024) {
        setError("파일 크기는 10MB 이하여야 합니다.");
        return;
      }

      setSelectedFile(file);
      setError(null);

      // 미리보기 URL 생성
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
    }
  };

  // 이미지 분석 실행
  const handleAnalyze = async () => {
    if (!selectedFile) {
      setError("이미지를 선택해주세요.");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      console.log("분석 시작:", selectedFile.name);
      const data = await pillSnapAPI.analyzeImage(selectedFile);

      console.log("분석 결과:", data);
      setResult(data);

      // 성공 시 결과 처리
      if (data.status === "success" && data.inference?.dets?.length > 0) {
        const topResult = data.inference.dets[0].top1;
        console.log("Top-1 약품:", topResult.label.item_name_kor);
        console.log("신뢰도:", topResult.confidence);
      }
    } catch (err) {
      console.error("분석 실패:", err);
      setError(err.message || "분석 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  // Top-2~5 추가 정보 조회
  const handleLoadMoreDetails = async (itemSeq) => {
    try {
      const drugInfo = await pillSnapAPI.getDrugInfo(itemSeq);
      console.log("추가 약품 정보:", drugInfo);
      // 상태 업데이트 또는 UI 갱신
    } catch (err) {
      console.error("약품 정보 조회 실패:", err);
    }
  };

  return (
    <div className="drug-analyzer">
      {/* 파일 업로드 영역 */}
      <div className="upload-section">
        <input
          type="file"
          accept="image/*"
          onChange={handleFileSelect}
          disabled={loading}
        />

        {previewUrl && (
          <div className="preview">
            <img
              src={previewUrl}
              alt="미리보기"
              style={{ maxWidth: "300px" }}
            />
          </div>
        )}

        <button onClick={handleAnalyze} disabled={!selectedFile || loading}>
          {loading ? "분석 중..." : "알약 분석하기"}
        </button>
      </div>

      {/* 에러 메시지 */}
      {error && <div className="error-message">⚠️ {error}</div>}

      {/* 분석 결과 표시 */}
      {result && result.status === "success" && (
        <div className="results">
          <h3>분석 결과</h3>

          {result.inference.dets.map((detection, idx) => (
            <div key={idx} className="detection-result">
              <h4>검출된 알약 #{idx + 1}</h4>

              {/* Top-1 결과 (OpenAPI 정보 포함) */}
              <div className="top1-result">
                <h5>가장 유력한 약품</h5>
                <p>약품명: {detection.top1.label.item_name_kor}</p>
                <p>제조사: {detection.top1.label.manufacturer}</p>
                <p>신뢰도: {(detection.top1.confidence * 100).toFixed(1)}%</p>
                <p>모양: {detection.top1.label.drug_shape}</p>
                <p>색상: {detection.top1.label.drug_color_front}</p>
                <p>
                  식별문자: {detection.top1.label.drug_print_front || "없음"}
                </p>

                {/* OpenAPI 추가 정보 (있는 경우) */}
                {result.drugs?.[0] && (
                  <div className="openapi-info">
                    <p>전문/일반: {result.drugs[0].etc_otc_name}</p>
                    <p>분류: {result.drugs[0].class_name}</p>
                    <p>허가일: {result.drugs[0].item_permit_date}</p>
                  </div>
                )}
              </div>

              {/* Top-3 결과 목록 */}
              {detection.top3 && detection.top3.length > 1 && (
                <div className="other-candidates">
                  <h5>다른 후보 약품들</h5>
                  {detection.top3.slice(1).map((item, i) => (
                    <div key={i} className="candidate">
                      <p>
                        {i + 2}순위: {item.label.item_name_kor}
                      </p>
                      <p>신뢰도: {(item.confidence * 100).toFixed(1)}%</p>
                      <button
                        onClick={() =>
                          handleLoadMoreDetails(item.label.item_seq)
                        }
                        size="small"
                      >
                        상세정보 보기
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}

          {/* 분석 메타데이터 */}
          <div className="metadata">
            <p>처리 시간: {result.latency_ms.total}ms</p>
            <p>추론 시간: {result.latency_ms.inference}ms</p>
            <p>Request ID: {result.request_id}</p>
          </div>
        </div>
      )}
    </div>
  );
}
```

## 🧪 Step 3: API 연동 테스트

### 3.1 헬스체크 테스트 컴포넌트

```jsx
// src/components/HealthCheck.jsx
import { useEffect, useState } from "react";
import { pillSnapAPI } from "@/lib/api/client";

export default function HealthCheck() {
  const [status, setStatus] = useState("checking");
  const [message, setMessage] = useState("");

  useEffect(() => {
    checkAPIHealth();
  }, []);

  const checkAPIHealth = async () => {
    try {
      const health = await pillSnapAPI.checkHealth();
      console.log("API 상태:", health);

      if (health.status === "healthy") {
        setStatus("online");
        setMessage("API 서버가 정상 작동 중입니다");
      } else {
        setStatus("degraded");
        setMessage("API 서버 상태: " + health.status);
      }
    } catch (err) {
      setStatus("offline");
      setMessage("API 서버에 연결할 수 없습니다");
      console.error("Health check failed:", err);
    }
  };

  return (
    <div className={`health-status ${status}`}>
      <span className="status-indicator">●</span>
      <span>{message}</span>
    </div>
  );
}
```

### 3.2 테스트 시나리오

브라우저 콘솔에서 다음 테스트를 실행하세요:

```javascript
// 1. API 연결 테스트
fetch("https://api.pillsnap.co.kr/health")
  .then((res) => res.json())
  .then((data) => console.log("Health:", data));

// 2. API 키 테스트
fetch("https://api.pillsnap.co.kr/v1/analyze", {
  method: "POST",
  headers: {
    "X-Api-Key": "YOUR_API_KEY_HERE",
  },
  body: new FormData(),
})
  .then((res) => res.json())
  .then((data) => console.log("Auth test:", data));
```

## 🐛 Step 4: 디버깅 가이드

### 4.1 일반적인 오류와 해결방법

#### 401 Unauthorized

```javascript
// 문제: API 키가 없거나 잘못됨
// 해결: .env.local 파일 확인
console.log("현재 API 키:", process.env.NEXT_PUBLIC_API_KEY);
```

#### CORS 오류

```javascript
// 문제: CORS 정책 위반
// 해결: 백엔드 팀에 현재 도메인 화이트리스트 추가 요청
// 현재 허용된 도메인:
// - http://localhost:3000
// - http://localhost:3001
```

#### 413 Request Too Large

```javascript
// 문제: 이미지가 10MB 초과
// 해결: 클라이언트에서 이미지 리사이징
async function resizeImage(file) {
  const img = new Image();
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  return new Promise((resolve) => {
    img.onload = () => {
      const MAX_WIDTH = 1024;
      const MAX_HEIGHT = 1024;

      let width = img.width;
      let height = img.height;

      if (width > height) {
        if (width > MAX_WIDTH) {
          height *= MAX_WIDTH / width;
          width = MAX_WIDTH;
        }
      } else {
        if (height > MAX_HEIGHT) {
          width *= MAX_HEIGHT / height;
          height = MAX_HEIGHT;
        }
      }

      canvas.width = width;
      canvas.height = height;
      ctx.drawImage(img, 0, 0, width, height);

      canvas.toBlob(resolve, "image/jpeg", 0.85);
    };

    img.src = URL.createObjectURL(file);
  });
}
```

### 4.2 로깅 유틸리티

```javascript
// src/lib/utils/logger.js
const isDev = process.env.NODE_ENV === "development";

export const apiLogger = {
  request: (method, url, data) => {
    if (isDev) {
      console.group(`🚀 API Request: ${method} ${url}`);
      console.log("Data:", data);
      console.groupEnd();
    }
  },

  response: (url, data) => {
    if (isDev) {
      console.group(`✅ API Response: ${url}`);
      console.log("Data:", data);
      console.groupEnd();
    }
  },

  error: (url, error) => {
    console.group(`❌ API Error: ${url}`);
    console.error("Error:", error);
    console.groupEnd();
  },
};
```

## 📸 Step 5: 이미지 전처리 사양

### 5.1 프론트엔드 이미지 표준화

API로 전송하기 전에 이미지를 다음과 같이 표준화하세요:

```javascript
// src/lib/utils/imagePreprocessor.js
import { UploadImageSpec } from '@/constants/imageSpec';

export async function preprocessImage(file) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    img.onload = () => {
      // 원본 크기 확인
      const originalWidth = img.width;
      const originalHeight = img.height;
      const longEdge = Math.max(originalWidth, originalHeight);
      
      // 리사이징 결정
      let targetWidth = originalWidth;
      let targetHeight = originalHeight;
      let wasResized = false;
      
      if (longEdge > UploadImageSpec.maxLongEdge) {
        // 4096px 초과 → 4096으로 축소
        const scale = UploadImageSpec.maxLongEdge / longEdge;
        targetWidth = Math.round(originalWidth * scale);
        targetHeight = Math.round(originalHeight * scale);
        wasResized = true;
      } else if (longEdge > UploadImageSpec.targetLongEdge) {
        // 2048px 초과 → 2048로 축소
        const scale = UploadImageSpec.targetLongEdge / longEdge;
        targetWidth = Math.round(originalWidth * scale);
        targetHeight = Math.round(originalHeight * scale);
        wasResized = true;
      }
      // 1024px 미만은 원본 유지 (업스케일 금지)
      
      // 캔버스에 그리기
      canvas.width = targetWidth;
      canvas.height = targetHeight;
      ctx.drawImage(img, 0, 0, targetWidth, targetHeight);
      
      // JPEG 변환 (Q=95)
      canvas.toBlob(
        (blob) => {
          resolve({
            blob,
            metadata: {
              originalWidth,
              originalHeight,
              processedWidth: targetWidth,
              processedHeight: targetHeight,
              wasResized,
              scaleFactor: targetWidth / originalWidth,
              fileSize: blob.size
            }
          });
        },
        'image/jpeg',
        UploadImageSpec.jpegQuality / 100
      );
    };
    
    img.onerror = () => reject(new Error('이미지 로드 실패'));
    img.src = URL.createObjectURL(file);
  });
}
```

### 5.2 이미지 업로드 규격 상수

```javascript
// src/constants/imageSpec.js
export const UploadImageSpec = {
  targetLongEdge: 2048,    // 목표 긴 변 (대부분 이 크기로)
  minLongEdge: 1024,       // 최소 긴 변 (업스케일 금지)
  maxLongEdge: 4096,       // 최대 긴 변 (초대형 보호)
  jpegQuality: 95,         // JPEG 품질
  maxFileSize: 10485760    // 10MB 제한
};
```

### 5.3 개선된 이미지 분석 함수

```javascript
// API 클라이언트에 추가
async analyzeImageWithPreprocessing(imageFile, mode = "detect_cls") {
  try {
    // 전처리 실행
    const { blob, metadata } = await preprocessImage(imageFile);
    
    // 파일 크기 체크
    if (blob.size > UploadImageSpec.maxFileSize) {
      throw new Error(`파일 크기가 ${UploadImageSpec.maxFileSize / 1048576}MB를 초과합니다`);
    }
    
    // 로깅 (개발 모드)
    if (process.env.NODE_ENV === 'development') {
      console.log('이미지 전처리 완료:', {
        원본: `${metadata.originalWidth}×${metadata.originalHeight}`,
        처리: `${metadata.processedWidth}×${metadata.processedHeight}`,
        크기: `${(blob.size / 1024).toFixed(1)}KB`,
        리사이즈: metadata.wasResized ? `${(metadata.scaleFactor * 100).toFixed(1)}%` : '없음'
      });
    }
    
    // FormData 생성
    const formData = new FormData();
    formData.append("image", blob, "processed.jpg");
    formData.append("mode", mode);
    
    // API 호출
    const response = await fetch(`${this.baseURL}/v1/analyze`, {
      method: "POST",
      headers: this.getHeaders(),
      body: formData,
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || "이미지 분석에 실패했습니다");
    }
    
    const result = await response.json();
    
    // 메타데이터 추가
    result.preprocessMetadata = metadata;
    
    return result;
  } catch (error) {
    console.error("Image analysis error:", error);
    throw error;
  }
}
```

## 📊 Step 6: 응답 데이터 구조

### 5.1 분석 성공 응답 예시

```json
{
  "status": "success",
  "inference": {
    "mode": "detect_cls",
    "dets": [
      {
        "bbox": [100, 200, 300, 400],
        "det_conf": 0.98,
        "top1": {
          "confidence": 0.92,
          "label": {
            "item_seq": 200608152,
            "item_name_kor": "타이레놀정500밀리그램",
            "manufacturer": "한국얀센",
            "drug_shape": "원형",
            "drug_color_front": "흰색"
          }
        },
        "top3": [
          /* Top-3 예측 결과 */
        ]
      }
    ]
  },
  "drugs": [
    /* OpenAPI 정보 */
  ],
  "request_id": "uuid",
  "latency_ms": {
    "total": 2500,
    "inference": 2000,
    "openapi": 450
  }
}
```

### 5.2 오류 응답 예시

```json
{
  "code": "401",
  "message": "API 키가 필요합니다",
  "request_id": "uuid"
}
```

## 🚦 Step 7: 최종 체크리스트

프론트엔드 Claude Code님, 다음 사항들을 확인해주세요:

- [ ] `.env.local` 파일 생성 및 API 키 설정
- [ ] API 클라이언트 모듈 생성 (`src/lib/api/client.js`)
- [ ] 헬스체크로 API 연결 확인
- [ ] 이미지 전처리 함수 구현 (2048px, JPEG Q95)
- [ ] 이미지 업로드 컴포넌트 구현
- [ ] 분석 결과 표시 UI 구현
- [ ] 에러 핸들링 및 로딩 상태 구현
- [ ] Top-2~5 약품 정보 추가 조회 기능
- [ ] 이미지 크기 검증 (10MB 제한)
- [ ] CORS 오류 없는지 확인
- [ ] 구조화 로깅 추가 (trace_id 포함)

## 💡 추가 팁

1. **개발 중 CORS 문제가 있다면**, 백엔드 팀에 현재 개발 서버 URL을 알려주세요.

2. **API 키는 이미 제공되었습니다**: `YOUR_API_KEY_HERE`

3. **성능 최적화를 위해**:

   - 이미지는 클라이언트에서 1024x1024로 리사이징
   - 결과는 로컬 스토리지에 캐싱
   - Top-2~5는 사용자 요청 시에만 로드

4. **모든 API 응답에는 `request_id`가 포함**됩니다. 디버깅 시 이 ID를 백엔드 팀에 전달하면 빠른 문제 해결이 가능합니다.

---

**작성일**: 2025-09-03 (최종 수정: 2025-09-07)
**API 버전**: 1.0.0
**API 상태**: 🟢 정상 운영 중 (https://api.pillsnap.co.kr)
**이미지 전처리 규격**: 2048px 긴 변, JPEG Q95, EXIF 픽셀 반영

이 문서의 내용을 순서대로 따라가시면 완벽하게 API 연동이 가능합니다!
혹시 문제가 발생하거나 추가 질문이 있으시면 언제든 문의해주세요.
