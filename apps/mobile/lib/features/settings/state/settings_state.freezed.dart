// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

/// Theme mode: system, light, or dark.
 ThemeMode get themeMode;/// App display locale ID (e.g. 'ja', 'en').
/// Empty string means follow the device default.
 String get appLocaleId;/// Locale ID for speech recognition (e.g. 'ja-JP', 'en-US').
/// Empty string means use device default.
 String get speechLocaleId;/// Currently connected Machine ID (null when disconnected).
 String? get activeMachineId;/// Shorebird update track ('stable' or 'staging').
 String get shorebirdTrack;/// Indent size for list formatting (1-4 spaces).
 int get indentSize;/// Whether to hide the voice input button in the chat input bar.
 bool get hideVoiceInput;/// External terminal app configuration (preset or custom URL template).
 TerminalAppConfig get terminalApp;/// Visible tabs (and their order) in the new session sheet.
 List<NewSessionTab> get newSessionTabs;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.appLocaleId, appLocaleId) || other.appLocaleId == appLocaleId)&&(identical(other.speechLocaleId, speechLocaleId) || other.speechLocaleId == speechLocaleId)&&(identical(other.activeMachineId, activeMachineId) || other.activeMachineId == activeMachineId)&&(identical(other.shorebirdTrack, shorebirdTrack) || other.shorebirdTrack == shorebirdTrack)&&(identical(other.indentSize, indentSize) || other.indentSize == indentSize)&&(identical(other.hideVoiceInput, hideVoiceInput) || other.hideVoiceInput == hideVoiceInput)&&(identical(other.terminalApp, terminalApp) || other.terminalApp == terminalApp)&&const DeepCollectionEquality().equals(other.newSessionTabs, newSessionTabs));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,appLocaleId,speechLocaleId,activeMachineId,shorebirdTrack,indentSize,hideVoiceInput,terminalApp,const DeepCollectionEquality().hash(newSessionTabs));

@override
String toString() {
  return 'SettingsState(themeMode: $themeMode, appLocaleId: $appLocaleId, speechLocaleId: $speechLocaleId, activeMachineId: $activeMachineId, shorebirdTrack: $shorebirdTrack, indentSize: $indentSize, hideVoiceInput: $hideVoiceInput, terminalApp: $terminalApp, newSessionTabs: $newSessionTabs)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, String appLocaleId, String speechLocaleId, String? activeMachineId, String shorebirdTrack, int indentSize, bool hideVoiceInput, TerminalAppConfig terminalApp, List<NewSessionTab> newSessionTabs
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? appLocaleId = null,Object? speechLocaleId = null,Object? activeMachineId = freezed,Object? shorebirdTrack = null,Object? indentSize = null,Object? hideVoiceInput = null,Object? terminalApp = null,Object? newSessionTabs = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,appLocaleId: null == appLocaleId ? _self.appLocaleId : appLocaleId // ignore: cast_nullable_to_non_nullable
as String,speechLocaleId: null == speechLocaleId ? _self.speechLocaleId : speechLocaleId // ignore: cast_nullable_to_non_nullable
as String,activeMachineId: freezed == activeMachineId ? _self.activeMachineId : activeMachineId // ignore: cast_nullable_to_non_nullable
as String?,shorebirdTrack: null == shorebirdTrack ? _self.shorebirdTrack : shorebirdTrack // ignore: cast_nullable_to_non_nullable
as String,indentSize: null == indentSize ? _self.indentSize : indentSize // ignore: cast_nullable_to_non_nullable
as int,hideVoiceInput: null == hideVoiceInput ? _self.hideVoiceInput : hideVoiceInput // ignore: cast_nullable_to_non_nullable
as bool,terminalApp: null == terminalApp ? _self.terminalApp : terminalApp // ignore: cast_nullable_to_non_nullable
as TerminalAppConfig,newSessionTabs: null == newSessionTabs ? _self.newSessionTabs : newSessionTabs // ignore: cast_nullable_to_non_nullable
as List<NewSessionTab>,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  String appLocaleId,  String speechLocaleId,  String? activeMachineId,  String shorebirdTrack,  int indentSize,  bool hideVoiceInput,  TerminalAppConfig terminalApp,  List<NewSessionTab> newSessionTabs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.appLocaleId,_that.speechLocaleId,_that.activeMachineId,_that.shorebirdTrack,_that.indentSize,_that.hideVoiceInput,_that.terminalApp,_that.newSessionTabs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  String appLocaleId,  String speechLocaleId,  String? activeMachineId,  String shorebirdTrack,  int indentSize,  bool hideVoiceInput,  TerminalAppConfig terminalApp,  List<NewSessionTab> newSessionTabs)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.themeMode,_that.appLocaleId,_that.speechLocaleId,_that.activeMachineId,_that.shorebirdTrack,_that.indentSize,_that.hideVoiceInput,_that.terminalApp,_that.newSessionTabs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  String appLocaleId,  String speechLocaleId,  String? activeMachineId,  String shorebirdTrack,  int indentSize,  bool hideVoiceInput,  TerminalAppConfig terminalApp,  List<NewSessionTab> newSessionTabs)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.appLocaleId,_that.speechLocaleId,_that.activeMachineId,_that.shorebirdTrack,_that.indentSize,_that.hideVoiceInput,_that.terminalApp,_that.newSessionTabs);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState extends SettingsState {
  const _SettingsState({this.themeMode = ThemeMode.system, this.appLocaleId = '', this.speechLocaleId = 'ja-JP', this.activeMachineId, this.shorebirdTrack = 'stable', this.indentSize = 2, this.hideVoiceInput = false, this.terminalApp = TerminalAppConfig.empty, final  List<NewSessionTab> newSessionTabs = defaultNewSessionTabs}): _newSessionTabs = newSessionTabs,super._();
  

/// Theme mode: system, light, or dark.
@override@JsonKey() final  ThemeMode themeMode;
/// App display locale ID (e.g. 'ja', 'en').
/// Empty string means follow the device default.
@override@JsonKey() final  String appLocaleId;
/// Locale ID for speech recognition (e.g. 'ja-JP', 'en-US').
/// Empty string means use device default.
@override@JsonKey() final  String speechLocaleId;
/// Currently connected Machine ID (null when disconnected).
@override final  String? activeMachineId;
/// Shorebird update track ('stable' or 'staging').
@override@JsonKey() final  String shorebirdTrack;
/// Indent size for list formatting (1-4 spaces).
@override@JsonKey() final  int indentSize;
/// Whether to hide the voice input button in the chat input bar.
@override@JsonKey() final  bool hideVoiceInput;
/// External terminal app configuration (preset or custom URL template).
@override@JsonKey() final  TerminalAppConfig terminalApp;
/// Visible tabs (and their order) in the new session sheet.
 final  List<NewSessionTab> _newSessionTabs;
/// Visible tabs (and their order) in the new session sheet.
@override@JsonKey() List<NewSessionTab> get newSessionTabs {
  if (_newSessionTabs is EqualUnmodifiableListView) return _newSessionTabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newSessionTabs);
}


