// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['user_id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
      gender: json['gender'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      emailNotification: json['email_notification'] as bool? ?? true,
      pushNotification: json['push_notification'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'user_id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'birth_date': instance.birthDate?.toIso8601String(),
      'gender': instance.gender,
      'allergies': instance.allergies,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'is_active': instance.isActive,
      'profile_completed': instance.profileCompleted,
      'email_notification': instance.emailNotification,
      'push_notification': instance.pushNotification,
    };
