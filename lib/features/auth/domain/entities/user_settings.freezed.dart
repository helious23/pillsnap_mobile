// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
  String get userId => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  bool get notificationEnabled => throw _privateConstructorUsedError;
  bool get emailNotification => throw _privateConstructorUsedError;
  bool get pushNotification => throw _privateConstructorUsedError;
  bool get autoSaveCaptures => throw _privateConstructorUsedError;
  bool get privacyMode => throw _privateConstructorUsedError;
  String get preferredCameraMode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
    UserSettings value,
    $Res Function(UserSettings) then,
  ) = _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call({
    String userId,
    String language,
    String theme,
    bool notificationEnabled,
    bool emailNotification,
    bool pushNotification,
    bool autoSaveCaptures,
    bool privacyMode,
    String preferredCameraMode,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? language = null,
    Object? theme = null,
    Object? notificationEnabled = null,
    Object? emailNotification = null,
    Object? pushNotification = null,
    Object? autoSaveCaptures = null,
    Object? privacyMode = null,
    Object? preferredCameraMode = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationEnabled: null == notificationEnabled
                ? _value.notificationEnabled
                : notificationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailNotification: null == emailNotification
                ? _value.emailNotification
                : emailNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            pushNotification: null == pushNotification
                ? _value.pushNotification
                : pushNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoSaveCaptures: null == autoSaveCaptures
                ? _value.autoSaveCaptures
                : autoSaveCaptures // ignore: cast_nullable_to_non_nullable
                      as bool,
            privacyMode: null == privacyMode
                ? _value.privacyMode
                : privacyMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            preferredCameraMode: null == preferredCameraMode
                ? _value.preferredCameraMode
                : preferredCameraMode // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
    _$UserSettingsImpl value,
    $Res Function(_$UserSettingsImpl) then,
  ) = __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String language,
    String theme,
    bool notificationEnabled,
    bool emailNotification,
    bool pushNotification,
    bool autoSaveCaptures,
    bool privacyMode,
    String preferredCameraMode,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
    _$UserSettingsImpl _value,
    $Res Function(_$UserSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? language = null,
    Object? theme = null,
    Object? notificationEnabled = null,
    Object? emailNotification = null,
    Object? pushNotification = null,
    Object? autoSaveCaptures = null,
    Object? privacyMode = null,
    Object? preferredCameraMode = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserSettingsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationEnabled: null == notificationEnabled
            ? _value.notificationEnabled
            : notificationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailNotification: null == emailNotification
            ? _value.emailNotification
            : emailNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        pushNotification: null == pushNotification
            ? _value.pushNotification
            : pushNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoSaveCaptures: null == autoSaveCaptures
            ? _value.autoSaveCaptures
            : autoSaveCaptures // ignore: cast_nullable_to_non_nullable
                  as bool,
        privacyMode: null == privacyMode
            ? _value.privacyMode
            : privacyMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        preferredCameraMode: null == preferredCameraMode
            ? _value.preferredCameraMode
            : preferredCameraMode // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl({
    required this.userId,
    this.language = 'ko',
    this.theme = 'light',
    this.notificationEnabled = true,
    this.emailNotification = true,
    this.pushNotification = true,
    this.autoSaveCaptures = true,
    this.privacyMode = false,
    this.preferredCameraMode = 'single',
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final bool notificationEnabled;
  @override
  @JsonKey()
  final bool emailNotification;
  @override
  @JsonKey()
  final bool pushNotification;
  @override
  @JsonKey()
  final bool autoSaveCaptures;
  @override
  @JsonKey()
  final bool privacyMode;
  @override
  @JsonKey()
  final String preferredCameraMode;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserSettings(userId: $userId, language: $language, theme: $theme, notificationEnabled: $notificationEnabled, emailNotification: $emailNotification, pushNotification: $pushNotification, autoSaveCaptures: $autoSaveCaptures, privacyMode: $privacyMode, preferredCameraMode: $preferredCameraMode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.notificationEnabled, notificationEnabled) ||
                other.notificationEnabled == notificationEnabled) &&
            (identical(other.emailNotification, emailNotification) ||
                other.emailNotification == emailNotification) &&
            (identical(other.pushNotification, pushNotification) ||
                other.pushNotification == pushNotification) &&
            (identical(other.autoSaveCaptures, autoSaveCaptures) ||
                other.autoSaveCaptures == autoSaveCaptures) &&
            (identical(other.privacyMode, privacyMode) ||
                other.privacyMode == privacyMode) &&
            (identical(other.preferredCameraMode, preferredCameraMode) ||
                other.preferredCameraMode == preferredCameraMode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    language,
    theme,
    notificationEnabled,
    emailNotification,
    pushNotification,
    autoSaveCaptures,
    privacyMode,
    preferredCameraMode,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(this);
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings({
    required final String userId,
    final String language,
    final String theme,
    final bool notificationEnabled,
    final bool emailNotification,
    final bool pushNotification,
    final bool autoSaveCaptures,
    final bool privacyMode,
    final String preferredCameraMode,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override
  String get userId;
  @override
  String get language;
  @override
  String get theme;
  @override
  bool get notificationEnabled;
  @override
  bool get emailNotification;
  @override
  bool get pushNotification;
  @override
  bool get autoSaveCaptures;
  @override
  bool get privacyMode;
  @override
  String get preferredCameraMode;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