/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.appLocaleId, appLocaleId) || other.appLocaleId == appLocaleId)&&(identical(other.speechLocaleId, speechLocaleId) || other.speechLocaleId == speechLocaleId)&&(identical(other.activeMachineId, activeMachineId) || other.activeMachineId == activeMachineId)&&(identical(other.shorebirdTrack, shorebirdTrack) || other.shorebirdTrack == shorebirdTrack)&&(identical(other.indentSize, indentSize) || other.indentSize == indentSize)&&(identical(other.hideVoiceInput, hideVoiceInput) || other.hideVoiceInput == hideVoiceInput)&&(identical(other.terminalApp, terminalApp) || other.terminalApp == terminalApp)&&const DeepCollectionEquality().equals(other._newSessionTabs, _newSessionTabs));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,appLocaleId,speechLocaleId,activeMachineId,shorebirdTrack,indentSize,hideVoiceInput,terminalApp,const DeepCollectionEquality().hash(_newSessionTabs));

@override
String toString() {
  return 'SettingsState(themeMode: $themeMode, appLocaleId: $appLocaleId, speechLocaleId: $speechLocaleId, activeMachineId: $activeMachineId, shorebirdTrack: $shorebirdTrack, indentSize: $indentSize, hideVoiceInput: $hideVoiceInput, terminalApp: $terminalApp, newSessionTabs: $newSessionTabs)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, String appLocaleId, String speechLocaleId, String? activeMachineId, String shorebirdTrack, int indentSize, bool hideVoiceInput, TerminalAppConfig terminalApp, List<NewSessionTab> newSessionTabs
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? appLocaleId = null,Object? speechLocaleId = null,Object? activeMachineId = freezed,Object? shorebirdTrack = null,Object? indentSize = null,Object? hideVoiceInput = null,Object? terminalApp = null,Object? newSessionTabs = null,}) {
  return _then(_SettingsState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,appLocaleId: null == appLocaleId ? _self.appLocaleId : appLocaleId // ignore: cast_nullable_to_non_nullable
as String,speechLocaleId: null == speechLocaleId ? _self.speechLocaleId : speechLocaleId // ignore: cast_nullable_to_non_nullable
as String,activeMachineId: freezed == activeMachineId ? _self.activeMachineId : activeMachineId // ignore: cast_nullable_to_non_nullable
as String?,shorebirdTrack: null == shorebirdTrack ? _self.shorebirdTrack : shorebirdTrack // ignore: cast_nullable_to_non_nullable
as String,indentSize: null == indentSize ? _self.indentSize : indentSize // ignore: cast_nullable_to_non_nullable
as int,hideVoiceInput: null == hideVoiceInput ? _self.hideVoiceInput : hideVoiceInput // ignore: cast_nullable_to_non_nullable
as bool,terminalApp: null == terminalApp ? _self.terminalApp : terminalApp // ignore: cast_nullable_to_non_nullable
as TerminalAppConfig,newSessionTabs: null == newSessionTabs ? _self._newSessionTabs : newSessionTabs // ignore: cast_nullable_to_non_nullable
as List<NewSessionTab>,
  ));
}


}

// dart format on
