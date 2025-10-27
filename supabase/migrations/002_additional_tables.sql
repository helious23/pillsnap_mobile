-- ====================================
-- PillSnap 추가 테이블 마이그레이션
-- ====================================

-- 1. 즐겨찾기 테이블
CREATE TABLE IF NOT EXISTS favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  drug_id TEXT NOT NULL,  -- 약품 고유 ID (API에서 제공)
  drug_name TEXT NOT NULL,
  drug_image TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- 중복 방지
  UNIQUE(user_id, drug_id)
);

-- 2. 검색 기록 테이블
CREATE TABLE IF NOT EXISTS search_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  search_type TEXT NOT NULL CHECK (search_type IN ('camera', 'text', 'barcode')),
  query TEXT,  -- 텍스트 검색의 경우
  drug_id TEXT,  -- 검색 결과 약품 ID
  drug_name TEXT,
  searched_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. 복약 관리 테이블
CREATE TABLE IF NOT EXISTS medications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  drug_id TEXT NOT NULL,
  drug_name TEXT NOT NULL,
  dosage TEXT,  -- 용량 (예: "1정", "2ml")
  frequency TEXT,  -- 빈도 (예: "하루 3번")
  duration_days INTEGER,  -- 복용 기간 (일)
  start_date DATE NOT NULL,
  end_date DATE,
  notes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. 복약 알림 테이블
CREATE TABLE IF NOT EXISTS medication_reminders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medication_id UUID REFERENCES medications(id) ON DELETE CASCADE NOT NULL,
  reminder_time TIME NOT NULL,
  repeat_days TEXT[] DEFAULT ARRAY['MON','TUE','WED','THU','FRI','SAT','SUN'],  -- 반복 요일
  is_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- 동일 약물에 대한 동일 시간 중복 방지
  CONSTRAINT uq_reminder_time UNIQUE (medication_id, reminder_time)
);

-- 5. 약물 상호작용 체크 테이블
CREATE TABLE IF NOT EXISTS drug_interactions (
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

-- 6. 사용자 피드백 테이블
CREATE TABLE IF NOT EXISTS user_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  capture_id UUID REFERENCES captures(id) ON DELETE SET NULL,
  feedback_type TEXT NOT NULL CHECK (feedback_type IN ('wrong_drug', 'missing_info', 'ui_issue', 'other')),
  is_correct BOOLEAN,  -- 약품 식별이 정확했는지
  correct_drug_name TEXT,  -- 사용자가 제공한 올바른 약품명
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 7. 알림 설정 테이블
CREATE TABLE IF NOT EXISTS notification_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  push_enabled BOOLEAN DEFAULT TRUE,
  medication_reminders BOOLEAN DEFAULT TRUE,
  interaction_alerts BOOLEAN DEFAULT TRUE,
  app_updates BOOLEAN DEFAULT FALSE,
  marketing BOOLEAN DEFAULT FALSE,
  quiet_hours_start TIME,  -- 방해금지 시작 시간
  quiet_hours_end TIME,    -- 방해금지 종료 시간
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 8. 약품 캐시 테이블 (자주 조회되는 약품 정보 캐싱)
CREATE TABLE IF NOT EXISTS drug_cache (
  drug_id TEXT PRIMARY KEY,
  drug_name TEXT NOT NULL,
  manufacturer TEXT,
  drug_data JSONB NOT NULL,  -- API 응답 전체 저장
  cached_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days') NOT NULL
);

-- ====================================
-- 인덱스 생성
-- ====================================

-- 성능 최적화를 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id_drug_id ON favorites(user_id, drug_id);
CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_searched_at ON search_history(searched_at DESC);
CREATE INDEX IF NOT EXISTS idx_medications_user_id ON medications(user_id);
CREATE INDEX IF NOT EXISTS idx_medications_is_active ON medications(is_active);
CREATE INDEX IF NOT EXISTS idx_medications_user_active ON medications(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_medication_reminders_medication_id ON medication_reminders(medication_id);
CREATE INDEX IF NOT EXISTS idx_drug_interactions_user_id ON drug_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_feedback_user_id ON user_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_user_feedback_status ON user_feedback(status);
CREATE INDEX IF NOT EXISTS idx_drug_cache_expires_at ON drug_cache(expires_at);

-- ====================================
-- RLS (Row Level Security) 정책
-- ====================================

-- 모든 테이블에 RLS 활성화
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE drug_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE drug_cache ENABLE ROW LEVEL SECURITY;

-- favorites 정책
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- search_history 정책
CREATE POLICY "Users can view own search history" ON search_history
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own search history" ON search_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own search history" ON search_history
  FOR DELETE USING (auth.uid() = user_id);

-- medications 정책
CREATE POLICY "Users can manage own medications" ON medications
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- medication_reminders 정책 (medications 테이블과 조인 필요)
CREATE POLICY "Users can manage own reminders" ON medication_reminders
  FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM medications 
      WHERE medications.id = medication_reminders.medication_id 
      AND medications.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM medications 
      WHERE medications.id = medication_reminders.medication_id 
      AND medications.user_id = auth.uid()
    )
  );

