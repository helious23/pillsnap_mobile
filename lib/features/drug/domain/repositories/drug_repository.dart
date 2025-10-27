import 'dart:io';
import 'package:pillsnap/features/drug/domain/entities/drug_result.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';

/// 약품 Repository 인터페이스
abstract class DrugRepository {
  /// 이미지 분석을 통한 약품 검색 (ROI 지원 추가)
  Future<List<DrugResult>> analyzeImage(
    File imageFile, {
    String mode, 
    File? roiFile,
    Map<String, dynamic>? identificationData,
  });
  
  /// 약품 상세 정보 조회
  Future<DrugDetail> getDrugDetail(int itemSeq);
  
  /// 약품 검색
  Future<List<DrugResult>> searchDrugs(String query);
}