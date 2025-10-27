import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pillsnap/features/drug/domain/repositories/drug_repository.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_result.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';
import 'package:pillsnap/core/network/api_client.dart';

/// 약품 Repository 구현체
class DrugRepositoryImpl implements DrugRepository {
  final PillSnapAPIClient _apiClient;
  
  DrugRepositoryImpl() : _apiClient = PillSnapAPIClient();
  
  @override
  Future<List<DrugResult>> analyzeImage(
    File imageFile, {
    String mode = 'cls_only', 
    File? roiFile,
    Map<String, dynamic>? identificationData,
  }) async {
    try {
      // 식별 데이터가 있으면 로그
      if (identificationData != null) {
        debugPrint('Sending identification data to API:');
        debugPrint('  Text: ${identificationData['text']}');
        debugPrint('  Colors: ${identificationData['colors']}');
        debugPrint('  Shape: ${identificationData['shape']}');
        debugPrint('  Size: ${identificationData['size']}');
      }
      
      final response = await _apiClient.analyzeImage(
        imageFile, 
        mode: mode,
        roiFile: roiFile,  // ROI 파일 전달
        identificationData: identificationData,  // 식별 데이터 전달
      );
      
      // status 필드가 있고 success가 아닌 경우만 실패 처리
      if (response.containsKey('status') && response['status'] != 'success' && response['status'] != null) {
        throw Exception('이미지 분석에 실패했습니다: ${response['status']}');
      }
      
      final List<DrugResult> results = [];
      
      // Response 구조 디버깅
      debugPrint('Response contains inference: ${response.containsKey('inference')}');
      debugPrint('Response contains results: ${response.containsKey('results')}');
      
      // inference 필드 또는 results 필드 확인
      final inference = response['inference'] as Map<String, dynamic>?;
      
      if (inference != null) {
        debugPrint('Inference keys: ${inference.keys.toList()}');
        debugPrint('Inference contains dets: ${inference.containsKey('dets')}');
        
        if (inference['dets'] != null) {
          final dets = inference['dets'] as List<dynamic>;
          debugPrint('Number of detections: ${dets.length}');
          
          for (final detection in dets) {
          final detectionMap = detection as Map<String, dynamic>;
          
          // Top-1 결과 처리
          if (detectionMap['top1'] != null) {
            try {
              final top1 = detectionMap['top1'] as Map<String, dynamic>;
              final label = top1['label'] as Map<String, dynamic>;
              
              debugPrint('Top1 data: $top1');
              debugPrint('Top1 label keys: ${label.keys.toList()}');
              debugPrint('Top1 label data: $label');
              
              // cls_only 모드에서는 필드명이 다를 수 있음
              results.add(DrugResult(
                itemSeq: label['item_seq'] as int?,
                nameKr: (label['name_kr'] ?? label['item_name_kor'] ?? '') as String,
                nameEn: (label['name_en'] ?? label['item_name_eng']) as String?,
                company: (label['company'] ?? label['manufacturer']) as String?,
                materials: label['materials'] != null 
                    ? List<String>.from(label['materials'] as List<dynamic>) 
                    : null,
                shape: label['drug_shape'] as String?,
                colorPrimary: label['drug_color_front'] as String?,
                colorSecondary: label['drug_color_back'] as String?,
                printFront: label['drug_print_front'] as String?,
                printBack: label['drug_print_back'] as String?,
                drugClass: label['drug_class'] as String?,
                otcCode: label['otc_code'] as String?,
                confidence: top1['prob'] != null 
                    ? (top1['prob'] as num).toDouble()
                    : top1['confidence'] != null
                        ? (top1['confidence'] as num).toDouble()
                        : 0.0,
                imageUrl: label['item_image'] as String?,
              ));
              
              debugPrint('Successfully added result: ${results.last.nameKr}');
            } catch (e, stackTrace) {
              debugPrint('Error parsing top1 result: $e');
              debugPrint('Stack trace: $stackTrace');
              debugPrint('Detection map: $detectionMap');
            }
          }
          
          // Top-3 결과 처리 (있는 경우)
          if (detectionMap['top3'] != null) {
            final top3List = detectionMap['top3'] as List<dynamic>;
            
            for (int i = 1; i < top3List.length && i < 3; i++) {
              final item = top3List[i] as Map<String, dynamic>;
              final label = item['label'] as Map<String, dynamic>;
              
              results.add(DrugResult(
                itemSeq: label['item_seq'] as int?,
                nameKr: (label['item_name_kor'] ?? '') as String,
                nameEn: label['item_name_eng'] as String?,
                company: label['manufacturer'] as String?,
                materials: label['materials'] != null 
                    ? List<String>.from(label['materials'] as List<dynamic>) 
                    : null,
                shape: label['drug_shape'] as String?,
                colorPrimary: label['drug_color_front'] as String?,
                colorSecondary: label['drug_color_back'] as String?,
                printFront: label['drug_print_front'] as String?,
                printBack: label['drug_print_back'] as String?,
                drugClass: label['drug_class'] as String?,
                otcCode: label['otc_code'] as String?,
                confidence: (item['confidence'] as num).toDouble(),
                imageUrl: label['item_image'] as String?,
              ));
            }
          }
        }
      }
      }
      
      return results;
    } catch (e) {
      throw Exception('이미지 분석 중 오류 발생: $e');
    }
  }
  
