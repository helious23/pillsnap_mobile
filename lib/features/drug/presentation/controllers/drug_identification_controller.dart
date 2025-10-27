import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_identification_data.dart';

/// 약품 식별 정보 수집 상태 관리
class DrugIdentificationNotifier extends StateNotifier<DrugIdentificationData> {
  DrugIdentificationNotifier() : super(DrugIdentificationData());

  /// 텍스트 업데이트 (기존 호환성 유지)
  void updateText(String? text, {String? position}) {
    state = state.copyWith(
      text: text,
      textPosition: position ?? state.textPosition,
    );
  }
  
  /// 앞면/뒷면 텍스트 업데이트
  void updateTexts({String? front, String? back}) {
    state = state.copyWith(
      textFront: front?.toUpperCase(), // 자동 대문자 변환
      textBack: back?.toUpperCase(),
    );
  }
  
  /// 마크 업데이트
  void updateMark(String? mark) {
    state = state.copyWith(mark: mark);
  }
  
  /// 분할선 업데이트
  void updateLines({String? front, String? back}) {
    state = state.copyWith(
      lineFront: front,
      lineBack: back,
    );
  }

  /// 색상 업데이트
  void updateColors(List<String> colors) {
    state = state.copyWith(colors: colors);
  }

  /// 색상 추가
  void addColor(String color) {
    if (!state.colors.contains(color)) {
      state = state.copyWith(colors: [...state.colors, color]);
    }
  }

  /// 색상 제거
  void removeColor(String color) {
    state = state.copyWith(
      colors: state.colors.where((c) => c != color).toList(),
    );
  }

  /// 모양 업데이트 (복수 선택)
  void updateShapes(List<String> shapes) {
    state = state.copyWith(shapes: shapes);
  }
  
  /// 모양 추가/제거 토글
  void toggleShape(String shape) {
    if (state.shapes.contains(shape)) {
      state = state.copyWith(
        shapes: state.shapes.where((s) => s != shape).toList(),
      );
    } else {
      state = state.copyWith(
        shapes: [...state.shapes, shape],
      );
    }
  }
  
  /// 모양 설정 (단일 - 레거시 호환)
  void setShape(String? shape) {
    if (shape == null) {
      state = state.copyWith(shapes: []);
    } else {
      state = state.copyWith(shapes: [shape]);
    }
  }
  
  /// 제형 설정
  void setForm(String? form) {
    state = state.copyWith(form: form);
  }

  /// 크기 업데이트
  void updateSize(String? size) {
    state = state.copyWith(size: size);
  }

  /// 특수 특징 업데이트
  void updateSpecialFeatures({
    bool? hasScoreLine,
    bool? hasCoating,
    String? specialFeatures,
  }) {
    state = state.copyWith(
      hasScoreLine: hasScoreLine ?? state.hasScoreLine,
      hasCoating: hasCoating ?? state.hasCoating,
      specialFeatures: specialFeatures ?? state.specialFeatures,
    );
  }

  /// 추가 정보 업데이트
  void updateAdditionalInfo({
    String? drugType,
    String? suspectedName,
    String? notes,
  }) {
    state = state.copyWith(
      drugType: drugType ?? state.drugType,
      suspectedName: suspectedName ?? state.suspectedName,
      notes: notes ?? state.notes,
    );
  }

  /// 초기화
  void reset() {
    state = DrugIdentificationData();
  }

  /// 단계별 검증
  bool isStepValid(int step) {
    switch (step) {
      case 1: // 텍스트는 선택적이지만 권장
        return true; // 건너뛸 수 있음
      case 2: // 색상
        return state.colors.isNotEmpty;
      case 3: // 모양
        return state.shapes.isNotEmpty;
      case 4: // 크기
        return state.size != null && state.size!.isNotEmpty;
      case 5: // 특수 특징
        return true; // 선택적
      case 6: // 추가 정보
        return true; // 선택적
      default:
        return false;
    }
  }

  /// 필수 정보가 있는지 확인
  bool get hasMinimumInfo {
    // 최소 색상과 모양은 있어야 함
    return state.colors.isNotEmpty && state.shapes.isNotEmpty;
  }

  /// 텍스트 입력 여부
  bool get hasTextInput {
    return (state.text != null && state.text!.isNotEmpty) ||
           (state.textFront != null && state.textFront!.isNotEmpty) ||
           (state.textBack != null && state.textBack!.isNotEmpty);
  }
  
  /// 마크 입력 여부
  bool get hasMarkInput {
    return state.mark != null && state.mark!.isNotEmpty;
  }
  
  /// 식별 정보 입력 여부 (텍스트 또는 마크)
  bool get hasIdentificationInfo {
    return hasTextInput || hasMarkInput;
  }
}

/// Provider
final drugIdentificationProvider = 
    StateNotifierProvider<DrugIdentificationNotifier, DrugIdentificationData>((ref) {
  return DrugIdentificationNotifier();
});