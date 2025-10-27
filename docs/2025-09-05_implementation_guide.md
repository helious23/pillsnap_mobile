# PillSnap 기능 구현 가이드
작성일: 2025년 9월 5일

## 🎯 Quick Start Guide

### 1. 촬영 내역 저장/조회 구현

#### Step 1: Repository 생성
```dart
// lib/features/history/data/repositories/capture_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class CaptureRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  
  /// 촬영 결과 저장
  Future<String> saveCapture({
    required String imageUrl,
    required List<Map<String, dynamic>> results,
    required String captureType,
  }) async {
    try {
      // 1. captures 테이블에 저장
      final captureResponse = await _supabase.client
          .from('captures')
          .insert({
            'user_id': _supabase.currentUser?.id,
            'image_url': imageUrl,
            'capture_type': captureType,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      final captureId = captureResponse['id'];
      
      // 2. capture_results 테이블에 결과 저장
      if (results.isNotEmpty) {
        final resultsData = results.map((result) => {
          'capture_id': captureId,
          'drug_id': result['drug_id'],
          'drug_name': result['drug_name'],
          'confidence': result['confidence'],
          'position': result['position'],
        }).toList();
        
        await _supabase.client
            .from('capture_results')
            .insert(resultsData);
      }
      
      return captureId;
    } catch (e) {
      throw Exception('촬영 내역 저장 실패: $e');
    }
  }
  
  /// 촬영 내역 조회
  Future<List<CaptureHistory>> getCaptureHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.client
          .from('captures')
          .select('''
            *,
            capture_results (
              drug_id,
              drug_name,
              confidence
            )
          ''')
          .eq('user_id', _supabase.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(limit);
      
      if (offset > 0) {
        query = query.range(offset, offset + limit - 1);
      }
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      final response = await query;
      
      return (response as List)
          .map((data) => CaptureHistory.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('촬영 내역 조회 실패: $e');
    }
  }
}
```

#### Step 2: Provider 생성
```dart
// lib/features/history/presentation/providers/capture_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final captureRepositoryProvider = Provider((ref) => CaptureRepository());

final captureHistoryProvider = FutureProvider.autoDispose<List<CaptureHistory>>((ref) async {
  final repository = ref.watch(captureRepositoryProvider);
  return repository.getCaptureHistory();
});

// 무한 스크롤을 위한 StateNotifier
class CaptureHistoryNotifier extends StateNotifier<AsyncValue<List<CaptureHistory>>> {
  final CaptureRepository _repository;
  int _offset = 0;
  bool _hasMore = true;
  
  CaptureHistoryNotifier(this._repository) : super(const AsyncLoading()) {
    loadInitial();
  }
  
  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final captures = await _repository.getCaptureHistory(offset: 0);
      _offset = captures.length;
      _hasMore = captures.length == 20;
      state = AsyncData(captures);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    final currentData = state.value ?? [];
    
    try {
      final moreCaptures = await _repository.getCaptureHistory(offset: _offset);
      _offset += moreCaptures.length;
      _hasMore = moreCaptures.length == 20;
      
      state = AsyncData([...currentData, ...moreCaptures]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

---

### 2. 약물 즐겨찾기 구현

#### Step 1: 즐겨찾기 버튼 컴포넌트
```dart
// lib/features/drug/presentation/widgets/favorite_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteButton extends ConsumerWidget {
  final String drugId;
  final String drugName;
  final String? drugImage;
  
  const FavoriteButton({
    Key? key,
    required this.drugId,
    required this.drugName,
    this.drugImage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider(drugId));
    
    return isFavoriteAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.favorite_border),
      data: (isFavorite) => IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
        ),
        onPressed: () async {
          try {
            final repository = ref.read(favoritesRepositoryProvider);
            
            if (isFavorite) {
              await repository.removeFavorite(drugId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('즐겨찾기에서 제거되었습니다')),
              );
            } else {
              await repository.addFavorite(
                drugId: drugId,
                drugName: drugName,
                drugImage: drugImage,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('즐겨찾기에 추가되었습니다')),
              );
            }
            
            // Provider 갱신
            ref.invalidate(isFavoriteProvider(drugId));
            ref.invalidate(favoritesListProvider);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('오류: $e')),
            );
          }
        },
      ),
    );
  }
}
```

#### Step 2: 즐겨찾기 목록 페이지
```dart
// lib/features/drug/presentation/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('오류: $error')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('즐겨찾기한 약품이 없습니다'),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _FavoriteCard(favorite: favorite);
            },
          );
        },
      ),
    );
  }
}
```

---

### 3. 알러지 정보 관리

#### Step 1: 알러지 입력 위젯
```dart
// lib/features/settings/presentation/widgets/allergy_input_widget.dart