  @override
  Future<DrugDetail> getDrugDetail(int itemSeq) async {
    try {
      final response = await _apiClient.getDrugInfo(itemSeq);
      
      // API 응답을 DrugDetail 엔티티로 변환
      return DrugDetail(
        itemSeq: response['item_seq'] as int?,
        itemName: (response['item_name'] ?? '') as String,
        itemEngName: response['item_eng_name'] as String?,
        entpName: (response['entp_name'] ?? '') as String,
        entpEngName: response['entp_eng_name'] as String?,
        itemImage: response['item_image'] as String?,
        etcOtcCode: response['etc_otc_code'] as String?,
        chart: response['chart'] as String?,
        formCode: response['form_code'] as String?,
        drugShape: response['drug_shape'] as String?,
        colorClass1: response['color_class1'] as String?,
        colorClass2: response['color_class2'] as String?,
        printFront: response['print_front'] as String?,
        printBack: response['print_back'] as String?,
        markCode: response['mark_code'] as String?,
        markCodeFront: response['mark_code_front'] as String?,
        markCodeBack: response['mark_code_back'] as String?,
        efficacy: response['ee_doc_data']?['efficacy'] as String?,
        eeDocId: response['ee_doc_id'] as String?,
        dosage: response['ud_doc_data']?['dosage'] as String?,
        udDocId: response['ud_doc_id'] as String?,
        warning: response['nb_doc_data']?['warning'] as String?,
        caution: response['nb_doc_data']?['caution'] as String?,
        interaction: response['nb_doc_data']?['interaction'] as String?,
        sideEffect: response['nb_doc_data']?['side_effect'] as String?,
        nbDocId: response['nb_doc_id'] as String?,
        storage: response['storage'] as String?,
        materialName: response['material_name'] as String?,
        insuranceCode: response['insurance_code'] as String?,
        isInsuranceCovered: response['is_insurance_covered'] as bool?,
        itemPermitDate: response['item_permit_date'] as String?,
        barCode: response['bar_code'] as String?,
        cancelDate: response['cancel_date'] as String?,
        cancelName: response['cancel_name'] as String?,
        ingredients: _parseIngredients(response['ingredients']),
      );
    } catch (e) {
      throw Exception('약품 상세 정보 조회 중 오류 발생: $e');
    }
  }
  
  /// 성분 정보 파싱
  List<Ingredient>? _parseIngredients(dynamic ingredientsData) {
    if (ingredientsData == null) return null;
    
    final List<Ingredient> ingredients = [];
    
    if (ingredientsData is List) {
      for (final item in ingredientsData) {
        final itemMap = item as Map<String, dynamic>;
        ingredients.add(Ingredient(
          name: (itemMap['name'] ?? '') as String,
          amount: itemMap['amount']?.toString(),
          unit: itemMap['unit'] as String?,
        ));
      }
    } else if (ingredientsData is String) {
      // 문자열로 된 성분 정보 처리
      final items = ingredientsData.split(',');
      for (final item in items) {
        ingredients.add(Ingredient(
          name: item.trim(),
        ));
      }
    }
    
    return ingredients.isNotEmpty ? ingredients : null;
  }
  
  @override
  Future<List<DrugResult>> searchDrugs(String query) async {
    // TODO: 검색 API 구현 (API 엔드포인트 추가 필요)
    throw UnimplementedError('검색 기능은 아직 구현되지 않았습니다');
  }
}