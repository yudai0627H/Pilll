// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
class _$UserTearOff {
  const _$UserTearOff();

// ignore: unused_element
  _User call(
      {@required String anonymouseUserID,
      @JsonKey(name: "settings") Setting setting}) {
    return _User(
      anonymouseUserID: anonymouseUserID,
      setting: setting,
    );
  }

// ignore: unused_element
  User fromJson(Map<String, Object> json) {
    return User.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $User = _$UserTearOff();

/// @nodoc
mixin _$User {
  String get anonymouseUserID;
  @JsonKey(name: "settings")
  Setting get setting;

  Map<String, dynamic> toJson();
  $UserCopyWith<User> get copyWith;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res>;
  $Res call(
      {String anonymouseUserID, @JsonKey(name: "settings") Setting setting});

  $SettingCopyWith<$Res> get setting;
}

/// @nodoc
class _$UserCopyWithImpl<$Res> implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  final User _value;
  // ignore: unused_field
  final $Res Function(User) _then;

  @override
  $Res call({
    Object anonymouseUserID = freezed,
    Object setting = freezed,
  }) {
    return _then(_value.copyWith(
      anonymouseUserID: anonymouseUserID == freezed
          ? _value.anonymouseUserID
          : anonymouseUserID as String,
      setting: setting == freezed ? _value.setting : setting as Setting,
    ));
  }

  @override
  $SettingCopyWith<$Res> get setting {
    if (_value.setting == null) {
      return null;
    }
    return $SettingCopyWith<$Res>(_value.setting, (value) {
      return _then(_value.copyWith(setting: value));
    });
  }
}

/// @nodoc
abstract class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) then) =
      __$UserCopyWithImpl<$Res>;
  @override
  $Res call(
      {String anonymouseUserID, @JsonKey(name: "settings") Setting setting});

  @override
  $SettingCopyWith<$Res> get setting;
}

/// @nodoc
class __$UserCopyWithImpl<$Res> extends _$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(_User _value, $Res Function(_User) _then)
      : super(_value, (v) => _then(v as _User));

  @override
  _User get _value => super._value as _User;

  @override
  $Res call({
    Object anonymouseUserID = freezed,
    Object setting = freezed,
  }) {
    return _then(_User(
      anonymouseUserID: anonymouseUserID == freezed
          ? _value.anonymouseUserID
          : anonymouseUserID as String,
      setting: setting == freezed ? _value.setting : setting as Setting,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_User extends _User {
  _$_User(
      {@required this.anonymouseUserID,
      @JsonKey(name: "settings") this.setting})
      : assert(anonymouseUserID != null),
        super._();

  factory _$_User.fromJson(Map<String, dynamic> json) =>
      _$_$_UserFromJson(json);

  @override
  final String anonymouseUserID;
  @override
  @JsonKey(name: "settings")
  final Setting setting;

  @override
  String toString() {
    return 'User(anonymouseUserID: $anonymouseUserID, setting: $setting)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _User &&
            (identical(other.anonymouseUserID, anonymouseUserID) ||
                const DeepCollectionEquality()
                    .equals(other.anonymouseUserID, anonymouseUserID)) &&
            (identical(other.setting, setting) ||
                const DeepCollectionEquality().equals(other.setting, setting)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(anonymouseUserID) ^
      const DeepCollectionEquality().hash(setting);

  @override
  _$UserCopyWith<_User> get copyWith =>
      __$UserCopyWithImpl<_User>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_UserToJson(this);
  }
}

abstract class _User extends User {
  _User._() : super._();
  factory _User(
      {@required String anonymouseUserID,
      @JsonKey(name: "settings") Setting setting}) = _$_User;

  factory _User.fromJson(Map<String, dynamic> json) = _$_User.fromJson;

  @override
  String get anonymouseUserID;
  @override
  @JsonKey(name: "settings")
  Setting get setting;
  @override
  _$UserCopyWith<_User> get copyWith;
}