import 'package:flutter/material.dart';

class AllergyInputWidget extends StatefulWidget {
  final List<String> allergies;
  final Function(List<String>) onChanged;
  
  const AllergyInputWidget({
    Key? key,
    required this.allergies,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  _AllergyInputWidgetState createState() => _AllergyInputWidgetState();
}

class _AllergyInputWidgetState extends State<AllergyInputWidget> {
  final _controller = TextEditingController();
  final List<String> _allergies = [];
  
  // 일반적인 알러지 목록
  final List<String> commonAllergies = [
    '페니실린', '아스피린', '설파제', 'NSAIDs',
    '락토스', '글루텐', '계란', '견과류', '유제품', '조개류'
  ];
  
  @override
  void initState() {
    super.initState();
    _allergies.addAll(widget.allergies);
  }
  
  void _addAllergy(String allergy) {
    if (allergy.isNotEmpty && !_allergies.contains(allergy)) {
      setState(() {
        _allergies.add(allergy);
      });
      widget.onChanged(_allergies);
      _controller.clear();
    }
  }
  
  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
    widget.onChanged(_allergies);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 입력 필드
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '알러지 성분 입력',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addAllergy,
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle),
              color: Theme.of(context).primaryColor,
              onPressed: () => _addAllergy(_controller.text),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // 일반적인 알러지 칩
        Text('일반적인 알러지:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonAllergies.map((allergy) {
            final isSelected = _allergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _addAllergy(allergy);
                } else {
                  _removeAllergy(allergy);
                }
              },
            );
          }).toList(),
        ),
        
        SizedBox(height: 16),
        
        // 현재 알러지 목록
        Text('내 알러지 정보:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allergies.map((allergy) {
            return Chip(
              label: Text(allergy),
              deleteIcon: Icon(Icons.close, size: 18),
              onDeleted: () => _removeAllergy(allergy),
              backgroundColor: Colors.red.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

---

### 4. 복약 알림 서비스

#### Step 1: 알림 서비스 초기화
```dart
// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  /// 복약 알림 스케줄
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required TimeOfDay time,
    required List<int> weekdays, // 1=월, 7=일
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    
    for (final weekday in weekdays) {
      var scheduledDate = _nextInstanceOfWeekday(weekday, time);
      
      await _notifications.zonedSchedule(
        id + weekday, // 고유 ID
        '복약 시간',
        '$medicationName 복용 시간입니다',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminder',
            '복약 알림',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
  
  /// 특정 요일의 다음 시간 계산
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  /// 알림 취소
  Future<void> cancelMedicationReminder(int medicationId) async {
    // 모든 요일의 알림 취소 (ID + 1~7)
    for (int i = 1; i <= 7; i++) {
      await _notifications.cancel(medicationId + i);
    }
  }
  
  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // 앱 내 복약 체크 화면으로 이동
    // Navigator.push 또는 GoRouter 사용
  }
}
```

---

## 📝 체크리스트

### 촬영 내역
- [ ] Supabase 테이블 생성/확인
- [ ] Repository 구현
- [ ] Provider 설정
- [ ] UI 페이지 구현
- [ ] 홈 화면 연동
- [ ] 테스트

### 즐겨찾기
- [ ] favorites 테이블 생성
- [ ] Repository 구현
- [ ] 약품 상세에 버튼 추가
- [ ] 즐겨찾기 목록 페이지
- [ ] 홈 화면 섹션 추가

### 내가 먹는 약
- [ ] user_medications 테이블
- [ ] medication_schedules 테이블
- [ ] 약품 검색 API 연동
- [ ] 등록/수정 UI
- [ ] 목록 페이지

### 알러지
- [ ] 프로필 페이지에 섹션 추가
- [ ] 입력 위젯 구현
- [ ] 약품 분석 시 체크 로직

### 알림
- [ ] flutter_local_notifications 설정
- [ ] iOS/Android 권한 처리
- [ ] 스케줄 설정 UI
- [ ] 복약 체크 화면

---

작성자: Claude Code
최종 수정: 2025년 9월 5일