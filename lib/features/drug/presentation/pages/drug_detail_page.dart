import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';
import 'package:pillsnap/features/drug/presentation/controllers/drug_detail_controller.dart';
import 'package:pillsnap/features/drug/domain/entities/drug_detail.dart';
import 'package:pillsnap/features/drug/presentation/widgets/drug_image_modal.dart';

/// 약품 상세 정보 페이지
class DrugDetailPage extends ConsumerStatefulWidget {
  final String drugId;
  
  const DrugDetailPage({
    super.key,
    required this.drugId,
  });

  @override
  ConsumerState<DrugDetailPage> createState() => _DrugDetailPageState();
}

class _DrugDetailPageState extends ConsumerState<DrugDetailPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drugDetailProvider(widget.drugId));
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '의약품 정보',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(state.error!)
              : state.drug != null
                  ? _buildContent(state.drug!)
                  : const SizedBox(),
    );
  }
  
  Widget _buildContent(DrugDetail drug) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 약품 이미지 (전체 너비, 탭 가능)
          GestureDetector(
            onTap: () {
              DrugImageModal.show(context, _buildPillImage());
            },
            child: Hero(
              tag: 'drug_image',
              child: Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _buildPillImage(),
                    ),
                    // 확대 아이콘 힌트
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 약품명
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              drug.itemName,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // 정보 태그들 (제조사, 제형, 정확도만)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Wrap(
              spacing: AppSpacing.md,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoChip(Icons.business_outlined, drug.entpName),
                if (drug.chart != null)
                  _buildInfoChip(Icons.medication_outlined, drug.chart!),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '정확도 87%',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          
          // 탭바
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '성분'),
                Tab(text: '효능·효과'),
                Tab(text: '용법·용량'),
                Tab(text: '주의사항'),
              ],
            ),
          ),
          
          // 탭 콘텐츠 (고정 높이)
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientTab(drug),
                _buildEfficacyTab(drug),
                _buildDosageTab(drug),
                _buildWarningTab(drug),
              ],
            ),
          ),
          
          // 하단 버튼들
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // pop을 사용하여 카메라로 돌아가기
                        if (context.canPop()) {
                          context.pop();
                          context.pop(); // 두 번 pop하여 카메라로
                        } else {
                          context.go('/camera');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        side: const BorderSide(
                          color: AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '다시 촬영하기',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('홈으로 가기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPillImage() {
    return Container(
      width: 140,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFF6EC1E4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽 흰색 부분
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
          ),
          // 오른쪽 파란색 부분
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6EC1E4),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  // 성분 탭
  Widget _buildIngredientTab(DrugDetail drug) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          '주성분',
          [
            _buildInfoItem('Acetaminophen 500mg'),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          '첨가제',
          [
            _buildInfoItem('옥수수전분, 포비돈, 전분글리콜산나트륨, 스테아르산마그네슘, 셀룰로오스미정질'),
          ],
        ),
      ],
    );
  }
  
  // 효능·효과 탭
  Widget _buildEfficacyTab(DrugDetail drug) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          '효능·효과',
          [
            _buildInfoItem(drug.efficacy ?? '해열 및 감기에 의한 동통과 두통, 신경통, 근육통, 월경통, 염좌통(삠통증), 치통, 관절통, 류마티양 동통'),
          ],
        ),
      ],
    );
  }
  
  // 용법·용량 탭
  Widget _buildDosageTab(DrugDetail drug) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          '성인',
          [
            _buildInfoItem('1회 1~2정'),
            _buildInfoItem('1일 3~4회 (4~6시간마다)'),
            _buildInfoItem('1일 최대 8정'),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          '소아',
          [
            _buildInfoItem('11세 이상: 성인과 동일'),
            _buildInfoItem('6~11세: 1회 1/2~1정'),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '최대 용량을 초과하지 마세요',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 주의사항 탭
  Widget _buildWarningTab(DrugDetail drug) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildWarningCard(
          '경고',
          drug.warning ?? '매일 세잔 이상 정기적 음주자는 의사와 상담\n아세트아미노펜 과량 복용시 간손상 위험',
          Colors.red,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildWarningCard(
          '복용 전 주의사항',
          drug.caution ?? '• 간장질환 환자는 의사와 상담\n• 알레르기 체질은 주의\n• 임부 및 수유부는 의사와 상담',
          Colors.orange,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildWarningCard(
          '이상반응',
          drug.sideEffect ?? '• 발진, 가려움 등 알레르기 증상\n• 구역, 구토\n• 식욕부진',
          Colors.amber,
        ),
      ],
    );
  }
  
  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningCard(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.body2.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '오류가 발생했습니다',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(drugDetailProvider(widget.drugId));
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}