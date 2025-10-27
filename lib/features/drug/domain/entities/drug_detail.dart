/// 약품 상세 정보 엔티티
class DrugDetail {
  // API 필드
  final int? itemSeq;  // API: item_seq
  final String itemName;  // API: item_name
  final String? itemEngName;  // API: item_eng_name
  final String entpName;  // API: entp_name (제조사)
  final String? entpEngName;  // API: entp_eng_name
  final String? itemImage;  // API: item_image
  final List<String>? additionalImages;
  
  // 기본 정보
  final String? etcOtcCode;  // API: etc_otc_code (전문/일반)
  final String? chart;  // API: chart (제형)
  final String? formCode;  // API: form_code
  final String? drugShape;  // API: drug_shape
  final String? colorClass1;  // API: color_class1
  final String? colorClass2;  // API: color_class2
  final String? printFront;  // API: print_front
  final String? printBack;  // API: print_back
  final String? markCode;  // API: mark_code
  final String? markCodeFront;  // API: mark_code_front
  final String? markCodeBack;  // API: mark_code_back
  
  // 효능/효과
  final String? efficacy;
  final String? eeDocId;  // API: ee_doc_id (효능효과 문서 ID)
  
  // 용법/용량
  final String? dosage;
  final String? udDocId;  // API: ud_doc_id (용법용량 문서 ID)
  
  // 주의사항
  final String? warning;
  final String? caution;
  final String? interaction; // 약물 상호작용
  final String? sideEffect; // 부작용
  final String? nbDocId;  // API: nb_doc_id (주의사항 문서 ID)
  
  // 보관방법
  final String? storage;
  
  // 성분
  final List<Ingredient>? ingredients;
  final String? materialName;  // API: material_name (주성분)
  
  // 보험 정보
  final String? insuranceCode;
  final bool? isInsuranceCovered;
  
  // 기타
  final String? itemPermitDate;  // API: item_permit_date (허가일자)
  final String? barCode;  // API: bar_code
  final String? cancelDate;  // API: cancel_date (취소일자)
  final String? cancelName;  // API: cancel_name (취소명)
  
  const DrugDetail({
    this.itemSeq,
    required this.itemName,
    this.itemEngName,
    required this.entpName,
    this.entpEngName,
    this.itemImage,
    this.additionalImages,
    this.etcOtcCode,
    this.chart,
    this.formCode,
    this.drugShape,
    this.colorClass1,
    this.colorClass2,
    this.printFront,
    this.printBack,
    this.markCode,
    this.markCodeFront,
    this.markCodeBack,
    this.efficacy,
    this.eeDocId,
    this.dosage,
    this.udDocId,
    this.warning,
    this.caution,
    this.interaction,
    this.sideEffect,
    this.nbDocId,
    this.storage,
    this.ingredients,
    this.materialName,
    this.insuranceCode,
    this.isInsuranceCovered,
    this.itemPermitDate,
    this.barCode,
    this.cancelDate,
    this.cancelName,
  });
  
  /// 호환성을 위한 getter (기존 UI 코드와의 호환)
  String get name => itemName;
  String get englishName => itemEngName ?? '';
  String get manufacturer => entpName;
  String? get imageUrl => itemImage;
  String? get category => etcOtcCode;
  String? get shape => drugShape ?? chart;
  String? get identificationMark => printFront;
  
  /// 허가일자를 DateTime으로 변환
  DateTime? get approvalDate {
    if (itemPermitDate == null) return null;
    try {
      // YYYYMMDD 형식 파싱
      final year = int.parse(itemPermitDate!.substring(0, 4));
      final month = int.parse(itemPermitDate!.substring(4, 6));
      final day = int.parse(itemPermitDate!.substring(6, 8));
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}

/// 성분 정보
class Ingredient {
  final String name;
  final String? amount;
  final String? unit;
  
  const Ingredient({
    required this.name,
    this.amount,
    this.unit,
  });
  
  String get displayText {
    if (amount != null && unit != null) {
      return '$name $amount$unit';
    }
    return name;
  }
}