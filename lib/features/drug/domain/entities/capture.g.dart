// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CaptureImpl _$$CaptureImplFromJson(Map<String, dynamic> json) =>
    _$CaptureImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      roiImageUrl: json['roiImageUrl'] as String?,
      captureMode: json['captureMode'] as String? ?? 'single',
      pillCount: (json['pillCount'] as num?)?.toInt() ?? 1,
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
      location: json['location'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CaptureImplToJson(_$CaptureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'imageUrl': instance.imageUrl,
      'roiImageUrl': instance.roiImageUrl,
      'captureMode': instance.captureMode,
      'pillCount': instance.pillCount,
      'deviceInfo': instance.deviceInfo,
      'location': instance.location,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
