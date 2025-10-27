import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// 사용자 설정 엔티티
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    @Default('ko') String language,
    @Default('light') String theme,
    @Default(true) bool notificationEnabled,
    @Default(true) bool emailNotification,
    @Default(true) bool pushNotification,
    @Default(true) bool autoSaveCaptures,
    @Default(false) bool privacyMode,
    @Default('single') String preferredCameraMode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserSettings;
  
  factory UserSettings.fromJson(Map<String, dynamic> json) => 
      _$UserSettingsFromJson(json);
}