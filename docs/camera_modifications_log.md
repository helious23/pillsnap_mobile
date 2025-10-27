# 카메라 기능 변경 이력

## 변경 날짜: 2025-09-03

### 초기 시도: iPhone 다중 렌즈 환경 개선 (실패)

#### 시도한 내용
1. **LensBias 시스템 구현**
   - macro(0.5x), normal(1.0x), far(2.0x+) 프리셋 추가
   - iOS 렌즈 자동 전환 유도 로직
   - 촬영 전 렌즈 보정 로직 (_applyPreCaptureCorrection)

2. **복잡한 포커스 시스템**
   - 재시도 로직
   - 포커스/노출 모드 자동 전환
   - iOS 특화 딜레이 및 안정화

3. **LensPresetSwitcher 위젯**
   - 아이콘 기반 렌즈 프리셋 UI
   - 애니메이션 효과

#### 실패 이유
- **복잡도만 증가**: 코드는 복잡해졌으나 실제 작동하지 않음
- **렌즈 전환 실패**: iOS 카메라가 예상대로 렌즈를 전환하지 않음
- **포커스 문제 지속**: 복잡한 로직에도 불구하고 초점이 맞지 않음

### 1차 수정: SimpleZoomSelector로 단순화

#### 변경 내용
1. **LensBias 시스템 제거**
   - enum, 관련 state 필드, 모든 메서드 삭제
   - 촬영 전 보정 로직 제거

2. **SimpleZoomSelector 위젯 생성**
   - 직접적인 줌 값 사용 (0.5×, 1×, 2×)
   - 단순한 버튼 UI

3. **메서드 단순화**
   ```dart
   // setZoom: 최소/최대 범위 체크 후 직접 설정
   // setFocusPoint: 재시도 없이 단순 설정
   ```

#### 결과
- 코드 복잡도 감소
- 실제 줌 기능 작동
- Flutter analyze 통과

### 최종 수정: 모든 추가 기능 제거

#### 사용자 요청
"그냥 기능을 없애자. 위에 0.5,1,2는 위젯도 없애고 기능도 다시 돌려놔."

#### 변경 내용
1. **SimpleZoomSelector 완전 제거**
   - 위젯 파일 삭제
   - camera_page.dart에서 import 및 사용 제거

2. **원래 상태로 복원**
   ```dart
   // setZoom: 최소한의 로직만 유지
   Future<void> setZoom(double zoom) async {
     final currentState = state.valueOrNull;
     if (currentState == null || !currentState.isInitialized) return;
     
     try {
       await currentState.controller!.setZoomLevel(zoom);
       state = AsyncValue.data(
         currentState.copyWith(currentZoom: zoom),
       );
     } catch (e) {
       debugPrint('줌 설정 실패: $e');
     }
   }
   
   // setFocusPoint: 기본 기능만 유지
   Future<void> setFocusPoint(Offset point) async {
     final currentState = state.valueOrNull;
     if (currentState?.controller == null || !currentState!.isInitialized) return;
     
     try {
       await currentState.controller!.setFocusPoint(point);
       await currentState.controller!.setExposurePoint(point);
       
       state = AsyncValue.data(
         currentState.copyWith(lastFocusPoint: point),
       );
     } catch (e) {
       debugPrint('포커스 설정 실패: $e');
     }
   }
   ```

## 최종 상태 (2025-09-03 기준)

### 제거된 파일
- `lib/features/camera/presentation/widgets/lens_preset_switcher.dart`
- `lib/features/camera/presentation/widgets/simple_zoom_selector.dart`

### 수정된 파일
1. **camera_controller.dart**
   - LensBias enum 제거
   - CameraState에서 currentLensBias 필드 제거
   - setLensBias, cycleLensBias, _applyPreCaptureCorrection 메서드 제거
   - setZoom, setFocusPoint 단순화

2. **camera_page.dart**
   - SimpleZoomSelector import 및 사용 제거
   - dart:io import 제거 (사용하지 않음)

### 현재 기능
- **하단 줌 컨트롤**: 1x, 2x, 3x 버튼 (camera_controls.dart)
- **탭하여 포커스**: 화면 탭으로 초점 설정
- **기본 카메라 기능**: 촬영, 플래시, 갤러리 선택

### 교훈
1. **단순함이 최선**: 복잡한 iOS 특화 로직보다 기본 API가 더 안정적
2. **실제 작동 우선**: 이론적으로 정교한 코드보다 실제로 작동하는 단순한 코드가 낫다
3. **점진적 개선**: 한 번에 모든 것을 해결하려 하지 말고 작은 단위로 테스트하며 진행

## 향후 개선 제안
만약 iPhone 렌즈 문제를 다시 해결하려 한다면:
1. 각 기능을 독립적으로 테스트
2. 실제 기기에서 줌 레벨과 렌즈 전환 관계 매핑
3. 사용자 피드백을 받아가며 점진적 개선