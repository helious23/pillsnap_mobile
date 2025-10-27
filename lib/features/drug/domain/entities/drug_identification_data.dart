/// 약품 식별 정보 데이터 모델
class DrugIdentificationData {
  // 0단계: 제형 (정제류/캡슐류)
  final String? form;
  
  // 1단계: 텍스트/마크 (가장 중요 - 40% 가중치)
  final String? text; // 기존 호환성 유지
  final String? textPosition; // front, back, both
  final String? textFront; // 앞면 문자
  final String? textBack; // 뒷면 문자
  final String? mark; // 마크 코드 (예: r0004)
  
  // 2단계: 색상 (25% 가중치)
  final List<String> colors;
  
  // 3단계: 모양 (20% 가중치)
  final List<String> shapes;
  
  // 4단계: 크기 (10% 가중치)
  final String? size;
  
  // 5단계: 특수 특징 (5% 가중치)
  final bool hasScoreLine; // 기존 호환성 유지
  final bool hasCoating;
  final String? specialFeatures;
  final String? lineFront; // 앞면 분할선 (none, -, +, other)
  final String? lineBack; // 뒷면 분할선 (none, -, +, other)
  
  // 6단계: 추가 정보 (참고용)
  final String? drugType; // tablet, capsule, etc
  final String? suspectedName;
  final String? notes;
  
  DrugIdentificationData({
    this.form,
    this.text,
    this.textPosition,
    this.textFront,
    this.textBack,
    this.mark,
    this.colors = const [],
    this.shapes = const [],
    this.size,
    this.hasScoreLine = false,
    this.hasCoating = false,
    this.specialFeatures,
    this.lineFront,
    this.lineBack,
    this.drugType,
    this.suspectedName,
    this.notes,
  });
  
  /// 복사 생성자
  DrugIdentificationData copyWith({
    String? form,
    String? text,
    String? textPosition,
    String? textFront,
    String? textBack,
    String? mark,
    List<String>? colors,
    List<String>? shapes,
    String? size,
    bool? hasScoreLine,
    bool? hasCoating,
    String? specialFeatures,
    String? lineFront,
    String? lineBack,
    String? drugType,
    String? suspectedName,
    String? notes,
  }) {
    return DrugIdentificationData(
      form: form ?? this.form,
      text: text ?? this.text,
      textPosition: textPosition ?? this.textPosition,
      textFront: textFront ?? this.textFront,
      textBack: textBack ?? this.textBack,
      mark: mark ?? this.mark,
      colors: colors ?? this.colors,
      shapes: shapes ?? this.shapes,
      size: size ?? this.size,
      hasScoreLine: hasScoreLine ?? this.hasScoreLine,
      hasCoating: hasCoating ?? this.hasCoating,
      specialFeatures: specialFeatures ?? this.specialFeatures,
      lineFront: lineFront ?? this.lineFront,
      lineBack: lineBack ?? this.lineBack,
      drugType: drugType ?? this.drugType,
      suspectedName: suspectedName ?? this.suspectedName,
      notes: notes ?? this.notes,
    );
  }
  
  /// 입력 완성도 계산 (0-100)
  double get completionScore {
    double score = 0;
    
    // 텍스트/마크 (40점)
    if (text != null && text!.isNotEmpty) {
      score += 40;
    }
    
    // 색상 (25점)
    if (colors.isNotEmpty) {
      score += colors.length >= 2 ? 25 : 15;
    }
    
    // 모양 (20점)
    if (shapes.isNotEmpty) {
      score += 20;
    }
    
    // 크기 (10점)
    if (size != null && size != 'unknown') {
      score += 10;
    }
    
    // 특수 특징 (5점)
    if (hasScoreLine || hasCoating) {
      score += 5;
    }
    
    return score;
  }
  
  /// 예상 정확도 (50-95%)
  int get estimatedAccuracy {
    return (completionScore * 1.1).clamp(50, 95).toInt();
  }
  
  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'form': form,
      'text': text,
      'textPosition': textPosition,
      'textFront': textFront,
      'textBack': textBack,
      'mark': mark,
      'colors': colors,
      'shapes': shapes,
      'size': size,
      'hasScoreLine': hasScoreLine,
      'hasCoating': hasCoating,
      'specialFeatures': specialFeatures,
      'lineFront': lineFront,
      'lineBack': lineBack,
      'drugType': drugType,
      'suspectedName': suspectedName,
      'notes': notes,
    };
  }
}