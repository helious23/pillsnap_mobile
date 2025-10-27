# Supabase 연동 가이드

## 개요

PillSnap Flutter 앱에 Supabase 백엔드를 연동한 문서입니다.

## ⚠️ 중요 변경사항

- **2025.01.09**: 추가 테이블 8개 생성 (Phase 2 완료)
- **uni_links → app_links**: 플러그인 교체 (MissingPluginException 해결)
- **비밀번호 규칙**: 8자 이상, 대/소문자, 숫자, 특수문자 포함

## 구현 완료 항목

### 1. 패키지 설치

```yaml
dependencies:
  supabase_flutter: ^2.8.0
  flutter_secure_storage: ^9.2.2
  app_links: ^6.3.2 # uni_links를 대체
  url_launcher: ^6.3.1
```

### 2. 구현된 파일 목록

#### 핵심 서비스

- `/lib/core/config/app_config.dart` - 앱 설정 (--dart-define 사용)
- `/lib/core/services/supabase_service.dart` - Supabase 서비스 싱글톤

#### 인증 관련

- `/lib/features/auth/domain/entities/profile.dart` - 프로필 엔티티
- `/lib/features/auth/domain/entities/user_settings.dart` - 설정 엔티티
- `/lib/features/auth/data/repositories/auth_repository.dart` - 인증 리포지토리
- `/lib/features/auth/data/repositories/profile_repository.dart` - 프로필 리포지토리
- `/lib/features/auth/data/repositories/settings_repository.dart` - 설정 리포지토리
- `/lib/features/auth/presentation/providers/auth_provider.dart` - 인증 프로바이더

#### 촬영 기록

- `/lib/features/drug/domain/entities/capture.dart` - 촬영 기록 엔티티
- `/lib/features/drug/data/repositories/capture_repository.dart` - 촬영 리포지토리

#### 딥링크 설정

- `/ios/Runner/Info.plist` - iOS 딥링크 설정 (CFBundleURLSchemes)
- `/android/app/src/main/AndroidManifest.xml` - Android 딥링크 설정

#### 라우터 수정

- `/lib/core/router/app_router.dart` - 인증 체크 로직 추가
- `/lib/main.dart` - Supabase 초기화 및 딥링크 처리

### 3. 실행 방법

#### 편리한 실행 방법

##### 1) VS Code 사용자

`.vscode/launch.json` 파일에 설정 완료.
F5 또는 Run and Debug로 실행.

##### 2) 스크립트 사용

```bash
# 실행 스크립트 사용 (권한 설정 필요)
chmod +x scripts/run_with_supabase.sh
./scripts/run_with_supabase.sh
```

##### 3) 직접 실행

```bash
flutter run \
  --dart-define=API_URL=https://api.pillsnap.co.kr \
  --dart-define=API_KEY=YOUR_API_KEY_HERE \
  --dart-define=SUPABASE_URL=https://dcpuiwszzyoojgikszaa.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE \
  --dart-define=DEBUG=true
```

#### 테스트 계정

```
이메일: test@example.com
비밀번호: Password123!
```

### 4. 주요 기능

#### 인증

- 이메일/비밀번호 회원가입
- 이메일 인증
- 로그인/로그아웃
- 비밀번호 재설정
- 세션 자동 갱신

#### 프로필

- 프로필 조회/수정
- 아바타 업로드
- 사용자 설정 관리

#### 촬영 기록

- 촬영 이미지 Storage 업로드
- 촬영 기록 DB 저장
- 내 촬영 기록 조회
- 촬영 통계

### 5. 보안 설정

#### Row Level Security (RLS)

- 모든 테이블에 RLS 활성화
- 사용자는 자신의 데이터만 접근 가능

#### 환경변수

- `--dart-define`으로 환경변수 주입
- 절대 코드에 하드코딩하지 않음

### 6. 데이터베이스 테이블

#### 현재 테이블 현황

##### ✅ Phase 1 (기본 테이블)

- `profiles` - 사용자 프로필
- `captures` - 촬영 기록

##### ✅ Phase 2 (추가 테이블 - 2025.01.09)

- `favorites` - 즐겨찾기 약품
- `search_history` - 검색 기록
- `medications` - 복약 관리
- `medication_reminders` - 복약 알림
- `drug_interactions` - 약물 상호작용
- `user_feedback` - 사용자 피드백
- `notification_settings` - 알림 설정
- `drug_cache` - 약품 정보 캐시

#### 마이그레이션 파일

1. `/supabase/migrations/001_initial_query.sql` - 기본 테이블
2. `/supabase/migrations/002_additional_tables.sql` - 추가 테이블

_Supabase Dashboard의 SQL Editor에서 순서대로 실행_

### 7. 테스트 체크리스트

- [x] 회원가입 (이메일 인증 필요)
- [x] 로그인/로그아웃
- [x] 프로필 자동 생성 (트리거)
- [x] 프로필 수정
- [x] 설정 변경 → notification_settings로 통합
- [x] 촬영 기록 저장
- [x] 이미지 업로드
- [x] 딥링크 처리
- [x] 인증 기반 라우팅
- [x] 비밀번호 유효성 검사 (8자+대소문자+숫자+특수문자)
- [x] 로그인 에러 UI (빨간 테두리, 에러 메시지)

## 다음 단계

### Phase 3 기능 구현

1. 즐겨찾기 기능 UI 연결
2. 복약 관리 UI 구현
3. 약물 상호작용 체크
4. 사용자 피드백 시스템

### 추가 기능

1. 소셜 로그인 (Google, Apple)
2. 실시간 데이터 동기화
3. 오프라인 지원
4. 푸시 알림

## 주의사항

1. **환경변수**: `--dart-define` 사용 (하드코딩 금지)
2. **비밀번호 규칙**: Supabase 요구사항 준수
   - 최소 8자
   - 대문자 포함 (A-Z)
   - 소문자 포함 (a-z)
   - 숫자 포함 (0-9)
   - 특수문자 포함 (!@#$%^&\*())
3. **Storage**: pillsnap-storage 버킷 생성 및 정책 설정 필요
4. **딥링크**: app_links 패키지 사용 (uni_links 대체)

## 에러 해결

### MissingPluginException

- **원인**: uni_links 플러그인 문제
- **해결**: app_links로 교체

```yaml
dependencies:
  app_links: ^6.3.2 # uni_links 대신 사용
```

### Invalid API key

- **원인**: ANON_KEY 잘림
- **해결**: 전체 키 사용

```dart
static const String supabaseAnonKey = 'eyJhbGci...';  // 전체 키
```

### 비밀번호 오류

- **원인**: Supabase 비밀번호 규칙 미충족
- **해결**: 8자+대문자+소문자+숫자+특수문자

### PostgreSQL 에러

- RLS 정책 확인 (WITH CHECK 포함)
- 테이블 권한 확인

### Storage 에러

- 버킷 정책 확인
- 파일 크기 제한 확인 (50MB)
