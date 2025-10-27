import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture.freezed.dart';
part 'capture.g.dart';

/// 촬영 기록 엔티티
@freezed
class Capture with _$Capture {
  const factory Capture({
    required String id,
    required String userId,
    required String imageUrl,
    String? roiImageUrl,
    @Default('single') String captureMode,
    @Default(1) int pillCount,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Capture;
  
  factory Capture.fromJson(Map<String, dynamic> json) => 
      _$CaptureFromJson(json);
}