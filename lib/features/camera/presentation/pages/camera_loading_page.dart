import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/core/widgets/loading/pill_loading_indicator.dart';
import 'package:pillsnap/features/drug/data/providers/drug_providers.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_result_controller.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';

/// 카메라 촬영 후 로딩 화면
/// API로 이미지를 전송하고 분석 결과를 받아옴
class CameraLoadingPage extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? roiPath;  // ROI 이미지 경로 추가
  final bool isMultiMode;
  
  const CameraLoadingPage({
    super.key,
    this.imagePath,
    this.roiPath,
    this.isMultiMode = false,
  });

  @override
  ConsumerState<CameraLoadingPage> createState() => _CameraLoadingPageState();
}

class _CameraLoadingPageState extends ConsumerState<CameraLoadingPage> {
  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }
  
  Future<void> _analyzeImage() async {
    // 식별 데이터 가져오기
    final identificationData = ref.read(drugIdentificationProvider);
    
    // 이미지 경로가 없으면 모의 데이터 로드
    if (widget.imagePath == null) {
      debugPrint('No image path provided, loading mock data');
      await Future<void>.delayed(const Duration(seconds: 2));
      await ref.read(drugResultProvider.notifier).loadMockData();
      _navigateToResult();
      return;
    }
    
    try {
      debugPrint('Starting image analysis for: ${widget.imagePath}');
      
      // 이미지 파일 생성
      final imageFile = File(widget.imagePath!);
      
      if (!imageFile.existsSync()) {
        throw Exception('이미지 파일을 찾을 수 없습니다');
      }
      
      // ROI 파일 생성 (있을 경우)
      File? roiFile;
      if (widget.roiPath != null) {
        roiFile = File(widget.roiPath!);
        if (!roiFile.existsSync()) {
          debugPrint('ROI file not found, continuing without ROI');
          roiFile = null;
        } else {
          debugPrint('ROI file found: ${widget.roiPath}');
        }
      }
      
      // API로 이미지 분석 요청 (단일 모드는 cls_only, 다중 모드는 detect_cls)
      final mode = widget.isMultiMode ? 'detect_cls' : 'cls_only';
      debugPrint('Analysis mode: $mode');
      debugPrint('Using ROI: ${roiFile != null}');
      
      // 식별 데이터 로그
      if (identificationData.completionScore > 0) {
        debugPrint('Using identification data:');
        debugPrint('  - Text: ${identificationData.text}');
        debugPrint('  - Colors: ${identificationData.colors}');
        debugPrint('  - Shapes: ${identificationData.shapes.join(", ")}');
        debugPrint('  - Size: ${identificationData.size}');
        debugPrint('  - Estimated accuracy: ${identificationData.estimatedAccuracy}%');
      }
      
      // repository 직접 호출 (mode와 roiFile 파라미터 전달)
      final repository = ref.read(drugRepositoryProvider);
      
      // 식별 데이터를 Map으로 변환하여 API에 전달
      final identificationMap = identificationData.completionScore > 0 
          ? identificationData.toMap() 
          : null;
      
      final results = await repository.analyzeImage(
        imageFile, 
        mode: mode,
        roiFile: roiFile,  // ROI 파일 전달
        identificationData: identificationMap,  // 식별 데이터 전달
      );
      
      debugPrint('Analysis complete. Results count: ${results.length}');
      
      // 결과를 상태에 저장
      ref.read(drugResultProvider.notifier).setResults(results);
      
      // 결과 화면으로 이동
      _navigateToResult();
    } catch (e) {
      debugPrint('Error during image analysis: $e');
      
      // 에러 발생 시 에러 메시지 설정
      ref.read(drugResultProvider.notifier).setError(
        '이미지 분석 중 오류가 발생했습니다.\n$e'
      );
      
      // 에러가 있어도 결과 화면으로 이동
      _navigateToResult();
    }
  }
  
  void _navigateToResult() {
    if (!mounted) return;
    
    // 결과 화면으로 이동 (replace로 스택 교체)
    context.pushReplacement('/camera/result');
  }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: PillLoadingIndicator(
          message: '분석 중...',
          subMessage: '의약품을 식별하고 있습니다',
        ),
      ),
    );
  }
}