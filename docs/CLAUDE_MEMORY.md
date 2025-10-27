# CLAUDE_MEMORY.md - PillSnap 핵심 규칙 (2025-09-19 v11 최신)

## 절대 수칙 10개

1. **폴더구조**: `features/<feature>/{presentation,domain,data}` 계층 필수
2. **파일명**: 모든 파일 `snake_case.dart` (UPPERCASE 금지)
3. **라우팅**: `go_router` 사용, 경로는 `route_paths.dart` 상수만 ✅
4. **상태관리**: Riverpod `AsyncNotifier/Notifier`만 (StateProvider 금지)
5. **스타일**: 하드코딩 금지, `AppColors/AppSpacing/AppTypography` 토큰만
6. **국제화**: 모든 문자열 ARB 파일, 문장 2줄 제한
7. **모델**: `freezed` + `json_serializable` 필수
8. **에러처리**: `Either<Failure, T>` 또는 `try-catch` 패턴
9. **위젯크기**: 150줄 초과 금지, 작게 분리
10. **withOpacity 금지**: `withValues(alpha: value)` 사용 필수 ✅

## 즉시 실행 명령 (2025-09-19 갱신)

```bash
# 환경변수 실행
flutter run \
  --dart-define=API_URL=https://api.pillsnap.co.kr \
  --dart-define=API_KEY=YOUR_API_KEY_HERE \
  --dart-define=SUPABASE_URL=https://dcpuiwszzyoojgikszaa.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# iOS 시뮬레이터 실행
flutter build ios --simulator
flutter run -d iPhone

# 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## 현재 진행 상태 (2025-09-19 v11)

### 완료된 Phase (95% 완료) 🎉
- ✅ Phase 0: 기본 설정
- ✅ Phase 1: Auth (Supabase 연동 완료)
- ✅ Phase 2: Onboarding
- ✅ Phase 3: Home
- ✅ Phase 4: Camera (촬영 기능 연동 완료)
- ✅ Phase 5: Drug Detail (구현 완료)
- ✅ Phase 6: Settings (완전 구현 완료)
- ✅ Phase 8: 라우팅 통합 (route_paths.dart 완료)
- ✅ Phase 9: i18n (ARB 파일 생성 완료)

### 진행중/대기
- 🔄 Phase 7: 공통 컴포넌트 (부분 완료)
- ⏸️ Phase 10: 최종 검증 (테스트 작성 선택사항)

## 완료된 핵심 작업 ✅

1. **route_paths.dart 생성** ✅ 완료
2. **Settings 페이지 구현** ✅ 완료
3. **withOpacity → withValues 교체** ✅ 완료 (132개 사용 중)
4. **API 연동** ✅ 완료
5. **Supabase 인증** ✅ 완료

## 남은 작업 (선택사항)

### 낮은 우선순위
1. **테스트 코드 작성** 🟢 (난이도: M, 3시간) - 선택사항
2. **공통 컴포넌트 정리** 🟢 (난이도: S, 1시간) - 선택사항
3. **CI/CD 파이프라인** 🟢 (난이도: M, 2시간) - 선택사항

### 추가 기능 (향후)
1. **즐겨찾기 기능** - favorites 테이블 활용
2. **촬영 내역 저장** - captures 테이블 활용
3. **iOS macro 렌즈 지원** - 네이티브 코드
4. **알러지 정보 관리** - profiles 확장

## 백엔드 정보

### API (pillsnap.co.kr)
- 용도: 약품 이미지 분석
- URL: https://api.pillsnap.co.kr
- Key: YOUR_API_KEY_HERE
- 상태: 정상 운영 중

### Supabase
- 용도: 사용자 인증, 데이터 저장
- URL: https://dcpuiwszzyoojgikszaa.supabase.co
- 테이블: profiles, captures, favorites, user_medications (예정)
- 상태: 정상 운영 중

## 핵심 아키텍처 원칙

- **Feature-first**: 기능별 모듈화 ✅
- **Clean Architecture**: presentation → domain ← data ✅
- **Riverpod 최신 API**: AsyncNotifier/Notifier만 ✅
- **go_router**: 모든 라우팅 중앙 관리 ✅
- **freezed**: 모든 모델/상태 불변 객체 ✅
- **토큰 시스템**: 하드코딩 절대 금지 ✅

## 프로젝트 상태 요약

**앱 빌드 가능 상태**: ✅ 준비 완료
- iOS 시뮬레이터: 정상 인식
- 디스크 공간: 17GB 여유
- Flutter Doctor: 모든 항목 통과
- 핵심 기능: 95% 구현 완료