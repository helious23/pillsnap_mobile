# Supabase Database Schema Documentation

## 개요
PillSnap 앱의 백엔드 데이터베이스 스키마입니다. Supabase (PostgreSQL)를 사용하며, Row Level Security(RLS)를 통해 데이터 보안을 강화했습니다.

## 테이블 구조

### 기본 테이블 (Phase 1 - 구현 완료)

### 1. profiles (사용자 프로필)
사용자의 기본 정보를 저장하는 테이블입니다.

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);
```

**필드 설명:**
- `id`: Supabase Auth의 user id와 동일 (외래키)
- `email`: 사용자 이메일 (고유값)
- `display_name`: 표시 이름
- `phone`: 전화번호
- `avatar_url`: 프로필 이미지 URL
- `created_at`: 계정 생성 시각
- `updated_at`: 마지막 프로필 수정 시각
- `last_seen_at`: 마지막 접속 시각
- `is_active`: 계정 활성화 상태

### 2. captures (촬영 기록)
약품 촬영 기록을 저장하는 테이블입니다.

```sql
CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  roi_image_url TEXT,
  capture_mode TEXT CHECK (capture_mode IN ('single', 'multi')) DEFAULT 'single',
  pill_count INTEGER DEFAULT 1 CHECK (pill_count >= 1 AND pill_count <= 4),
  device_info JSONB,
  location JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**필드 설명:**
- `id`: 촬영 고유 ID
- `user_id`: 사용자 ID (외래키)
- `image_url`: 원본 이미지 URL
- `roi_image_url`: ROI(Region of Interest) 이미지 URL
- `capture_mode`: 촬영 모드 ('single' 또는 'multi')
- `pill_count`: 촬영된 약품 개수 (1-4개)
- `device_info`: 기기 정보 (모델, OS 버전 등)
- `location`: 위치 정보 (선택적)
- `created_at`: 촬영 시각
- `updated_at`: 마지막 수정 시각

### 추가 테이블 (Phase 2 - 구현 완료)

### 3. favorites (즐겨찾기)
자주 사용하는 약품을 즐겨찾기로 저장합니다.

```sql
CREATE TABLE favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  drug_id TEXT NOT NULL,
  drug_name TEXT NOT NULL,
  drug_image TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, drug_id)
);
```

### 4. search_history (검색 기록)
약품 검색 및 촬영 이력을 저장합니다.

```sql
CREATE TABLE search_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  search_type TEXT NOT NULL CHECK (search_type IN ('camera', 'text', 'barcode')),
  query TEXT,
  drug_id TEXT,
  drug_name TEXT,
  searched_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 5. medications (복약 관리)
현재 복용 중인 약품 목록을 관리합니다.

```sql
CREATE TABLE medications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  drug_id TEXT NOT NULL,
  drug_name TEXT NOT NULL,
  dosage TEXT,
  frequency TEXT,
  duration_days INTEGER,
  start_date DATE NOT NULL,
  end_date DATE,
  notes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 6. medication_reminders (복약 알림)
복약 알림 설정을 저장합니다.

```sql
CREATE TABLE medication_reminders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE NOT NULL,
  reminder_time TIME NOT NULL,
  repeat_days TEXT[] DEFAULT ARRAY['MON','TUE','WED','THU','FRI','SAT','SUN'],
  is_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  CONSTRAINT uq_reminder_time UNIQUE (medication_id, reminder_time)
);
```

### 7. drug_interactions (약물 상호작용)
복용 약품 간 상호작용을 체크합니다.

```sql
CREATE TABLE drug_interactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  drug_id_1 TEXT NOT NULL,
  drug_name_1 TEXT NOT NULL,
  drug_id_2 TEXT NOT NULL,
  drug_name_2 TEXT NOT NULL,
  severity TEXT CHECK (severity IN ('low', 'moderate', 'high', 'critical')),
  interaction_description TEXT,
  checked_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 8. user_feedback (사용자 피드백)
약품 식별 정확도에 대한 피드백을 수집합니다.

```sql
CREATE TABLE user_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  capture_id UUID REFERENCES captures(id) ON DELETE SET NULL,
  feedback_type TEXT NOT NULL CHECK (feedback_type IN ('wrong_drug', 'missing_info', 'ui_issue', 'other')),
  is_correct BOOLEAN,
  correct_drug_name TEXT,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 9. notification_settings (알림 설정)
사용자별 알림 설정을 관리합니다.

