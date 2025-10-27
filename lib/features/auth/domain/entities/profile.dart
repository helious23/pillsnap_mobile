import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// 사용자 프로필 엔티티
@freezed
class Profile with _$Profile {
  const Profile._();
  
  const factory Profile({
    @JsonKey(name: 'user_id') required String id,
    required String email,
    String? displayName,
    String? phone,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    List<String>? allergies,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSeenAt,
    @Default(true) bool isActive,
    @Default(false) bool profileCompleted,
    @Default(true) bool emailNotification,
    @Default(true) bool pushNotification,
  }) = _Profile;
  
  factory Profile.fromJson(Map<String, dynamic> json) => 
      _$ProfileFromJson(json);
}