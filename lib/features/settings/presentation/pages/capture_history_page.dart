import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme.dart';

class CaptureHistoryPage extends ConsumerWidget {
  const CaptureHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 더미 데이터
    final captures = [
      CaptureItem(
        id: '1',
        drugName: '타이레놀정 500mg',
        captureDate: DateTime.now().subtract(
          const Duration(hours: 2),
        ),
        accuracy: 98.5,
        imageUrl: 'assets/sample1.jpg',
        pillCount: 1,
      ),
      CaptureItem(
        id: '2',
        drugName: '부루펜정 400mg',
        captureDate: DateTime.now().subtract(const Duration(days: 1)),
        accuracy: 95.2,
        imageUrl: 'assets/sample2.jpg',
        pillCount: 2,
      ),
      CaptureItem(
        id: '3',
        drugName: '아스피린정 100mg',
        captureDate: DateTime.now().subtract(const Duration(days: 2)),
        accuracy: 92.8,
        imageUrl: 'assets/sample3.jpg',
        pillCount: 1,
      ),
      CaptureItem(
        id: '4',
        drugName: '게보린정',
        captureDate: DateTime.now().subtract(const Duration(days: 3)),
        accuracy: 89.3,
        imageUrl: 'assets/sample4.jpg',
        pillCount: 3,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '촬영 내역',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              _showClearHistoryDialog(context);
            },
          ),
        ],
      ),
      body: captures.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: captures.length,
              itemBuilder: (context, index) {
                final capture = captures[index];
                final isFirst = index == 0;
                final isLast = index == captures.length - 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst ||
                        _isDifferentDay(
                          captures[index - 1].captureDate,
                          capture.captureDate,
                        ))
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 12,
                          top: isFirst ? 0 : 20,
                        ),
                        child: Text(
                          _formatDateHeader(capture.captureDate),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    _buildCaptureCard(context, capture),
                    if (!isLast) const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '촬영 내역이 없습니다',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '약품을 촬영하면 여기에 기록됩니다',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard(
    BuildContext context,
    CaptureItem capture,
  ) {
    return InkWell(
      onTap: () {
        // 약품 상세 페이지로 이동
        context.push('/drug/${capture.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지 썸네일
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medication,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          capture.drugName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (capture.pillCount > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${capture.pillCount}개',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTime(capture.captureDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: _getAccuracyColor(
                              capture.accuracy,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '정확도 ${capture.accuracy.toStringAsFixed(1)}%',
                            style: AppTextStyles.caption.copyWith(
                              color: _getAccuracyColor(
                                capture.accuracy,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '오늘';
    } else if (dateOnly == yesterday) {
      return '어제';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 95) return AppColors.success;
    if (accuracy >= 85) return AppColors.warning;
    return AppColors.error;
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('촬영 내역 삭제'),
        content: const Text('모든 촬영 내역을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 내역 삭제 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('촬영 내역이 삭제되었습니다')),
              );
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// 촬영 항목 모델
class CaptureItem {
  final String id;
  final String drugName;
  final DateTime captureDate;
  final double accuracy;
  final String imageUrl;
  final int pillCount;

  CaptureItem({
    required this.id,
    required this.drugName,
    required this.captureDate,
    required this.accuracy,
    required this.imageUrl,
    required this.pillCount,
  });
}
