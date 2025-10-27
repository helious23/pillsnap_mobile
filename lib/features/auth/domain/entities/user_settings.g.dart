// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      userId: json['userId'] as String,
      language: json['language'] as String? ?? 'ko',
      theme: json['theme'] as String? ?? 'light',
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      emailNotification: json['emailNotification'] as bool? ?? true,
      pushNotification: json['pushNotification'] as bool? ?? true,
      autoSaveCaptures: json['autoSaveCaptures'] as bool? ?? true,
      privacyMode: json['privacyMode'] as bool? ?? false,
      preferredCameraMode: json['preferredCameraMode'] as String? ?? 'single',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'language': instance.language,
      'theme': instance.theme,
      'notificationEnabled': instance.notificationEnabled,
      'emailNotification': instance.emailNotification,
      'pushNotification': instance.pushNotification,
      'autoSaveCaptures': instance.autoSaveCaptures,
      'privacyMode': instance.privacyMode,
      'preferredCameraMode': instance.preferredCameraMode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
