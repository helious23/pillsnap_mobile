import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';
import 'package:pillsnap/features/drug/domain/repositories/drug_repository.dart';
import 'package:pillsnap/features/drug/data/providers/drug_providers.dart';

/// 약품 상세 정보 상태
class DrugDetailState {
  final DrugDetail? drug;
  final bool isLoading;
  final String? error;
  final bool isFavorite;

  const DrugDetailState({
    this.drug,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
  });

  DrugDetailState copyWith({
    DrugDetail? drug,
    bool? isLoading,
    String? error,
    bool? isFavorite,
  }) {
    return DrugDetailState(
      drug: drug ?? this.drug,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 약품 상세 정보 컨트롤러
class DrugDetailNotifier extends StateNotifier<DrugDetailState> {
  final DrugRepository _repository;
  
  DrugDetailNotifier(this._repository) : super(const DrugDetailState());

  /// 약품 정보 로드
  Future<void> loadDrugDetail(String drugId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // drugId를 int로 변환
      final itemSeq = int.tryParse(drugId);
      if (itemSeq == null) {
        throw Exception('잘못된 약품 ID입니다: $drugId');
      }
      
      debugPrint('Loading drug detail for itemSeq: $itemSeq');
      
      // API로 약품 상세 정보 조회
      final drug = await _repository.getDrugDetail(itemSeq);
      
      debugPrint('Drug detail loaded successfully: ${drug.itemName}');
      
      state = state.copyWith(
        drug: drug,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading drug detail: $e');
      
      // 에러 발생 시 모의 데이터로 폴백 (개발용)
      if (kDebugMode) {
        _loadMockData(drugId);
      } else {
        state = state.copyWith(
          error: '약품 정보를 불러오는데 실패했습니다: $e',
          isLoading: false,
        );
      }
    }
  }
  
  /// 모의 데이터 로드 (개발용 폴백)
  void _loadMockData(String drugId) {
    final mockDrug = DrugDetail(
      itemSeq: int.tryParse(drugId) ?? 198801518,
      itemName: '타이레놀정500밀리그램(아세트아미노펜)',
      itemEngName: 'Tylenol Tab. 500mg',
      entpName: '한국얀센(주)',
      etcOtcCode: '일반의약품',
      chart: '정제',
      drugShape: '원형',
      colorClass1: '하양',
      printFront: 'TYLENOL',
      printBack: '500',
      efficacy: '해열 및 진통',
      dosage: '1회 1~2정, 1일 3~4회',
      warning: '과량 복용시 간손상 위험',
      caution: '간장질환 환자 주의',
      storage: '실온보관(1~30℃)',
      ingredients: [
        const Ingredient(
          name: '아세트아미노펜',
          amount: '500',
          unit: 'mg',
        ),
      ],
    );
    
    state = state.copyWith(
      drug: mockDrug,
      isLoading: false,
    );
  }

  /// 즐겨찾기 토글
  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  /// 상태 초기화
  void clear() {
    state = const DrugDetailState();
  }
}

/// 약품 상세 정보 프로바이더
final drugDetailProvider = StateNotifierProvider.family<
    DrugDetailNotifier, DrugDetailState, String>((ref, drugId) {
  // repository 주입
  final repository = ref.watch(drugRepositoryProvider);
  final notifier = DrugDetailNotifier(repository);
  notifier.loadDrugDetail(drugId);
  return notifier;
});