-- drug_interactions 정책
CREATE POLICY "Users can manage own drug interactions" ON drug_interactions
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- user_feedback 정책
CREATE POLICY "Users can manage own feedback" ON user_feedback
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- notification_settings 정책
CREATE POLICY "Users can manage own notification settings" ON notification_settings
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- drug_cache 정책 (모든 사용자가 읽기 가능)
CREATE POLICY "Anyone can view drug cache" ON drug_cache
  FOR SELECT USING (true);
CREATE POLICY "System can manage drug cache" ON drug_cache
  FOR ALL 
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- ====================================
-- 트리거 함수
-- ====================================

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- medications 테이블에 트리거 적용
CREATE TRIGGER update_medications_updated_at
  BEFORE UPDATE ON medications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- notification_settings 테이블에 트리거 적용
CREATE TRIGGER update_notification_settings_updated_at
  BEFORE UPDATE ON notification_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 사용자 가입시 기본 알림 설정 생성
CREATE OR REPLACE FUNCTION create_default_notification_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_user_created_notification_settings
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_notification_settings();

-- ====================================
-- 뷰 생성 (선택사항)
-- ====================================

-- 활성 복약 정보와 알림을 조인한 뷰
CREATE OR REPLACE VIEW active_medications_with_reminders AS
SELECT 
  m.*,
  ARRAY_AGG(
    jsonb_build_object(
      'id', r.id,
      'reminder_time', r.reminder_time,
      'repeat_days', r.repeat_days,
      'is_enabled', r.is_enabled
    ) ORDER BY r.reminder_time
  ) FILTER (WHERE r.id IS NOT NULL) AS reminders
FROM medications m
LEFT JOIN medication_reminders r ON m.id = r.medication_id
WHERE m.is_active = true
GROUP BY m.id;

-- 최근 검색 기록 요약 뷰
CREATE OR REPLACE VIEW recent_search_summary AS
SELECT 
  user_id,
  COUNT(*) AS total_searches,
  COUNT(DISTINCT drug_id) AS unique_drugs,
  MAX(searched_at) AS last_search,
  ARRAY_AGG(DISTINCT drug_name ORDER BY drug_name) 
    FILTER (WHERE drug_name IS NOT NULL) AS searched_drugs
FROM search_history
WHERE searched_at > NOW() - INTERVAL '30 days'
GROUP BY user_id;

-- ====================================
-- 주석
-- ====================================

COMMENT ON TABLE favorites IS '사용자가 자주 사용하는 약품 즐겨찾기';
COMMENT ON TABLE search_history IS '약품 검색/촬영 기록';
COMMENT ON TABLE medications IS '복약 관리 정보';
COMMENT ON TABLE medication_reminders IS '복약 알림 설정';
COMMENT ON TABLE drug_interactions IS '약물 상호작용 체크 기록';
COMMENT ON TABLE user_feedback IS '사용자 피드백 및 오류 신고';
COMMENT ON TABLE notification_settings IS '사용자별 알림 설정';
COMMENT ON TABLE drug_cache IS '자주 조회되는 약품 정보 캐시';