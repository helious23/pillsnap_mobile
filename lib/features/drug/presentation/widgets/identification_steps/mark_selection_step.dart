import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_identification_controller.dart';
import 'package:pillsnap/core/services/supabase_service.dart';
import 'package:pillsnap/features/drug/presentation/widgets/common/base_identification_step.dart';

/// 마크 데이터 모델
class MarkData {
  final String code;
  final String? imageUrl;
  
  MarkData({
    required this.code,
    this.imageUrl,
  });
}

/// 마크 이미지 로딩 Provider (중복 제거)
final marksProvider = FutureProvider<List<MarkData>>((ref) async {
  final supabase = SupabaseService.instance;
  
  try {
    debugPrint('=== Starting to load marks from Supabase ===');
    
    // 분할선 컬럼 확인을 위한 쿼리 (한 번만 실행)
    final schemaCheck = await supabase.client
      .from('drugs_master')
      .select()
      .limit(1);
    
    debugPrint('Schema check result: ${schemaCheck.runtimeType}');
    
    if ((schemaCheck as List).isNotEmpty) {
      final columns = schemaCheck[0].keys.toList();
      final lineColumns = columns.where((col) => 
        col.toLowerCase().contains('line') || 
        col.toLowerCase().contains('division') ||
        col.toLowerCase().contains('분할'));
      debugPrint('=== Division line columns: $lineColumns');
      debugPrint('All columns: $columns');
    } else {
      debugPrint('No data in drugs_master table');
    }
    
    // 전체 마크 데이터 로드 (제한 없이)
    final result = await supabase.client
      .from('drugs_master')
      .select('mark, mark_image_urls')
      .not('mark', 'is', null)
      .not('mark_image_urls', 'is', null);
    
    debugPrint('Marks query result count: ${(result as List).length}');
    
    // 중복 제거를 위한 Map 사용
    final uniqueMarks = <String, MarkData>{};
    
    for (final item in result) {
      final markCode = item['mark'] as String?;
      final imageUrls = item['mark_image_urls'] as List?;
      
      if (markCode != null) {
        // 중복된 마크 코드는 첫 번째 것만 사용
        if (!uniqueMarks.containsKey(markCode)) {
          uniqueMarks[markCode] = MarkData(
            code: markCode,
            imageUrl: imageUrls?.isNotEmpty == true ? imageUrls![0] as String : null,
          );
        }
      }
    }
    
    // 마크 코드 기준 정렬
    final sortedMarks = uniqueMarks.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    
    debugPrint('=== Loaded ${sortedMarks.length} unique marks ===');
    if (sortedMarks.isNotEmpty) {
      debugPrint('First few marks: ${sortedMarks.take(5).map((m) => m.code).join(', ')}');
    }
    return sortedMarks;
  } catch (e, stackTrace) {
    debugPrint('=== Error loading marks ===');
    debugPrint('Error: $e');
    debugPrint('Stack trace: $stackTrace');
    return [];
  }
});

/// 마크 선택 단계 (Step 5)
class MarkSelectionStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const MarkSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<MarkSelectionStep> createState() => _MarkSelectionStepState();
}

class _MarkSelectionStepState extends ConsumerState<MarkSelectionStep> {
  String? selectedMark;
  bool hasNoMark = false;
  bool cantSeeMark = false;
  int displayedItems = 20; // 초기 표시 개수
  final ScrollController _scrollController = ScrollController();
  static const int itemsPerLoad = 20; // 한 번에 로드할 개수
  
  @override
  void initState() {
    super.initState();
    final data = ref.read(drugIdentificationProvider);
    selectedMark = data.mark;
    
    // 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      // 스크롤이 80% 도달하면 더 로드
      _loadMore();
    }
  }
  
  void _loadMore() {
    final marksAsync = ref.read(marksProvider);
    marksAsync.whenData((marks) {
      if (displayedItems < marks.length) {
        setState(() {
          displayedItems = (displayedItems + itemsPerLoad).clamp(0, marks.length);
        });
      }
    });
  }
  
  void _handleNext() {
    if (hasNoMark || cantSeeMark) {
      ref.read(drugIdentificationProvider.notifier).updateMark(null);
    } else {
      ref.read(drugIdentificationProvider.notifier).updateMark(selectedMark);
    }
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    final marksAsync = ref.watch(marksProvider);
    
    return BaseIdentificationStep(
      title: '약에 마크나 로고가 있나요?',
      subtitle: '제조사 로고나 특수 기호를 선택하세요',
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 옵션 버튼들 (마크 그리드보다 위에 배치)
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    label: '마크가 없어요',
                    isSelected: hasNoMark,
                    onTap: () {
                      setState(() {
                        hasNoMark = !hasNoMark;
                        if (hasNoMark) {
                          cantSeeMark = false;
                          selectedMark = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildOptionButton(
                    label: '잘 안보여요',
                    isSelected: cantSeeMark,
                    onTap: () {
                      setState(() {
                        cantSeeMark = !cantSeeMark;
                        if (cantSeeMark) {
                          hasNoMark = false;
                          selectedMark = null;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // 마크 그리드 (항상 표시)
            marksAsync.when(
              data: (marks) => _buildMarkGrid(marks),
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildErrorState(),
            ),
          ],
        ),
      ),
      onNext: _handleNext,
      onReset: () {
        setState(() {
          selectedMark = null;
          hasNoMark = false;
          cantSeeMark = false;
        });
      },
      isResetEnabled: selectedMark != null || hasNoMark || cantSeeMark,
    );
  }
  
  Widget _buildMarkGrid(List<MarkData> marks) {
    if (marks.isEmpty) {
      return _buildEmptyState();
    }
    
    // displayedItems 만큼만 표시
    final displayMarks = marks.take(displayedItems).toList();
    
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.0,
          children: displayMarks.map((mark) {
            return _buildMarkCard(mark);
          }).toList(),
        ),
        // 더 보기 버튼 또는 로딩 인디케이터
        if (displayedItems < marks.length) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: () {
              setState(() {
                displayedItems = (displayedItems + itemsPerLoad).clamp(0, marks.length);
              });
            },
            icon: const Icon(Icons.expand_more),
            label: Text('더 보기 (${marks.length - displayedItems}개 남음)'),
          ),
        ] else if (marks.length > 20) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            '모든 마크 로드 완료 (${marks.length}개)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildMarkCard(MarkData mark) {
    final isSelected = selectedMark == mark.code;
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            if (selectedMark == mark.code) {
              selectedMark = null;
            } else {
              selectedMark = mark.code;
              hasNoMark = false;
              cantSeeMark = false;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: mark.imageUrl != null
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Image.network(
                    mark.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        mark.code,
                        style: AppTextStyles.caption,
                      );
                    },
                  ),
                )
              : Text(
                  mark.code,
                  style: AppTextStyles.caption,
                ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '마크 정보를 불러올 수 없습니다',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '마크를 불러오는 중 오류가 발생했습니다',
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () {
                // refresh 결과를 무시해도 괜찮음을 명시
                ref.invalidate(marksProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}