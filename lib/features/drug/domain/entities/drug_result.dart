/// 약품 검색 결과 엔티티
class DrugResult {
  final int? itemSeq;  // API: item_seq
  final String nameKr;  // API: name_kr
  final String? nameEn;  // API: name_en
  final String? company;  // API: company
  final List<String>? materials;  // API: materials
  final String? shape;  // API: shape
  final String? colorPrimary;  // API: color_primary
  final String? colorSecondary;  // API: color_secondary
  final String? printFront;  // API: print_front
  final String? printBack;  // API: print_back
  final String? drugClass;  // API: drug_class
  final String? otcCode;  // API: otc_code
  final double confidence;  // API: conf (0.0 ~ 1.0)
  final String? imageUrl;

  const DrugResult({
    this.itemSeq,
    required this.nameKr,
    this.nameEn,
    this.company,
    this.materials,
    this.shape,
    this.colorPrimary,
    this.colorSecondary,
    this.printFront,
    this.printBack,
    this.drugClass,
    this.otcCode,
    required this.confidence,
    this.imageUrl,
  });

  /// 정확도를 퍼센트로 반환
  int get confidencePercent => (confidence * 100).round();
  
  /// 높은 정확도인지 확인 (80% 이상)
  bool get isHighConfidence => confidence >= 0.8;
  
  /// 제조사명 (호환성을 위해 추가)
  String get manufacturer => company ?? '';
  
  /// 약품명 (호환성을 위해 추가)
  String get name => nameKr;
}