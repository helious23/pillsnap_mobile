// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Capture _$CaptureFromJson(Map<String, dynamic> json) {
  return _Capture.fromJson(json);
}

/// @nodoc
mixin _$Capture {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get roiImageUrl => throw _privateConstructorUsedError;
  String get captureMode => throw _privateConstructorUsedError;
  int get pillCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get deviceInfo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get location => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Capture to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaptureCopyWith<Capture> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptureCopyWith<$Res> {
  factory $CaptureCopyWith(Capture value, $Res Function(Capture) then) =
      _$CaptureCopyWithImpl<$Res, Capture>;
  @useResult
  $Res call({
    String id,
    String userId,
    String imageUrl,
    String? roiImageUrl,
    String captureMode,
    int pillCount,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CaptureCopyWithImpl<$Res, $Val extends Capture>
    implements $CaptureCopyWith<$Res> {
  _$CaptureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? roiImageUrl = freezed,
    Object? captureMode = null,
    Object? pillCount = null,
    Object? deviceInfo = freezed,
    Object? location = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            roiImageUrl: freezed == roiImageUrl
                ? _value.roiImageUrl
                : roiImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            captureMode: null == captureMode
                ? _value.captureMode
                : captureMode // ignore: cast_nullable_to_non_nullable
                      as String,
            pillCount: null == pillCount
                ? _value.pillCount
                : pillCount // ignore: cast_nullable_to_non_nullable
                      as int,
            deviceInfo: freezed == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$CaptureImplCopyWith<$Res> implements $CaptureCopyWith<$Res> {
  factory _$$CaptureImplCopyWith(
    _$CaptureImpl value,
    $Res Function(_$CaptureImpl) then,
  ) = __$$CaptureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String imageUrl,
    String? roiImageUrl,
    String captureMode,
    int pillCount,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CaptureImplCopyWithImpl<$Res>
    extends _$CaptureCopyWithImpl<$Res, _$CaptureImpl>
    implements _$$CaptureImplCopyWith<$Res> {
  __$$CaptureImplCopyWithImpl(
    _$CaptureImpl _value,
    $Res Function(_$CaptureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? roiImageUrl = freezed,
    Object? captureMode = null,
    Object? pillCount = null,
    Object? deviceInfo = freezed,
    Object? location = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CaptureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        roiImageUrl: freezed == roiImageUrl
            ? _value.roiImageUrl
            : roiImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        captureMode: null == captureMode
            ? _value.captureMode
            : captureMode // ignore: cast_nullable_to_non_nullable
                  as String,
        pillCount: null == pillCount
            ? _value.pillCount
            : pillCount // ignore: cast_nullable_to_non_nullable
                  as int,
        deviceInfo: freezed == deviceInfo
            ? _value._deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        location: freezed == location
            ? _value._location
            : location // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$CaptureImpl implements _Capture {
  const _$CaptureImpl({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.roiImageUrl,
    this.captureMode = 'single',
    this.pillCount = 1,
    final Map<String, dynamic>? deviceInfo,
    final Map<String, dynamic>? location,
    required this.createdAt,
    required this.updatedAt,
  }) : _deviceInfo = deviceInfo,
       _location = location;

  factory _$CaptureImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaptureImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String imageUrl;
  @override
  final String? roiImageUrl;
  @override
  @JsonKey()
  final String captureMode;
  @override
  @JsonKey()
  final int pillCount;
  final Map<String, dynamic>? _deviceInfo;
  @override
  Map<String, dynamic>? get deviceInfo {
    final value = _deviceInfo;
    if (value == null) return null;
    if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _location;
  @override
  Map<String, dynamic>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableMapView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Capture(id: $id, userId: $userId, imageUrl: $imageUrl, roiImageUrl: $roiImageUrl, captureMode: $captureMode, pillCount: $pillCount, deviceInfo: $deviceInfo, location: $location, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.roiImageUrl, roiImageUrl) ||
                other.roiImageUrl == roiImageUrl) &&
            (identical(other.captureMode, captureMode) ||
                other.captureMode == captureMode) &&
            (identical(other.pillCount, pillCount) ||
                other.pillCount == pillCount) &&
            const DeepCollectionEquality().equals(
              other._deviceInfo,
              _deviceInfo,
            ) &&
            const DeepCollectionEquality().equals(other._location, _location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    imageUrl,
    roiImageUrl,
    captureMode,
    pillCount,
    const DeepCollectionEquality().hash(_deviceInfo),
    const DeepCollectionEquality().hash(_location),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptureImplCopyWith<_$CaptureImpl> get copyWith =>
      __$$CaptureImplCopyWithImpl<_$CaptureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CaptureImplToJson(this);
  }
}

abstract class _Capture implements Capture {
  const factory _Capture({
    required final String id,
    required final String userId,
    required final String imageUrl,
    final String? roiImageUrl,
    final String captureMode,
    final int pillCount,
    final Map<String, dynamic>? deviceInfo,
    final Map<String, dynamic>? location,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CaptureImpl;

  factory _Capture.fromJson(Map<String, dynamic> json) = _$CaptureImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get imageUrl;
  @override
  String? get roiImageUrl;
  @override
  String get captureMode;
  @override
  int get pillCount;
  @override
  Map<String, dynamic>? get deviceInfo;
  @override
  Map<String, dynamic>? get location;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Capture
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptureImplCopyWith<_$CaptureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
