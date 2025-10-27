import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/profile.dart';

/// 프로필 리포지토리
class ProfileRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  
  /// 내 프로필 조회
  Future<Profile?> fetchMyProfile() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return null;
      
      final response = await _supabase.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }
  
  /// 프로필 업데이트 (기존 메소드)
  Future<Profile> updateMyProfile({
    String? displayName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      final userEmail = _supabase.currentUser?.email;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final updateData = <String, dynamic>{
        'user_id': userId, // upsert를 위해 user_id 포함
        'email': userEmail, // email 필드 추가
      };
      if (displayName != null) updateData['display_name'] = displayName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      
      // upsert를 사용하여 프로필이 없으면 생성, 있으면 업데이트
      final response = await _supabase.client
          .from('profiles')
          .upsert(updateData, onConflict: 'user_id')
          .select()
          .single();
      
      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('프로필 업데이트 실패: ${e.message}');
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }
  
  /// 프로필 업데이트 (회원가입 시 추가 정보)
  Future<void> updateProfile({
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    List<String>? allergies,
    bool? profileCompleted,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      final userEmail = _supabase.currentUser?.email;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final updateData = <String, dynamic>{
        'user_id': userId, // upsert를 위해 user_id 포함
        'email': userEmail, // email 필드 추가
      };
      if (phoneNumber != null) updateData['phone'] = phoneNumber;
      if (birthDate != null) updateData['birth_date'] = birthDate.toIso8601String();
      if (gender != null) updateData['gender'] = gender;
      // allergies 처리 - 안전한 방식으로 처리
      if (allergies != null && allergies.isNotEmpty) {
        // 각 항목을 sanitize하고 유효성 검사
        final sanitizedAllergies = allergies
            .where((item) => item.isNotEmpty && item.length <= 100) // 길이 제한
            .map((item) => item.trim()) // 공백 제거
            .toList();
        
        // Supabase는 배열을 직접 지원하므로 List로 전달
        // SDK가 자동으로 파라미터화된 쿼리로 변환
        updateData['allergies'] = sanitizedAllergies;
      } else {
        updateData['allergies'] = null;
      }
      if (profileCompleted != null) updateData['profile_completed'] = profileCompleted;
      
      // upsert를 사용하여 프로필이 없으면 생성, 있으면 업데이트
      await _supabase.client
          .from('profiles')
          .upsert(updateData, onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw Exception('프로필 업데이트 실패: ${e.message}');
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }
  
  /// 아바타 업로드
  Future<String> uploadAvatar(String filePath) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'avatars/$fileName';
      
      // 기존 아바타 삭제
      try {
        final oldFiles = await _supabase.client.storage
            .from('pillsnap-storage')
            .list(path: 'avatars/$userId');
        
        for (final file in oldFiles) {
          await _supabase.client.storage
              .from('pillsnap-storage')
              .remove(['avatars/$userId/${file.name}']);
        }
      } catch (_) {
        // 기존 파일이 없을 수 있음
      }
      
      // 새 아바타 업로드
      final file = await File(filePath).readAsBytes();
      await _supabase.client.storage
          .from('pillsnap-storage')
          .uploadBinary(storagePath, file);
      
      // Public URL 가져오기
      final url = _supabase.client.storage
          .from('pillsnap-storage')
          .getPublicUrl(storagePath);
      
      // 프로필 업데이트
      await updateMyProfile(avatarUrl: url);
      
      return url;
    } catch (e) {
      throw Exception('아바타 업로드 실패: $e');
    }
  }
  
  /// 알림 설정 업데이트
  Future<void> updateNotificationSettings({
    bool? emailNotification,
    bool? pushNotification,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      final userEmail = _supabase.currentUser?.email;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final updateData = <String, dynamic>{
        'user_id': userId,
        'email': userEmail, // email 필드 추가 (필수 필드)
      };
      
      if (emailNotification != null) {
        updateData['email_notification'] = emailNotification;
      }
      if (pushNotification != null) {
        updateData['push_notification'] = pushNotification;
      }
      
      await _supabase.client
          .from('profiles')
          .upsert(updateData, onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw Exception('알림 설정 업데이트 실패: ${e.message}');
    } catch (e) {
      throw Exception('알림 설정 업데이트 실패: $e');
    }
  }
  
  /// 프로필 생성 (회원가입 직후 사용)
  Future<Profile> createProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .insert({
            'user_id': userId,
            'email': email,
            'display_name': displayName,
          })
          .select()
          .single();
      
      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      // 이미 존재하는 경우 조회해서 반환
      if (e.code == '23505') {
        final existing = await fetchMyProfile();
        if (existing != null) return existing;
      }
      throw Exception('프로필 생성 실패: ${e.message}');
    } catch (e) {
      throw Exception('프로필 생성 실패: $e');
    }
  }
}