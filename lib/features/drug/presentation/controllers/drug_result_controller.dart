import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_result.dart';

/// 약품 검색 결과 상태
class DrugResultState {
  final List<DrugResult> results;
  final bool isLoading;
  final String? error;

  const DrugResultState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  DrugResultState copyWith({
    List<DrugResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return DrugResultState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 약품 검색 결과 컨트롤러
class DrugResultNotifier extends StateNotifier<DrugResultState> {
  DrugResultNotifier() : super(const DrugResultState());

  /// 모의 데이터 로드
  Future<void> loadMockData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // 모의 지연
    await Future<void>.delayed(const Duration(seconds: 1));
    
    // 모의 데이터 (API 스펙에 맞게 수정)
    final mockResults = [
      const DrugResult(
        itemSeq: 198801518,
        nameKr: '타이레놀정500밀리그램(아세트아미노펜)',
        nameEn: 'Tylenol Tab. 500mg',
        company: '한국얀센(주)',
        materials: ['아세트아미노펜'],
        shape: '원형',
        colorPrimary: '하양',
        printFront: 'TYLENOL',
        printBack: '500',
        drugClass: '해열진통소염제',
        otcCode: '일반의약품',
        confidence: 0.92,
      ),
      const DrugResult(
        itemSeq: 195700020,
        nameKr: '게보린정',
        company: '삼진제약(주)',
        materials: ['아세트아미노펜', '카페인무수물', '에테살리실아미드'],
        shape: '원형',
        colorPrimary: '하양',
        confidence: 0.78,
      ),
      const DrugResult(
        itemSeq: 200003092,
        nameKr: '부루펜정400밀리그램(이부프로펜)',
        company: '한미약품(주)',
        materials: ['이부프로펜'],
        shape: '원형',
        colorPrimary: '분홍',
        confidence: 0.65,
      ),
      const DrugResult(
        itemSeq: 198200134,
        nameKr: '아스피린정100밀리그램',
        company: '바이엘코리아(주)',
        materials: ['아스피린'],
        shape: '원형',
        colorPrimary: '하양',
        confidence: 0.52,
      ),
      const DrugResult(
        itemSeq: 195900006,
        nameKr: '판피린정',
        company: '동아에스티(주)',
        materials: ['아세트아미노펜'],
        shape: '원형',
        colorPrimary: '하양',
        confidence: 0.41,
      ),
    ];
    
    state = state.copyWith(
      results: mockResults,
      isLoading: false,
    );
  }

  /// API 결과 설정
  void setResults(List<DrugResult> results) {
    state = state.copyWith(
      results: results,
      isLoading: false,
      error: null,
    );
  }
  
  /// 에러 설정
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }
  
  /// 결과 초기화
  void clearResults() {
    state = const DrugResultState();
  }
}

/// 약품 검색 결과 프로바이더
final drugResultProvider = StateNotifierProvider<DrugResultNotifier, DrugResultState>((ref) {
  return DrugResultNotifier();
});