```sql
CREATE TABLE notification_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  push_enabled BOOLEAN DEFAULT TRUE,
  medication_reminders BOOLEAN DEFAULT TRUE,
  interaction_alerts BOOLEAN DEFAULT TRUE,
  app_updates BOOLEAN DEFAULT FALSE,
  marketing BOOLEAN DEFAULT FALSE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

### 10. drug_cache (약품 캐시)
자주 조회되는 약품 정보를 캐싱합니다.

```sql
CREATE TABLE drug_cache (
  drug_id TEXT PRIMARY KEY,
  drug_name TEXT NOT NULL,
  manufacturer TEXT,
  drug_data JSONB NOT NULL,
  cached_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days') NOT NULL
);
```

### 기존 테이블 (삭제 예정)

### drug_results (약품 식별 결과) - 더 이상 사용 안 함
*Note: API 직접 호출로 대체되어 사용하지 않음*

```sql
CREATE TABLE drug_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  capture_id UUID REFERENCES captures(id) ON DELETE CASCADE NOT NULL,
  drug_name TEXT NOT NULL,
  manufacturer TEXT,
  drug_code TEXT,
  drug_type TEXT,
  ingredients JSONB,
  efficacy TEXT,
  usage_instructions TEXT,
  precautions TEXT,
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  pill_index INTEGER DEFAULT 0,
  verification_status TEXT CHECK (verification_status IN ('pending', 'verified', 'rejected')) DEFAULT 'pending',
  verified_by UUID REFERENCES profiles(id),
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**필드 설명:**
- `id`: 결과 고유 ID
- `capture_id`: 촬영 ID (외래키)
- `drug_name`: 약품명
- `manufacturer`: 제조사
- `drug_code`: 약품 코드
- `drug_type`: 약품 종류
- `ingredients`: 성분 정보 (JSON 형태)
- `efficacy`: 효능/효과
- `usage_instructions`: 용법/용량
- `precautions`: 주의사항
- `confidence_score`: AI 신뢰도 점수 (0-1)
- `pill_index`: 다중 촬영 시 약품 인덱스
- `verification_status`: 검증 상태
- `verified_by`: 검증한 약사/전문가 ID
- `verified_at`: 검증 시각

### user_settings (사용자 설정) - 더 이상 사용 안 함
*Note: notification_settings 테이블로 대체됨*

```sql
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  language TEXT DEFAULT 'ko',
  theme TEXT DEFAULT 'light',
  notification_enabled BOOLEAN DEFAULT true,
  email_notification BOOLEAN DEFAULT true,
  push_notification BOOLEAN DEFAULT true,
  auto_save_captures BOOLEAN DEFAULT true,
  privacy_mode BOOLEAN DEFAULT false,
  preferred_camera_mode TEXT DEFAULT 'single',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**필드 설명:**
- `user_id`: 사용자 ID (기본키, 외래키)
- `language`: 언어 설정 (기본값: 'ko')
- `theme`: 테마 설정 (기본값: 'light')
- `notification_enabled`: 알림 활성화
- `email_notification`: 이메일 알림
- `push_notification`: 푸시 알림
- `auto_save_captures`: 촬영 자동 저장
- `privacy_mode`: 프라이버시 모드
- `preferred_camera_mode`: 선호하는 카메라 모드

## 인덱스

성능 최적화를 위한 인덱스 설정:

### 기본 인덱스

```sql
-- 사용자별 촬영 조회 최적화
CREATE INDEX idx_captures_user_id_created_at ON captures(user_id, created_at DESC);

-- 촬영별 결과 조회 최적화
CREATE INDEX idx_drug_results_capture_id ON drug_results(capture_id);

-- 약품명 검색 최적화
CREATE INDEX idx_drug_results_drug_name ON drug_results(drug_name);

-- JSONB 필드 검색 최적화
CREATE INDEX idx_drug_results_ingredients ON drug_results USING gin(ingredients);
CREATE INDEX idx_captures_device_info ON captures USING gin(device_info);

### 추가 인덱스 (Phase 2)

-- 즐겨찾기 복합 인덱스
CREATE INDEX idx_favorites_user_id_drug_id ON favorites(user_id, drug_id);

-- 검색 기록 인덱스
CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_search_history_searched_at ON search_history(searched_at DESC);

-- 복약 관리 인덱스
CREATE INDEX idx_medications_user_active ON medications(user_id, is_active);
CREATE INDEX idx_medication_reminders_medication_id ON medication_reminders(medication_id);

-- 피드백 및 캐시 인덱스
CREATE INDEX idx_user_feedback_status ON user_feedback(status);
CREATE INDEX idx_drug_cache_expires_at ON drug_cache(expires_at);
```

## Row Level Security (RLS) 정책

### profiles 테이블
```sql
-- 사용자는 자신의 프로필만 조회 가능
CREATE POLICY "Users can view own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

-- 사용자는 자신의 프로필만 수정 가능
CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);
```

### captures 테이블
```sql
-- 사용자는 자신의 촬영만 조회 가능
CREATE POLICY "Users can view own captures" 
  ON captures FOR SELECT 
  USING (auth.uid() = user_id);

-- 사용자는 자신의 촬영만 생성 가능
CREATE POLICY "Users can insert own captures" 
  ON captures FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- 사용자는 자신의 촬영만 삭제 가능
