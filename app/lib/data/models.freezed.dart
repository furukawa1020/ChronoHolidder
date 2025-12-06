// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EraScore {

 String get era_name; int get start_year; int get end_year; double get score; String get reason; List<String> get artifacts; String? get image_url;
/// Create a copy of EraScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EraScoreCopyWith<EraScore> get copyWith => _$EraScoreCopyWithImpl<EraScore>(this as EraScore, _$identity);

  /// Serializes this EraScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EraScore&&(identical(other.era_name, era_name) || other.era_name == era_name)&&(identical(other.start_year, start_year) || other.start_year == start_year)&&(identical(other.end_year, end_year) || other.end_year == end_year)&&(identical(other.score, score) || other.score == score)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.artifacts, artifacts)&&(identical(other.image_url, image_url) || other.image_url == image_url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,era_name,start_year,end_year,score,reason,const DeepCollectionEquality().hash(artifacts),image_url);

@override
String toString() {
  return 'EraScore(era_name: $era_name, start_year: $start_year, end_year: $end_year, score: $score, reason: $reason, artifacts: $artifacts, image_url: $image_url)';
}


}

/// @nodoc
abstract mixin class $EraScoreCopyWith<$Res>  {
  factory $EraScoreCopyWith(EraScore value, $Res Function(EraScore) _then) = _$EraScoreCopyWithImpl;
@useResult
$Res call({
 String era_name, int start_year, int end_year, double score, String reason, List<String> artifacts, String? image_url
});




}
/// @nodoc
class _$EraScoreCopyWithImpl<$Res>
    implements $EraScoreCopyWith<$Res> {
  _$EraScoreCopyWithImpl(this._self, this._then);

  final EraScore _self;
  final $Res Function(EraScore) _then;

/// Create a copy of EraScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? era_name = null,Object? start_year = null,Object? end_year = null,Object? score = null,Object? reason = null,Object? artifacts = null,Object? image_url = freezed,}) {
  return _then(_self.copyWith(
era_name: null == era_name ? _self.era_name : era_name // ignore: cast_nullable_to_non_nullable
as String,start_year: null == start_year ? _self.start_year : start_year // ignore: cast_nullable_to_non_nullable
as int,end_year: null == end_year ? _self.end_year : end_year // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,artifacts: null == artifacts ? _self.artifacts : artifacts // ignore: cast_nullable_to_non_nullable
as List<String>,image_url: freezed == image_url ? _self.image_url : image_url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EraScore].
extension EraScorePatterns on EraScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EraScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EraScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EraScore value)  $default,){
final _that = this;
switch (_that) {
case _EraScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EraScore value)?  $default,){
final _that = this;
switch (_that) {
case _EraScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String era_name,  int start_year,  int end_year,  double score,  String reason,  List<String> artifacts,  String? image_url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EraScore() when $default != null:
return $default(_that.era_name,_that.start_year,_that.end_year,_that.score,_that.reason,_that.artifacts,_that.image_url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String era_name,  int start_year,  int end_year,  double score,  String reason,  List<String> artifacts,  String? image_url)  $default,) {final _that = this;
switch (_that) {
case _EraScore():
return $default(_that.era_name,_that.start_year,_that.end_year,_that.score,_that.reason,_that.artifacts,_that.image_url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String era_name,  int start_year,  int end_year,  double score,  String reason,  List<String> artifacts,  String? image_url)?  $default,) {final _that = this;
switch (_that) {
case _EraScore() when $default != null:
return $default(_that.era_name,_that.start_year,_that.end_year,_that.score,_that.reason,_that.artifacts,_that.image_url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EraScore implements EraScore {
  const _EraScore({required this.era_name, required this.start_year, required this.end_year, required this.score, required this.reason, required final  List<String> artifacts, this.image_url}): _artifacts = artifacts;
  factory _EraScore.fromJson(Map<String, dynamic> json) => _$EraScoreFromJson(json);

@override final  String era_name;
@override final  int start_year;
@override final  int end_year;
@override final  double score;
@override final  String reason;
 final  List<String> _artifacts;
@override List<String> get artifacts {
  if (_artifacts is EqualUnmodifiableListView) return _artifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artifacts);
}

@override final  String? image_url;

/// Create a copy of EraScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EraScoreCopyWith<_EraScore> get copyWith => __$EraScoreCopyWithImpl<_EraScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EraScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EraScore&&(identical(other.era_name, era_name) || other.era_name == era_name)&&(identical(other.start_year, start_year) || other.start_year == start_year)&&(identical(other.end_year, end_year) || other.end_year == end_year)&&(identical(other.score, score) || other.score == score)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._artifacts, _artifacts)&&(identical(other.image_url, image_url) || other.image_url == image_url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,era_name,start_year,end_year,score,reason,const DeepCollectionEquality().hash(_artifacts),image_url);

@override
String toString() {
  return 'EraScore(era_name: $era_name, start_year: $start_year, end_year: $end_year, score: $score, reason: $reason, artifacts: $artifacts, image_url: $image_url)';
}


}

/// @nodoc
abstract mixin class _$EraScoreCopyWith<$Res> implements $EraScoreCopyWith<$Res> {
  factory _$EraScoreCopyWith(_EraScore value, $Res Function(_EraScore) _then) = __$EraScoreCopyWithImpl;
@override @useResult
$Res call({
 String era_name, int start_year, int end_year, double score, String reason, List<String> artifacts, String? image_url
});




}
/// @nodoc
class __$EraScoreCopyWithImpl<$Res>
    implements _$EraScoreCopyWith<$Res> {
  __$EraScoreCopyWithImpl(this._self, this._then);

  final _EraScore _self;
  final $Res Function(_EraScore) _then;

/// Create a copy of EraScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? era_name = null,Object? start_year = null,Object? end_year = null,Object? score = null,Object? reason = null,Object? artifacts = null,Object? image_url = freezed,}) {
  return _then(_EraScore(
era_name: null == era_name ? _self.era_name : era_name // ignore: cast_nullable_to_non_nullable
as String,start_year: null == start_year ? _self.start_year : start_year // ignore: cast_nullable_to_non_nullable
as int,end_year: null == end_year ? _self.end_year : end_year // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,artifacts: null == artifacts ? _self._artifacts : artifacts // ignore: cast_nullable_to_non_nullable
as List<String>,image_url: freezed == image_url ? _self.image_url : image_url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AnalysisResponse {

 String get location_name; List<EraScore> get peak_eras; String get summary_ai;
/// Create a copy of AnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisResponseCopyWith<AnalysisResponse> get copyWith => _$AnalysisResponseCopyWithImpl<AnalysisResponse>(this as AnalysisResponse, _$identity);

  /// Serializes this AnalysisResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisResponse&&(identical(other.location_name, location_name) || other.location_name == location_name)&&const DeepCollectionEquality().equals(other.peak_eras, peak_eras)&&(identical(other.summary_ai, summary_ai) || other.summary_ai == summary_ai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location_name,const DeepCollectionEquality().hash(peak_eras),summary_ai);

@override
String toString() {
  return 'AnalysisResponse(location_name: $location_name, peak_eras: $peak_eras, summary_ai: $summary_ai)';
}


}

/// @nodoc
abstract mixin class $AnalysisResponseCopyWith<$Res>  {
  factory $AnalysisResponseCopyWith(AnalysisResponse value, $Res Function(AnalysisResponse) _then) = _$AnalysisResponseCopyWithImpl;
@useResult
$Res call({
 String location_name, List<EraScore> peak_eras, String summary_ai
});




}
/// @nodoc
class _$AnalysisResponseCopyWithImpl<$Res>
    implements $AnalysisResponseCopyWith<$Res> {
  _$AnalysisResponseCopyWithImpl(this._self, this._then);

  final AnalysisResponse _self;
  final $Res Function(AnalysisResponse) _then;

/// Create a copy of AnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location_name = null,Object? peak_eras = null,Object? summary_ai = null,}) {
  return _then(_self.copyWith(
location_name: null == location_name ? _self.location_name : location_name // ignore: cast_nullable_to_non_nullable
as String,peak_eras: null == peak_eras ? _self.peak_eras : peak_eras // ignore: cast_nullable_to_non_nullable
as List<EraScore>,summary_ai: null == summary_ai ? _self.summary_ai : summary_ai // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisResponse].
extension AnalysisResponsePatterns on AnalysisResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisResponse value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String location_name,  List<EraScore> peak_eras,  String summary_ai)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisResponse() when $default != null:
return $default(_that.location_name,_that.peak_eras,_that.summary_ai);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String location_name,  List<EraScore> peak_eras,  String summary_ai)  $default,) {final _that = this;
switch (_that) {
case _AnalysisResponse():
return $default(_that.location_name,_that.peak_eras,_that.summary_ai);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String location_name,  List<EraScore> peak_eras,  String summary_ai)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisResponse() when $default != null:
return $default(_that.location_name,_that.peak_eras,_that.summary_ai);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisResponse implements AnalysisResponse {
  const _AnalysisResponse({required this.location_name, required final  List<EraScore> peak_eras, required this.summary_ai}): _peak_eras = peak_eras;
  factory _AnalysisResponse.fromJson(Map<String, dynamic> json) => _$AnalysisResponseFromJson(json);

@override final  String location_name;
 final  List<EraScore> _peak_eras;
@override List<EraScore> get peak_eras {
  if (_peak_eras is EqualUnmodifiableListView) return _peak_eras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_peak_eras);
}

@override final  String summary_ai;

/// Create a copy of AnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisResponseCopyWith<_AnalysisResponse> get copyWith => __$AnalysisResponseCopyWithImpl<_AnalysisResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisResponse&&(identical(other.location_name, location_name) || other.location_name == location_name)&&const DeepCollectionEquality().equals(other._peak_eras, _peak_eras)&&(identical(other.summary_ai, summary_ai) || other.summary_ai == summary_ai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location_name,const DeepCollectionEquality().hash(_peak_eras),summary_ai);

@override
String toString() {
  return 'AnalysisResponse(location_name: $location_name, peak_eras: $peak_eras, summary_ai: $summary_ai)';
}


}

/// @nodoc
abstract mixin class _$AnalysisResponseCopyWith<$Res> implements $AnalysisResponseCopyWith<$Res> {
  factory _$AnalysisResponseCopyWith(_AnalysisResponse value, $Res Function(_AnalysisResponse) _then) = __$AnalysisResponseCopyWithImpl;
@override @useResult
$Res call({
 String location_name, List<EraScore> peak_eras, String summary_ai
});




}
/// @nodoc
class __$AnalysisResponseCopyWithImpl<$Res>
    implements _$AnalysisResponseCopyWith<$Res> {
  __$AnalysisResponseCopyWithImpl(this._self, this._then);

  final _AnalysisResponse _self;
  final $Res Function(_AnalysisResponse) _then;

/// Create a copy of AnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location_name = null,Object? peak_eras = null,Object? summary_ai = null,}) {
  return _then(_AnalysisResponse(
location_name: null == location_name ? _self.location_name : location_name // ignore: cast_nullable_to_non_nullable
as String,peak_eras: null == peak_eras ? _self._peak_eras : peak_eras // ignore: cast_nullable_to_non_nullable
as List<EraScore>,summary_ai: null == summary_ai ? _self.summary_ai : summary_ai // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
