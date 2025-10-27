import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/core/network/api_client.dart';
import 'package:pillsnap/theme/app_colors.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// API 헬스체크 상태
enum HealthStatus { checking, online, offline, degraded }

/// API 헬스체크 Provider
final healthCheckProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = PillSnapAPIClient();
  return await apiClient.checkHealth();
});

/// 헬스체크 위젯
class HealthCheckWidget extends ConsumerWidget {
  const HealthCheckWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthCheckProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(healthAsync),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIndicator(healthAsync),
          const SizedBox(width: AppSpacing.sm),
          _buildStatusText(healthAsync),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(AsyncValue<Map<String, dynamic>> healthAsync) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getIndicatorColor(healthAsync),
      ),
    );
  }
  
  Widget _buildStatusText(AsyncValue<Map<String, dynamic>> healthAsync) {
    return healthAsync.when(
      data: (data) {
        final status = data['status'] as String?;
        if (status == 'healthy') {
          return Text(
            'API 서버 정상',
            style: AppTextStyles.caption.copyWith(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          );
        } else {
          return Text(
            'API 서버 상태: $status',
            style: AppTextStyles.caption.copyWith(
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          );
        }
      },
      loading: () => Text(
        'API 서버 확인 중...',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      error: (error, stack) => Text(
        'API 서버 오프라인',
        style: AppTextStyles.caption.copyWith(
          color: Colors.red[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Color _getBackgroundColor(AsyncValue<Map<String, dynamic>> healthAsync) {
    return healthAsync.when(
      data: (data) {
        final status = data['status'] as String?;
        if (status == 'healthy') {
          return Colors.green.withValues(alpha: 0.1);
        } else {
          return Colors.orange.withValues(alpha: 0.1);
        }
      },
      loading: () => AppColors.surface,
      error: (_, __) => Colors.red.withValues(alpha: 0.1),
    );
  }
  
  Color _getIndicatorColor(AsyncValue<Map<String, dynamic>> healthAsync) {
    return healthAsync.when(
      data: (data) {
        final status = data['status'] as String?;
        if (status == 'healthy') {
          return Colors.green;
        } else {
          return Colors.orange;
        }
      },
      loading: () => AppColors.textSecondary,
      error: (_, __) => Colors.red,
    );
  }
}