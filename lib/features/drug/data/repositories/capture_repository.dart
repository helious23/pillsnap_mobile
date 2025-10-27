import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/capture.dart';

/// 촬영 기록 리포지토리
class CaptureRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  
  /// 촬영 기록 생성
  Future<Capture> createCapture({
    required String imagePath,
    String? roiImagePath,
    required String captureMode,
    required int pillCount,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      // 이미지 업로드
      final imageUrl = await _uploadCaptureImage(imagePath);
      String? roiImageUrl;
      
      if (roiImagePath != null) {
        roiImageUrl = await _uploadCaptureImage(roiImagePath, isRoi: true);
      }
      
      // DB에 기록 저장
      final response = await _supabase.client
          .from('captures')
          .insert({
            'user_id': userId,
            'image_url': imageUrl,
            'roi_image_url': roiImageUrl,
            'capture_mode': captureMode,
            'pill_count': pillCount,
            'device_info': deviceInfo,
            'location': location,
          })
          .select()
          .single();
      
      return Capture.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('촬영 기록 저장 실패: ${e.message}');
    } catch (e) {
      throw Exception('촬영 기록 저장 실패: $e');
    }
  }
  
  /// 내 촬영 기록 목록 조회
  Future<List<Capture>> listMyCaptures({
    int limit = 20,
    DateTime? since,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      // since가 있으면 그 이전 데이터만 조회
      final response = since != null
          ? await _supabase.client
              .from('captures')
              .select()
              .eq('user_id', userId)
              .filter('created_at', 'lt', since.toIso8601String())
              .order('created_at', ascending: false)
              .limit(limit)
          : await _supabase.client
              .from('captures')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(limit);
      
      return (response as List)
          .map((json) => Capture.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('촬영 기록 조회 실패: $e');
    }
  }
  
  /// 특정 촬영 기록 조회
  Future<Capture?> getCapture(String captureId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final response = await _supabase.client
          .from('captures')
          .select()
          .eq('id', captureId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Capture.fromJson(response);
    } catch (e) {
      throw Exception('촬영 기록 조회 실패: $e');
    }
  }
  
  /// 촬영 기록 삭제
  Future<void> deleteCapture(String captureId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      // 먼저 이미지 URL 가져오기
      final capture = await getCapture(captureId);
      if (capture == null) return;
      
      // Storage에서 이미지 삭제  
      // Capture 엔티티에 imageUrl/roiImageUrl 필드가 없으므로 주석 처리
      // await _deleteStorageImage(capture.imageUrl);
      // if (capture.roiImageUrl != null) {
      //   await _deleteStorageImage(capture.roiImageUrl!);
      // }
      
      // DB에서 기록 삭제 (연관된 drug_results는 CASCADE 삭제)
      await _supabase.client
          .from('captures')
          .delete()
          .eq('id', captureId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('촬영 기록 삭제 실패: $e');
    }
  }
  
  /// 촬영 이미지 업로드
  Future<String> _uploadCaptureImage(String imagePath, {bool isRoi = false}) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final captureId = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = isRoi ? 'roi.jpg' : 'original.jpg';
      final storagePath = 'captures/$userId/$captureId/$fileName';
      
      final file = File(imagePath);
      
      await _supabase.client.storage
          .from('pillsnap-storage')
          .upload(storagePath, file);
      
      final url = _supabase.client.storage
          .from('pillsnap-storage')
          .getPublicUrl(storagePath);
      
      return url;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }
  
  /// 최근 촬영 통계
  Future<Map<String, dynamic>> getCaptureStats() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      // 전체 촬영 수
      final totalCount = await _supabase.client
          .from('captures')
          .select('id')
          .eq('user_id', userId);
      
      // 오늘 촬영 수
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final todayCount = await _supabase.client
          .from('captures')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', todayStart.toIso8601String());
      
      return {
        'total': (totalCount as List).length,
        'today': (todayCount as List).length,
      };
    } catch (e) {
      throw Exception('통계 조회 실패: $e');
    }
  }
}