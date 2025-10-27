# PillSnap 구현 필요 기능 명세서
작성일: 2025년 9월 5일

## 📌 구현 완료 항목
- ✅ 카메라 촬영 기능
- ✅ API 연동 (https://api.pillsnap.co.kr)
- ✅ 인증 시스템 (로그인/회원가입/이메일 인증)
- ✅ 온보딩
- ✅ 프로필 관리
- ✅ 약품 검색 및 상세 정보

## 🚀 구현 필요 기능 (우선순위순)

### 1. 약물 즐겨찾기 기능
**우선순위: 높음**

#### 구현 내용
- 약품 상세 페이지에 즐겨찾기 버튼 추가
- 즐겨찾기 목록 페이지 생성
- 홈 화면에서 즐겨찾기 빠른 접근

#### 필요 작업
```dart
// 1. Supabase 테이블 활용
favorites {
  id: uuid
  user_id: uuid (references profiles)
  drug_id: string
  drug_name: string
  drug_image: string
  created_at: timestamp
}

// 2. Repository 구현
lib/features/drug/data/repositories/favorites_repository.dart
- addFavorite(drugId, drugInfo)
- removeFavorite(drugId)
- getFavorites()
- isFavorite(drugId)

// 3. UI 구현
lib/features/drug/presentation/pages/favorites_page.dart
- 즐겨찾기 목록 그리드/리스트 뷰
- 삭제 기능
- 약품 상세로 이동
```

#### UI 위치
- 약품 상세 페이지 우측 상단에 하트 아이콘
- 홈 화면 상단에 "즐겨찾기" 섹션
- 설정 페이지에서 "즐겨찾기 관리" 메뉴

---

### 2. 내가 먹는 약 등록 (My Medications)
**우선순위: 높음**

#### 구현 내용
- 현재 복용 중인 약물 등록
- 복용 일정 설정
- 약물 정보 API 활용 (이미 있다고 함)

#### 필요 작업
```dart
// 1. Supabase 테이블 활용
user_medications {
  id: uuid
  user_id: uuid (references profiles)
  drug_id: string
  drug_name: string
  dosage: string (예: "1일 2회")
  start_date: date
  end_date: date (nullable)
  notes: text
  is_active: boolean
  created_at: timestamp
}

medication_schedules {
  id: uuid
  medication_id: uuid (references user_medications)
  time: time (예: "08:00", "20:00")
  days_of_week: array (예: [1,2,3,4,5])
  notification_enabled: boolean
}

// 2. Repository 구현
lib/features/medication/data/repositories/medication_repository.dart
- addMedication(medicationInfo)
- updateMedication(id, medicationInfo)
- deleteMedication(id)
- getMyMedications()
- toggleMedication(id, isActive)

// 3. UI 구현
lib/features/medication/presentation/pages/
  - my_medications_page.dart (목록)
  - add_medication_page.dart (등록)
  - medication_schedule_page.dart (일정 설정)
```

#### API 활용
```dart
// 약물 검색 API 활용
GET /api/drug/search?query={약품명}
- 자동완성 기능
- 약품 선택 후 상세 정보 자동 입력
```

#### UI 플로우
1. "내가 먹는 약" 메뉴 → 목록 페이지
2. "+" 버튼 → 약품 검색
3. 약품 선택 → 복용 정보 입력
4. 알림 설정 (선택)

---

### 3. 알러지 정보 수정
**우선순위: 중간**

#### 구현 내용
- 프로필 설정에서 알러지 정보 추가/삭제
- 태그 형식으로 관리
- 약품 분석 시 알러지 경고 표시

#### 필요 작업
```dart
// 1. Profile 엔티티 활용 (이미 있음)
Profile {
  ...
  allergies: List<String>?
  ...
}

// 2. UI 구현
lib/features/settings/presentation/widgets/allergy_edit_widget.dart
- 칩(Chip) 형태로 알러지 표시
- 추가: TextField + 추가 버튼
- 삭제: 칩의 X 버튼
- 일반적인 알러지 목록 제공 (선택 가능)

// 3. 알러지 체크 로직
lib/features/drug/domain/usecases/check_allergy.dart
- 약품 성분과 사용자 알러지 비교
- 경고 다이얼로그 표시
```

#### 일반적인 알러지 목록
```dart
const commonAllergies = [
  '페니실린',
  '아스피린',
  '설파제',
  'NSAIDs',
  '락토스',
  '글루텐',
  '계란',
  '견과류',
  '유제품',
  '조개류'
];
```

---

### 4. 촬영 내역 저장/조회
**우선순위: 높음**

#### 구현 내용
- 카메라 촬영 후 자동 저장
- 촬영 내역 목록 조회
- 날짜별 필터링
- 상세 보기 및 삭제

#### 필요 작업
```dart
// 1. Supabase 테이블 활용
captures {
  id: uuid
  user_id: uuid (references profiles)
  image_url: string
  capture_type: enum ('single', 'multiple')
  created_at: timestamp
}

capture_results {
  id: uuid
  capture_id: uuid (references captures)
  drug_id: string
  drug_name: string
  confidence: decimal
  position: jsonb (x, y 좌표 for multiple)
}

// 2. Repository 구현
lib/features/history/data/repositories/capture_repository.dart
- saveCapture(imageUrl, results)
- getCaptureHistory(userId, dateRange?)
- getCaptureDetail(captureId)
- deleteCapture(captureId)

// 3. UI 구현
lib/features/history/presentation/pages/capture_history_page.dart
- 달력 뷰 또는 리스트 뷰
- 썸네일 이미지
- 촬영 날짜/시간
- 인식된 약품 개수
- 상세 보기 → 원본 이미지 + 인식 결과
```

#### UI/UX
- 홈 화면에 "최근 촬영" 섹션 (이미 UI 있음 - 연동 필요)
- 설정 > 촬영 내역 메뉴
- 무한 스크롤 페이지네이션
- 월별 그룹핑

---

### 5. 복약 알림 서비스
**우선순위: 중간**

#### 구현 내용
- 설정한 시간에 복약 알림
- 로컬 푸시 알림
- 복용 체크 기능
- 복약 기록 저장

#### 필요 작업
```dart
// 1. 패키지 설치
dependencies:
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.2
  flutter_native_timezone: ^2.0.0

// 2. 알림 서비스 구현
lib/core/services/notification_service.dart
- 초기화
- 권한 요청
- 스케줄 알림 설정
- 알림 취소
- 알림 클릭 핸들링

// 3. Supabase 테이블 활용
medication_logs {
  id: uuid
  medication_id: uuid (references user_medications)
  scheduled_time: timestamp
  taken_time: timestamp (nullable)
  status: enum ('pending', 'taken', 'skipped', 'late')
  notes: text
}

// 4. Repository 구현
lib/features/medication/data/repositories/medication_log_repository.dart
- logMedication(medicationId, status)
- getTodayLogs()
- getLogHistory(dateRange)
- updateLogStatus(logId, status)
```

#### 알림 플로우
1. 약물 등록 시 알림 시간 설정
2. 백그라운드에서 스케줄 실행
3. 알림 표시: "[약품명] 복용 시간입니다"
4. 알림 클릭 → 복약 체크 화면
5. 복용 확인/건너뛰기/나중에

#### UI 구현
```dart
lib/features/medication/presentation/pages/
  - medication_reminder_page.dart (알림 설정)
  - medication_check_page.dart (복용 체크)
  - medication_history_page.dart (복약 기록)
```

---

## 📱 네비게이션 구조 업데이트

```dart
// 새로운 라우트 추가
/favorites                 // 즐겨찾기 목록
/medications              // 내가 먹는 약
/medications/add          // 약 추가
/medications/:id/schedule // 복약 일정
/history                  // 촬영 내역
/history/:id              // 촬영 상세
/settings/allergies       // 알러지 관리
/reminders               // 알림 설정
```

---

## 🎨 UI/UX 가이드라인

### 공통 컴포넌트
1. **약품 카드**: 즐겨찾기, 내가 먹는 약에서 재사용
2. **알림 시간 선택기**: iOS 스타일 시간 선택
3. **태그 입력**: 알러지, 약품 카테고리
4. **빈 상태 화면**: 데이터 없을 때 안내

### 색상 사용
- 즐겨찾기: `AppColors.error` (빨간 하트)
- 복약 완료: `AppColors.success` (초록 체크)
- 복약 미완료: `AppColors.warning` (노란 경고)
- 알러지 경고: `AppColors.error` (빨간 배경)

---

## 🔄 데이터 동기화

### 오프라인 지원
```dart
// SharedPreferences 활용
- 즐겨찾기 캐싱
- 최근 촬영 캐싱
- 복약 일정 캐싱

// 온라인 복구 시 동기화
- 충돌 해결: 서버 데이터 우선
- 로컬 변경사항 큐잉
```

---

## 📊 우선순위 매트릭스

| 기능 | 중요도 | 난이도 | 구현 순서 |
|------|--------|--------|-----------|
| 촬영 내역 저장/조회 | 높음 | 낮음 | 1 |
| 약물 즐겨찾기 | 높음 | 낮음 | 2 |
| 내가 먹는 약 등록 | 높음 | 중간 | 3 |
| 알러지 정보 수정 | 중간 | 낮음 | 4 |
| 복약 알림 서비스 | 중간 | 높음 | 5 |

---

## 🚧 추가 고려사항

1. **성능 최적화**
   - 이미지 압축 및 썸네일 생성
   - 페이지네이션 구현
   - 캐싱 전략

2. **보안**
   - 민감한 의료 정보 암호화
   - 권한 체크 강화

3. **접근성**
   - 시각 장애인을 위한 TTS
   - 큰 텍스트 모드 지원

4. **분석**
   - 복약 준수율 통계
   - 자주 검색하는 약품 분석

---

## 📅 예상 개발 일정

- **1주차**: 촬영 내역 + 즐겨찾기
- **2주차**: 내가 먹는 약 등록
- **3주차**: 알러지 정보 + 복약 알림
- **4주차**: 테스트 및 안정화

---

작성자: Claude Code
최종 수정: 2025년 9월 5일