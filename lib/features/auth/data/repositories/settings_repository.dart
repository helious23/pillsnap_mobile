import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/user_settings.dart';

/// 사용자 설정 리포지토리
class SettingsRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  
  /// 내 설정 조회
  Future<UserSettings?> fetchMySettings() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return null;
      
      final response = await _supabase.client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // 설정이 없으면 기본값으로 생성
        return await _createDefaultSettings(userId);
      }
      
      return UserSettings.fromJson(response);
    } catch (e) {
      throw Exception('설정 조회 실패: $e');
    }
  }
  
  /// 설정 업데이트
  Future<UserSettings> updateMySettings({
    String? language,
    String? theme,
    bool? notificationEnabled,
    bool? emailNotification,
    bool? pushNotification,
    bool? autoSaveCaptures,
    bool? privacyMode,
    String? preferredCameraMode,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('로그인이 필요합니다');
      
      final updateData = <String, dynamic>{};
      if (language != null) updateData['language'] = language;
      if (theme != null) updateData['theme'] = theme;
      if (notificationEnabled != null) {
        updateData['notification_enabled'] = notificationEnabled;
      }
      if (emailNotification != null) {
        updateData['email_notification'] = emailNotification;
      }
      if (pushNotification != null) {
        updateData['push_notification'] = pushNotification;
      }
      if (autoSaveCaptures != null) {
        updateData['auto_save_captures'] = autoSaveCaptures;
      }
      if (privacyMode != null) {
        updateData['privacy_mode'] = privacyMode;
      }
      if (preferredCameraMode != null) {
        updateData['preferred_camera_mode'] = preferredCameraMode;
      }
      
      if (updateData.isEmpty) {
        throw Exception('업데이트할 내용이 없습니다');
      }
      
      // upsert로 처리 (없으면 생성, 있으면 업데이트)
      final response = await _supabase.client
          .from('user_settings')
          .upsert({
            'user_id': userId,
            ...updateData,
          })
          .select()
          .single();
      
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('설정 업데이트 실패: ${e.message}');
    } catch (e) {
      throw Exception('설정 업데이트 실패: $e');
    }
  }
  
  /// 기본 설정 생성
  Future<UserSettings> _createDefaultSettings(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_settings')
          .insert({
            'user_id': userId,
            'language': 'ko',
            'theme': 'light',
            'notification_enabled': true,
            'email_notification': true,
            'push_notification': true,
            'auto_save_captures': true,
            'privacy_mode': false,
            'preferred_camera_mode': 'single',
          })
          .select()
          .single();
      
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      // 이미 존재하는 경우
      if (e.code == '23505') {
        final existing = await fetchMySettings();
        if (existing != null) return existing;
      }
      throw Exception('기본 설정 생성 실패: ${e.message}');
    } catch (e) {
      throw Exception('기본 설정 생성 실패: $e');
    }
  }
  
  /// 알림 설정 토글
  Future<UserSettings> toggleNotifications({
    required bool enabled,
  }) async {
    return updateMySettings(
      notificationEnabled: enabled,
      emailNotification: enabled,
      pushNotification: enabled,
    );
  }
  
  /// 테마 변경
  Future<UserSettings> changeTheme(String theme) async {
    if (!['light', 'dark', 'system'].contains(theme)) {
      throw Exception('지원하지 않는 테마입니다');
    }
    return updateMySettings(theme: theme);
  }
  
  /// 언어 변경
  Future<UserSettings> changeLanguage(String language) async {
    if (!['ko', 'en', 'ja', 'zh'].contains(language)) {
      throw Exception('지원하지 않는 언어입니다');
    }
    return updateMySettings(language: language);
  }
}