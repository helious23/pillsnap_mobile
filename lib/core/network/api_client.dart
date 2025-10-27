import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pillsnap/core/utils/image_processor.dart';

/// PillSnap API 클라이언트
class PillSnapAPIClient {
  static final PillSnapAPIClient _instance = PillSnapAPIClient._internal();
  factory PillSnapAPIClient() => _instance;
  PillSnapAPIClient._internal();

  // dart-define으로 전달된 환경변수 사용 (기본값 제공)
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.pillsnap.co.kr',
  );
  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '', // .env 파일 또는 --dart-define으로 주입 필요
  );
  
  /// API 클라이언트 초기화
  Future<void> initialize() async {
    if (kDebugMode) {
      print('API Client Configuration:');
      print('  Base URL: $_baseUrl');
      print('  API Key: ${_apiKey.isNotEmpty ? '${_apiKey.substring(0, 8)}...' : 'Not set'}');
    }
  }
  
  /// 기본 헤더 생성
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Accept': 'application/json',
    };
    
    if (includeAuth && _apiKey.isNotEmpty) {
      headers['X-Api-Key'] = _apiKey;
    }
    
    return headers;
  }
  
  /// 이미지 분석 API (ROI 지원 추가)
  Future<Map<String, dynamic>> analyzeImage(
    File imageFile, {
    String mode = 'cls_only',  // 기본값을 cls_only로 변경 (단일 약품)
    File? roiFile,  // ROI 이미지 (단일 모드에서 선택적 사용)
    Map<String, dynamic>? identificationData,  // 사용자 입력 식별 데이터
  }) async {
    try {
      // 파일 존재 확인
      if (!imageFile.existsSync()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }
      
      // 이미지 전처리 (IMAGE_OPTIMIZATION_GUIDE.md 기준)
      debugPrint('이미지 전처리 시작...');
      File processedFile;
      
      if (mode == 'cls_only') {
        // 단일 약품: 384x384로 전처리
        processedFile = await ImageProcessor.preprocessForClassification(imageFile);
      } else {
        // 다중 약품: 1024x1024로 전처리
        processedFile = await ImageProcessor.preprocessForDetection(imageFile);
      }
      
      // 전처리 후 검증
      await ImageProcessor.validateImage(processedFile);
      
      // 파일 크기 확인
      final fileSize = await processedFile.length();
      debugPrint('Processed file path: ${processedFile.path}');
      debugPrint('Processed file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // 10MB 제한 체크
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('이미지 파일이 너무 큽니다 (최대 10MB): ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      }
      
      final uri = Uri.parse('$_baseUrl/v1/analyze');
      debugPrint('API Request URL: $uri');
      debugPrint('API Key present: ${_apiKey.isNotEmpty}');
      
      final request = http.MultipartRequest('POST', uri);
      
      // 헤더 추가
      final headers = _getHeaders();
      debugPrint('Request headers: $headers');
      request.headers.addAll(headers);
      
      // 파일 추가 (전처리된 파일 사용)
      final stream = http.ByteStream(processedFile.openRead());
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        fileSize,
        filename: 'processed_image.jpg',  // 일관된 파일명
      );
      request.files.add(multipartFile);
      
      // ROI 파일 추가 (있을 경우)
      if (roiFile != null && roiFile.existsSync()) {
        final roiFileSize = await roiFile.length();
        debugPrint('[API] Adding ROI file: ${roiFile.path}');
        debugPrint('[API] ROI size: ${(roiFileSize / 1024).toStringAsFixed(1)} KB');
        
        final roiStream = http.ByteStream(roiFile.openRead());
        final roiMultipart = http.MultipartFile(
          'roi',  // 서버에서 roi 필드로 받음
          roiStream,
          roiFileSize,
          filename: 'roi_512.jpg',
        );
        request.files.add(roiMultipart);
        debugPrint('[API] ROI file added to request');
      } else {
        debugPrint('[API] No ROI file provided or file does not exist');
      }
      
      // mode 추가
      request.fields['mode'] = mode;
      debugPrint('Request mode: $mode');
      
      // 식별 데이터 추가 (JSON 문자열로 전송)
      if (identificationData != null) {
        request.fields['identification_data'] = json.encode(identificationData);
        debugPrint('[API] Sending identification data:');
        debugPrint('  - Text: ${identificationData['text']}');
        debugPrint('  - Colors: ${identificationData['colors']}');
        debugPrint('  - Shape: ${identificationData['shape']}');
        debugPrint('  - Size: ${identificationData['size']}');
        debugPrint('  - Special features: hasScoreLine=${identificationData['hasScoreLine']}, hasCoating=${identificationData['hasCoating']}');
      }
      
      // 요청 전송
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Headers: ${response.headers}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        debugPrint('API Response Body (first 500 chars): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
        
        final data = json.decode(responseBody) as Map<String, dynamic>;
        debugPrint('API Response Status field: ${data['status']}');
        debugPrint('API Response keys: ${data.keys.toList()}');
        
        // status 필드가 없어도 inference 필드가 있으면 성공으로 처리
        if (data.containsKey('inference') || data.containsKey('results')) {
          return data;
        }
        
        return data;
      } else {
        debugPrint('API Error Response Body: ${response.body}');
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? '이미지 분석에 실패했습니다 (Status: ${response.statusCode})');
        } catch (jsonError) {
          throw Exception('이미지 분석 실패 (Status: ${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Image analysis error: $e');
      debugPrint('Request URL: $_baseUrl/v1/analyze');
      debugPrint('API Key: ${_apiKey.isNotEmpty ? '${_apiKey.substring(0, 8)}...' : 'Not set'}');
      rethrow;
    }
  }
  
  /// Base64 이미지 분석 (대체 방법)
  Future<Map<String, dynamic>> analyzeImageBase64(
    String base64Image, {
    String mode = 'detect_cls',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/analyze'),
        headers: {
          ..._getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'image': base64Image,
          'mode': mode,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '이미지 분석에 실패했습니다');
      }
    } catch (e) {
      debugPrint('Image analysis error: $e');
      throw Exception('이미지 분석 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 개별 약품 정보 조회
  Future<Map<String, dynamic>> getDrugInfo(int itemSeq) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/drugs/item/$itemSeq'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '약품 정보를 가져올 수 없습니다');
      }
    } catch (e) {
      debugPrint('Drug info error: $e');
      throw Exception('약품 정보 조회 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 다중 약품 정보 일괄 조회
  Future<Map<String, dynamic>> getDrugsBatch(List<int> itemSeqs) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/drugs/batch'),
        headers: {
          ..._getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'item_seqs': itemSeqs,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '약품 정보를 가져올 수 없습니다');
      }
    } catch (e) {
      debugPrint('Batch drug info error: $e');
      throw Exception('약품 정보 조회 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 헬스체크 (인증 불필요)
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _getHeaders(includeAuth: false),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('서버 상태를 확인할 수 없습니다');
      }
    } catch (e) {
      debugPrint('Health check error: $e');
      throw Exception('서버 연결 확인 중 오류가 발생했습니다: $e');
    }
  }
}