CREATE POLICY "Users can delete own captures" 
  ON captures FOR DELETE 
  USING (auth.uid() = user_id);
```

### drug_results 테이블
```sql
-- 사용자는 자신의 촬영 결과만 조회 가능
CREATE POLICY "Users can view own drug results" 
  ON drug_results FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM captures 
      WHERE captures.id = drug_results.capture_id 
      AND captures.user_id = auth.uid()
    )
  );
```

### 추가 테이블 RLS 정책 (Phase 2)

```sql
-- favorites 정책
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- medications 정책 (WITH CHECK 추가)
CREATE POLICY "Users can manage own medications" ON medications
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- notification_settings 정책 (WITH CHECK 추가)
CREATE POLICY "Users can manage own notification settings" ON notification_settings
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- drug_cache 정책
CREATE POLICY "Anyone can view drug cache" ON drug_cache
  FOR SELECT USING (true);
CREATE POLICY "System can manage drug cache" ON drug_cache
  FOR ALL 
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');
```

## 트리거

### 1. 프로필 자동 생성
새 사용자 가입 시 자동으로 프로필 생성:

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  
  INSERT INTO public.notification_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

### 2. updated_at 자동 갱신
데이터 수정 시 updated_at 필드 자동 갱신:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 각 테이블에 트리거 적용
CREATE TRIGGER update_profiles_updated_at 
  BEFORE UPDATE ON profiles 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_captures_updated_at 
  BEFORE UPDATE ON captures 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drug_results_updated_at 
  BEFORE UPDATE ON drug_results 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medications_updated_at 
  BEFORE UPDATE ON medications 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_settings_updated_at 
  BEFORE UPDATE ON notification_settings 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
```

## Storage 구조

Supabase Storage 버킷 구성:

```
pillsnap-storage/
├── avatars/          # 프로필 이미지
│   └── {user_id}/
│       └── avatar.png
├── captures/         # 촬영 이미지
│   └── {user_id}/
│       └── {capture_id}/
│           ├── original.jpg
│           └── roi.jpg
└── temp/            # 임시 파일 (24시간 후 자동 삭제)
```

### Storage 정책
```sql
-- 사용자는 자신의 폴더에만 접근 가능
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'pillsnap-storage' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view own images"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'pillsnap-storage' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

## Flutter 연동 가이드

### 1. 의존성 추가
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

### 2. 초기화
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(MyApp());
}
```

### 3. 데이터 접근 예시
```dart
// 촬영 기록 조회
final captures = await Supabase.instance.client
  .from('captures')
  .select('*, drug_results(*)')
  .order('created_at', ascending: false);

// 새 촬영 추가
final result = await Supabase.instance.client
  .from('captures')
  .insert({
    'user_id': userId,
    'image_url': imageUrl,
    'capture_mode': 'single',
    'pill_count': 1,
  })
  .select()
  .single();
```

## 마이그레이션 노트

### 초기 설정
1. Supabase 프로젝트 생성
2. SQL Editor에서 위 스키마 실행
3. Authentication 설정 (이메일 인증 활성화)
4. Storage 버킷 생성 및 정책 설정
5. 환경 변수 설정 (URL, Anon Key)

### 보안 고려사항
- RLS 정책이 모든 테이블에 활성화되어 있는지 확인
- Storage 버킷 정책이 올바르게 설정되어 있는지 확인
- 민감한 정보는 환경 변수로 관리
- API 키는 절대 코드에 하드코딩하지 않음

## 성능 최적화

### 쿼리 최적화 팁
1. 필요한 필드만 select하기
2. 페이지네이션 사용 (limit, offset)
3. 인덱스가 있는 필드로 검색
4. JSONB 필드는 GIN 인덱스 활용

### 캐싱 전략
1. 자주 조회되는 약품 정보는 로컬 캐싱
2. 프로필 정보는 앱 시작 시 한 번만 로드
3. 이미지는 CDN 캐싱 활용

## 구현 상태

### ✅ Phase 1 (기본 기능) - 완료
- profiles: 사용자 프로필
- captures: 촬영 기록
- 인증 시스템 연동
- 이미지 업로드

### ✅ Phase 2 (확장 기능) - 완료
- favorites: 약품 즐겨찾기
- search_history: 검색 기록
- medications: 복약 관리
- medication_reminders: 복약 알림
- drug_interactions: 약물 상호작용
- user_feedback: 사용자 피드백
- notification_settings: 알림 설정
- drug_cache: 약품 정보 캐싱

### 🔄 Phase 3 (예정)
- 약사 검증 시스템
- 커뮤니티 기능
- AI 모델 개선 피드백 루프

## 마이그레이션 파일

### 실행 순서
1. `/supabase/migrations/001_initial_query.sql` - 기본 테이블 생성
2. `/supabase/migrations/002_additional_tables.sql` - 추가 테이블 생성

*Note: Supabase Dashboard의 SQL Editor에서 순서대로 실행*