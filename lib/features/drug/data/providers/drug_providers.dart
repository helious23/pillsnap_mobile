import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/features/drug/domain/repositories/drug_repository.dart';
import 'package:pillsnap/features/drug/data/repositories/drug_repository_impl.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_result.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';

/// Drug Repository Provider
final drugRepositoryProvider = Provider<DrugRepository>((ref) {
  return DrugRepositoryImpl();
});

/// 이미지 분석 Provider
final analyzeImageProvider = FutureProvider.family<List<DrugResult>, File>(
  (ref, imageFile) async {
    final repository = ref.watch(drugRepositoryProvider);
    return await repository.analyzeImage(imageFile);
  },
);

/// 약품 상세 정보 Provider
final drugDetailApiProvider = FutureProvider.family<DrugDetail, int>(
  (ref, itemSeq) async {
    final repository = ref.watch(drugRepositoryProvider);
    return await repository.getDrugDetail(itemSeq);
  },
);