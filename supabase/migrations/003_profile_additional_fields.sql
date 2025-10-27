-- ====================================
-- profiles 테이블에 추가 필드 마이그레이션
-- ====================================

-- profiles 테이블에 추가 컬럼 생성
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('male', 'female', 'other', NULL)),
ADD COLUMN IF NOT EXISTS allergies TEXT[];

-- 컬럼 설명 추가
COMMENT ON COLUMN public.profiles.birth_date IS '생년월일 - 연령별 약물 복용량 확인용';
COMMENT ON COLUMN public.profiles.gender IS '성별 - 성별에 따른 약물 반응 차이 확인용';
COMMENT ON COLUMN public.profiles.allergies IS '알레르기 정보 배열 - 약물 알레르기 체크용';