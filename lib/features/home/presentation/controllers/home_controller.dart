import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 최근 촬영 데이터 모델
class RecentCapture {
  final String id;
  final String drugName;
  final DateTime captureDate;
  final String? imageUrl;
  
  const RecentCapture({
    required this.id,
    required this.drugName,
    required this.captureDate,
    this.imageUrl,
  });
}

/// 최근 촬영 목록 프로바이더
final recentCapturesProvider = FutureProvider<List<RecentCapture>>((ref) async {
  // TODO: 실제 데이터 연동
  // 임시 데이터
  await Future<void>.delayed(const Duration(seconds: 1));
  
  return [
    RecentCapture(
      id: '1',
      drugName: '타이레놀 500mg',
      captureDate: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    RecentCapture(
      id: '2',
      drugName: '부루펜 400mg',
      captureDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentCapture(
      id: '3',
      drugName: '아스피린 100mg',
      captureDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
});

/// 홈 화면 상태 컨트롤러
class HomeController extends Notifier<void> {
  @override
  void build() {}
  
  /// 최근 촬영 목록 새로고침
  Future<void> refreshRecentCaptures() async {
    ref.invalidate(recentCapturesProvider);
  }
}

/// 홈 컨트롤러 프로바이더
final homeControllerProvider = 
    NotifierProvider<HomeController, void>(HomeController.new);