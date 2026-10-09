// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_style.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimetableStyle implements DiagnosticableTreeMixin {

@JsonKey(name: 'seedColor') int get seedColorValue; double get dayWidth; double get cellHeight; double get fontScale;@_EnumFallback(CourseLineHeight.values) CourseLineHeight get lineHeight; double get headerHeight; double get periodColumnWidth; double get courseBlockGap; double get courseBlockRadius; double get courseHorizontalPadding; double get courseVerticalPadding;@_EnumFallback(CourseTextAlignment.values) CourseTextAlignment get courseTextAlignment; bool get showWeekend; bool get showPeriodColumn; bool get showWeekSelector; bool get showGrid; bool get showHeaderDate; bool get showPeriodEndTime; bool get highlightToday; bool get showCurrentTime;@_EnumFallback(CourseColorMode.values) CourseColorMode get colorMode;@_EnumFallback(CoursePaletteKind.values) CoursePaletteKind get palette;@_EnumFallback(CourseTextColor.values) CourseTextColor get textColor; Map<String, int> get courseColors; Map<String, String> get courseAliases; bool get showLocation; bool get showTeacher; bool get stripTeacherTitle; bool get splitLocation;@_EnumFallback(CourseNameStyle.values) CourseNameStyle get nameStyle;@_EnumFallback(AppThemeMode.values) AppThemeMode get themeMode; bool get oledBlack;
/// Create a copy of TimetableStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableStyleCopyWith<TimetableStyle> get copyWith => _$TimetableStyleCopyWithImpl<TimetableStyle>(this as TimetableStyle, _$identity);

  /// Serializes this TimetableStyle to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as TimetableStyle;
  properties
    ..add(DiagnosticsProperty('type', 'TimetableStyle'))
    ..add(DiagnosticsProperty('seedColorValue', _this.seedColorValue))..add(DiagnosticsProperty('dayWidth', _this.dayWidth))..add(DiagnosticsProperty('cellHeight', _this.cellHeight))..add(DiagnosticsProperty('fontScale', _this.fontScale))..add(DiagnosticsProperty('lineHeight', _this.lineHeight))..add(DiagnosticsProperty('headerHeight', _this.headerHeight))..add(DiagnosticsProperty('periodColumnWidth', _this.periodColumnWidth))..add(DiagnosticsProperty('courseBlockGap', _this.courseBlockGap))..add(DiagnosticsProperty('courseBlockRadius', _this.courseBlockRadius))..add(DiagnosticsProperty('courseHorizontalPadding', _this.courseHorizontalPadding))..add(DiagnosticsProperty('courseVerticalPadding', _this.courseVerticalPadding))..add(DiagnosticsProperty('courseTextAlignment', _this.courseTextAlignment))..add(DiagnosticsProperty('showWeekend', _this.showWeekend))..add(DiagnosticsProperty('showPeriodColumn', _this.showPeriodColumn))..add(DiagnosticsProperty('showWeekSelector', _this.showWeekSelector))..add(DiagnosticsProperty('showGrid', _this.showGrid))..add(DiagnosticsProperty('showHeaderDate', _this.showHeaderDate))..add(DiagnosticsProperty('showPeriodEndTime', _this.showPeriodEndTime))..add(DiagnosticsProperty('highlightToday', _this.highlightToday))..add(DiagnosticsProperty('showCurrentTime', _this.showCurrentTime))..add(DiagnosticsProperty('colorMode', _this.colorMode))..add(DiagnosticsProperty('palette', _this.palette))..add(DiagnosticsProperty('textColor', _this.textColor))..add(DiagnosticsProperty('courseColors', _this.courseColors))..add(DiagnosticsProperty('courseAliases', _this.courseAliases))..add(DiagnosticsProperty('showLocation', _this.showLocation))..add(DiagnosticsProperty('showTeacher', _this.showTeacher))..add(DiagnosticsProperty('stripTeacherTitle', _this.stripTeacherTitle))..add(DiagnosticsProperty('splitLocation', _this.splitLocation))..add(DiagnosticsProperty('nameStyle', _this.nameStyle))..add(DiagnosticsProperty('themeMode', _this.themeMode))..add(DiagnosticsProperty('oledBlack', _this.oledBlack));
}

@override
bool operator ==(Object other) {
  final _this = this as TimetableStyle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableStyle&&(identical(other.seedColorValue, _this.seedColorValue) || other.seedColorValue == _this.seedColorValue)&&(identical(other.dayWidth, _this.dayWidth) || other.dayWidth == _this.dayWidth)&&(identical(other.cellHeight, _this.cellHeight) || other.cellHeight == _this.cellHeight)&&(identical(other.fontScale, _this.fontScale) || other.fontScale == _this.fontScale)&&(identical(other.lineHeight, _this.lineHeight) || other.lineHeight == _this.lineHeight)&&(identical(other.headerHeight, _this.headerHeight) || other.headerHeight == _this.headerHeight)&&(identical(other.periodColumnWidth, _this.periodColumnWidth) || other.periodColumnWidth == _this.periodColumnWidth)&&(identical(other.courseBlockGap, _this.courseBlockGap) || other.courseBlockGap == _this.courseBlockGap)&&(identical(other.courseBlockRadius, _this.courseBlockRadius) || other.courseBlockRadius == _this.courseBlockRadius)&&(identical(other.courseHorizontalPadding, _this.courseHorizontalPadding) || other.courseHorizontalPadding == _this.courseHorizontalPadding)&&(identical(other.courseVerticalPadding, _this.courseVerticalPadding) || other.courseVerticalPadding == _this.courseVerticalPadding)&&(identical(other.courseTextAlignment, _this.courseTextAlignment) || other.courseTextAlignment == _this.courseTextAlignment)&&(identical(other.showWeekend, _this.showWeekend) || other.showWeekend == _this.showWeekend)&&(identical(other.showPeriodColumn, _this.showPeriodColumn) || other.showPeriodColumn == _this.showPeriodColumn)&&(identical(other.showWeekSelector, _this.showWeekSelector) || other.showWeekSelector == _this.showWeekSelector)&&(identical(other.showGrid, _this.showGrid) || other.showGrid == _this.showGrid)&&(identical(other.showHeaderDate, _this.showHeaderDate) || other.showHeaderDate == _this.showHeaderDate)&&(identical(other.showPeriodEndTime, _this.showPeriodEndTime) || other.showPeriodEndTime == _this.showPeriodEndTime)&&(identical(other.highlightToday, _this.highlightToday) || other.highlightToday == _this.highlightToday)&&(identical(other.showCurrentTime, _this.showCurrentTime) || other.showCurrentTime == _this.showCurrentTime)&&(identical(other.colorMode, _this.colorMode) || other.colorMode == _this.colorMode)&&(identical(other.palette, _this.palette) || other.palette == _this.palette)&&(identical(other.textColor, _this.textColor) || other.textColor == _this.textColor)&&const DeepCollectionEquality().equals(other.courseColors, _this.courseColors)&&const DeepCollectionEquality().equals(other.courseAliases, _this.courseAliases)&&(identical(other.showLocation, _this.showLocation) || other.showLocation == _this.showLocation)&&(identical(other.showTeacher, _this.showTeacher) || other.showTeacher == _this.showTeacher)&&(identical(other.stripTeacherTitle, _this.stripTeacherTitle) || other.stripTeacherTitle == _this.stripTeacherTitle)&&(identical(other.splitLocation, _this.splitLocation) || other.splitLocation == _this.splitLocation)&&(identical(other.nameStyle, _this.nameStyle) || other.nameStyle == _this.nameStyle)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.oledBlack, _this.oledBlack) || other.oledBlack == _this.oledBlack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimetableStyle;
  return Object.hashAll([runtimeType,_this.seedColorValue,_this.dayWidth,_this.cellHeight,_this.fontScale,_this.lineHeight,_this.headerHeight,_this.periodColumnWidth,_this.courseBlockGap,_this.courseBlockRadius,_this.courseHorizontalPadding,_this.courseVerticalPadding,_this.courseTextAlignment,_this.showWeekend,_this.showPeriodColumn,_this.showWeekSelector,_this.showGrid,_this.showHeaderDate,_this.showPeriodEndTime,_this.highlightToday,_this.showCurrentTime,_this.colorMode,_this.palette,_this.textColor,const DeepCollectionEquality().hash(_this.courseColors),const DeepCollectionEquality().hash(_this.courseAliases),_this.showLocation,_this.showTeacher,_this.stripTeacherTitle,_this.splitLocation,_this.nameStyle,_this.themeMode,_this.oledBlack]);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as TimetableStyle;
  return 'TimetableStyle(seedColorValue: ${_this.seedColorValue}, dayWidth: ${_this.dayWidth}, cellHeight: ${_this.cellHeight}, fontScale: ${_this.fontScale}, lineHeight: ${_this.lineHeight}, headerHeight: ${_this.headerHeight}, periodColumnWidth: ${_this.periodColumnWidth}, courseBlockGap: ${_this.courseBlockGap}, courseBlockRadius: ${_this.courseBlockRadius}, courseHorizontalPadding: ${_this.courseHorizontalPadding}, courseVerticalPadding: ${_this.courseVerticalPadding}, courseTextAlignment: ${_this.courseTextAlignment}, showWeekend: ${_this.showWeekend}, showPeriodColumn: ${_this.showPeriodColumn}, showWeekSelector: ${_this.showWeekSelector}, showGrid: ${_this.showGrid}, showHeaderDate: ${_this.showHeaderDate}, showPeriodEndTime: ${_this.showPeriodEndTime}, highlightToday: ${_this.highlightToday}, showCurrentTime: ${_this.showCurrentTime}, colorMode: ${_this.colorMode}, palette: ${_this.palette}, textColor: ${_this.textColor}, courseColors: ${_this.courseColors}, courseAliases: ${_this.courseAliases}, showLocation: ${_this.showLocation}, showTeacher: ${_this.showTeacher}, stripTeacherTitle: ${_this.stripTeacherTitle}, splitLocation: ${_this.splitLocation}, nameStyle: ${_this.nameStyle}, themeMode: ${_this.themeMode}, oledBlack: ${_this.oledBlack})';
}


}

/// @nodoc
abstract mixin class $TimetableStyleCopyWith<$Res>  {
  factory $TimetableStyleCopyWith(TimetableStyle value, $Res Function(TimetableStyle) _then) = _$TimetableStyleCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'seedColor') int seedColorValue, double dayWidth, double cellHeight, double fontScale,@_EnumFallback(CourseLineHeight.values) CourseLineHeight lineHeight, double headerHeight, double periodColumnWidth, double courseBlockGap, double courseBlockRadius, double courseHorizontalPadding, double courseVerticalPadding,@_EnumFallback(CourseTextAlignment.values) CourseTextAlignment courseTextAlignment, bool showWeekend, bool showPeriodColumn, bool showWeekSelector, bool showGrid, bool showHeaderDate, bool showPeriodEndTime, bool highlightToday, bool showCurrentTime,@_EnumFallback(CourseColorMode.values) CourseColorMode colorMode,@_EnumFallback(CoursePaletteKind.values) CoursePaletteKind palette,@_EnumFallback(CourseTextColor.values) CourseTextColor textColor, Map<String, int> courseColors, Map<String, String> courseAliases, bool showLocation, bool showTeacher, bool stripTeacherTitle, bool splitLocation,@_EnumFallback(CourseNameStyle.values) CourseNameStyle nameStyle,@_EnumFallback(AppThemeMode.values) AppThemeMode themeMode, bool oledBlack
});




}
/// @nodoc
class _$TimetableStyleCopyWithImpl<$Res>
    implements $TimetableStyleCopyWith<$Res> {
  _$TimetableStyleCopyWithImpl(this._self, this._then);

  final TimetableStyle _self;
  final $Res Function(TimetableStyle) _then;

/// Create a copy of TimetableStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seedColorValue = null,Object? dayWidth = null,Object? cellHeight = null,Object? fontScale = null,Object? lineHeight = null,Object? headerHeight = null,Object? periodColumnWidth = null,Object? courseBlockGap = null,Object? courseBlockRadius = null,Object? courseHorizontalPadding = null,Object? courseVerticalPadding = null,Object? courseTextAlignment = null,Object? showWeekend = null,Object? showPeriodColumn = null,Object? showWeekSelector = null,Object? showGrid = null,Object? showHeaderDate = null,Object? showPeriodEndTime = null,Object? highlightToday = null,Object? showCurrentTime = null,Object? colorMode = null,Object? palette = null,Object? textColor = null,Object? courseColors = null,Object? courseAliases = null,Object? showLocation = null,Object? showTeacher = null,Object? stripTeacherTitle = null,Object? splitLocation = null,Object? nameStyle = null,Object? themeMode = null,Object? oledBlack = null,}) {
  return _then(TimetableStyle(
seedColorValue: null == seedColorValue ? _self.seedColorValue : seedColorValue // ignore: cast_nullable_to_non_nullable
as int,dayWidth: null == dayWidth ? _self.dayWidth : dayWidth // ignore: cast_nullable_to_non_nullable
as double,cellHeight: null == cellHeight ? _self.cellHeight : cellHeight // ignore: cast_nullable_to_non_nullable
as double,fontScale: null == fontScale ? _self.fontScale : fontScale // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as CourseLineHeight,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as double,periodColumnWidth: null == periodColumnWidth ? _self.periodColumnWidth : periodColumnWidth // ignore: cast_nullable_to_non_nullable
as double,courseBlockGap: null == courseBlockGap ? _self.courseBlockGap : courseBlockGap // ignore: cast_nullable_to_non_nullable
as double,courseBlockRadius: null == courseBlockRadius ? _self.courseBlockRadius : courseBlockRadius // ignore: cast_nullable_to_non_nullable
as double,courseHorizontalPadding: null == courseHorizontalPadding ? _self.courseHorizontalPadding : courseHorizontalPadding // ignore: cast_nullable_to_non_nullable
as double,courseVerticalPadding: null == courseVerticalPadding ? _self.courseVerticalPadding : courseVerticalPadding // ignore: cast_nullable_to_non_nullable
as double,courseTextAlignment: null == courseTextAlignment ? _self.courseTextAlignment : courseTextAlignment // ignore: cast_nullable_to_non_nullable
as CourseTextAlignment,showWeekend: null == showWeekend ? _self.showWeekend : showWeekend // ignore: cast_nullable_to_non_nullable
as bool,showPeriodColumn: null == showPeriodColumn ? _self.showPeriodColumn : showPeriodColumn // ignore: cast_nullable_to_non_nullable
as bool,showWeekSelector: null == showWeekSelector ? _self.showWeekSelector : showWeekSelector // ignore: cast_nullable_to_non_nullable
as bool,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,showHeaderDate: null == showHeaderDate ? _self.showHeaderDate : showHeaderDate // ignore: cast_nullable_to_non_nullable
as bool,showPeriodEndTime: null == showPeriodEndTime ? _self.showPeriodEndTime : showPeriodEndTime // ignore: cast_nullable_to_non_nullable
as bool,highlightToday: null == highlightToday ? _self.highlightToday : highlightToday // ignore: cast_nullable_to_non_nullable
as bool,showCurrentTime: null == showCurrentTime ? _self.showCurrentTime : showCurrentTime // ignore: cast_nullable_to_non_nullable
as bool,colorMode: null == colorMode ? _self.colorMode : colorMode // ignore: cast_nullable_to_non_nullable
as CourseColorMode,palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as CoursePaletteKind,textColor: null == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as CourseTextColor,courseColors: null == courseColors ? _self.courseColors : courseColors // ignore: cast_nullable_to_non_nullable
as Map<String, int>,courseAliases: null == courseAliases ? _self.courseAliases : courseAliases // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showLocation: null == showLocation ? _self.showLocation : showLocation // ignore: cast_nullable_to_non_nullable
as bool,showTeacher: null == showTeacher ? _self.showTeacher : showTeacher // ignore: cast_nullable_to_non_nullable
as bool,stripTeacherTitle: null == stripTeacherTitle ? _self.stripTeacherTitle : stripTeacherTitle // ignore: cast_nullable_to_non_nullable
as bool,splitLocation: null == splitLocation ? _self.splitLocation : splitLocation // ignore: cast_nullable_to_non_nullable
as bool,nameStyle: null == nameStyle ? _self.nameStyle : nameStyle // ignore: cast_nullable_to_non_nullable
as CourseNameStyle,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,oledBlack: null == oledBlack ? _self.oledBlack : oledBlack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TimetableStyle].
extension TimetableStylePatterns on TimetableStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimetableStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimetableStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimetableStyle value)  $default,){
final _that = this;
switch (_that) {
case _TimetableStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimetableStyle value)?  $default,){
final _that = this;
switch (_that) {
case _TimetableStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'seedColor')  int seedColorValue,  double dayWidth,  double cellHeight,  double fontScale, @_EnumFallback(CourseLineHeight.values)  CourseLineHeight lineHeight,  double headerHeight,  double periodColumnWidth,  double courseBlockGap,  double courseBlockRadius,  double courseHorizontalPadding,  double courseVerticalPadding, @_EnumFallback(CourseTextAlignment.values)  CourseTextAlignment courseTextAlignment,  bool showWeekend,  bool showPeriodColumn,  bool showWeekSelector,  bool showGrid,  bool showHeaderDate,  bool showPeriodEndTime,  bool highlightToday,  bool showCurrentTime, @_EnumFallback(CourseColorMode.values)  CourseColorMode colorMode, @_EnumFallback(CoursePaletteKind.values)  CoursePaletteKind palette, @_EnumFallback(CourseTextColor.values)  CourseTextColor textColor,  Map<String, int> courseColors,  Map<String, String> courseAliases,  bool showLocation,  bool showTeacher,  bool stripTeacherTitle,  bool splitLocation, @_EnumFallback(CourseNameStyle.values)  CourseNameStyle nameStyle, @_EnumFallback(AppThemeMode.values)  AppThemeMode themeMode,  bool oledBlack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimetableStyle() when $default != null:
return $default(_that.seedColorValue,_that.dayWidth,_that.cellHeight,_that.fontScale,_that.lineHeight,_that.headerHeight,_that.periodColumnWidth,_that.courseBlockGap,_that.courseBlockRadius,_that.courseHorizontalPadding,_that.courseVerticalPadding,_that.courseTextAlignment,_that.showWeekend,_that.showPeriodColumn,_that.showWeekSelector,_that.showGrid,_that.showHeaderDate,_that.showPeriodEndTime,_that.highlightToday,_that.showCurrentTime,_that.colorMode,_that.palette,_that.textColor,_that.courseColors,_that.courseAliases,_that.showLocation,_that.showTeacher,_that.stripTeacherTitle,_that.splitLocation,_that.nameStyle,_that.themeMode,_that.oledBlack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'seedColor')  int seedColorValue,  double dayWidth,  double cellHeight,  double fontScale, @_EnumFallback(CourseLineHeight.values)  CourseLineHeight lineHeight,  double headerHeight,  double periodColumnWidth,  double courseBlockGap,  double courseBlockRadius,  double courseHorizontalPadding,  double courseVerticalPadding, @_EnumFallback(CourseTextAlignment.values)  CourseTextAlignment courseTextAlignment,  bool showWeekend,  bool showPeriodColumn,  bool showWeekSelector,  bool showGrid,  bool showHeaderDate,  bool showPeriodEndTime,  bool highlightToday,  bool showCurrentTime, @_EnumFallback(CourseColorMode.values)  CourseColorMode colorMode, @_EnumFallback(CoursePaletteKind.values)  CoursePaletteKind palette, @_EnumFallback(CourseTextColor.values)  CourseTextColor textColor,  Map<String, int> courseColors,  Map<String, String> courseAliases,  bool showLocation,  bool showTeacher,  bool stripTeacherTitle,  bool splitLocation, @_EnumFallback(CourseNameStyle.values)  CourseNameStyle nameStyle, @_EnumFallback(AppThemeMode.values)  AppThemeMode themeMode,  bool oledBlack)  $default,) {final _that = this;
switch (_that) {
case _TimetableStyle():
return $default(_that.seedColorValue,_that.dayWidth,_that.cellHeight,_that.fontScale,_that.lineHeight,_that.headerHeight,_that.periodColumnWidth,_that.courseBlockGap,_that.courseBlockRadius,_that.courseHorizontalPadding,_that.courseVerticalPadding,_that.courseTextAlignment,_that.showWeekend,_that.showPeriodColumn,_that.showWeekSelector,_that.showGrid,_that.showHeaderDate,_that.showPeriodEndTime,_that.highlightToday,_that.showCurrentTime,_that.colorMode,_that.palette,_that.textColor,_that.courseColors,_that.courseAliases,_that.showLocation,_that.showTeacher,_that.stripTeacherTitle,_that.splitLocation,_that.nameStyle,_that.themeMode,_that.oledBlack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'seedColor')  int seedColorValue,  double dayWidth,  double cellHeight,  double fontScale, @_EnumFallback(CourseLineHeight.values)  CourseLineHeight lineHeight,  double headerHeight,  double periodColumnWidth,  double courseBlockGap,  double courseBlockRadius,  double courseHorizontalPadding,  double courseVerticalPadding, @_EnumFallback(CourseTextAlignment.values)  CourseTextAlignment courseTextAlignment,  bool showWeekend,  bool showPeriodColumn,  bool showWeekSelector,  bool showGrid,  bool showHeaderDate,  bool showPeriodEndTime,  bool highlightToday,  bool showCurrentTime, @_EnumFallback(CourseColorMode.values)  CourseColorMode colorMode, @_EnumFallback(CoursePaletteKind.values)  CoursePaletteKind palette, @_EnumFallback(CourseTextColor.values)  CourseTextColor textColor,  Map<String, int> courseColors,  Map<String, String> courseAliases,  bool showLocation,  bool showTeacher,  bool stripTeacherTitle,  bool splitLocation, @_EnumFallback(CourseNameStyle.values)  CourseNameStyle nameStyle, @_EnumFallback(AppThemeMode.values)  AppThemeMode themeMode,  bool oledBlack)?  $default,) {final _that = this;
switch (_that) {
case _TimetableStyle() when $default != null:
return $default(_that.seedColorValue,_that.dayWidth,_that.cellHeight,_that.fontScale,_that.lineHeight,_that.headerHeight,_that.periodColumnWidth,_that.courseBlockGap,_that.courseBlockRadius,_that.courseHorizontalPadding,_that.courseVerticalPadding,_that.courseTextAlignment,_that.showWeekend,_that.showPeriodColumn,_that.showWeekSelector,_that.showGrid,_that.showHeaderDate,_that.showPeriodEndTime,_that.highlightToday,_that.showCurrentTime,_that.colorMode,_that.palette,_that.textColor,_that.courseColors,_that.courseAliases,_that.showLocation,_that.showTeacher,_that.stripTeacherTitle,_that.splitLocation,_that.nameStyle,_that.themeMode,_that.oledBlack);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimetableStyle extends TimetableStyle with DiagnosticableTreeMixin {
  const _TimetableStyle({@JsonKey(name: 'seedColor') this.seedColorValue = TimetableStyle.defaultSeedColor, this.dayWidth = TimetableStyle.defaultDayWidth, this.cellHeight = 0, this.fontScale = 1, @_EnumFallback(CourseLineHeight.values) this.lineHeight = CourseLineHeight.standard, this.headerHeight = TimetableStyle.defaultHeaderHeight, this.periodColumnWidth = TimetableStyle.defaultPeriodColumnWidth, this.courseBlockGap = TimetableStyle.defaultCourseBlockGap, this.courseBlockRadius = TimetableStyle.defaultCourseBlockRadius, this.courseHorizontalPadding = TimetableStyle.defaultCourseHorizontalPadding, this.courseVerticalPadding = TimetableStyle.defaultCourseVerticalPadding, @_EnumFallback(CourseTextAlignment.values) this.courseTextAlignment = CourseTextAlignment.left, this.showWeekend = true, this.showPeriodColumn = true, this.showWeekSelector = true, this.showGrid = true, this.showHeaderDate = true, this.showPeriodEndTime = true, this.highlightToday = true, this.showCurrentTime = true, @_EnumFallback(CourseColorMode.values) this.colorMode = CourseColorMode.theme, @_EnumFallback(CoursePaletteKind.values) this.palette = CoursePaletteKind.morandi, @_EnumFallback(CourseTextColor.values) this.textColor = CourseTextColor.auto,  Map<String, int> courseColors = const <String, int>{},  Map<String, String> courseAliases = const <String, String>{}, this.showLocation = true, this.showTeacher = false, this.stripTeacherTitle = true, this.splitLocation = true, @_EnumFallback(CourseNameStyle.values) this.nameStyle = CourseNameStyle.full, @_EnumFallback(AppThemeMode.values) this.themeMode = AppThemeMode.system, this.oledBlack = false}): _courseColors = courseColors,_courseAliases = courseAliases,super._();
  factory _TimetableStyle.fromJson(Map<String, dynamic> json) => _$TimetableStyleFromJson(json);

@override@JsonKey(name: 'seedColor') final  int seedColorValue;
@override@JsonKey() final  double dayWidth;
@override@JsonKey() final  double cellHeight;
@override@JsonKey() final  double fontScale;
@override@JsonKey()@_EnumFallback(CourseLineHeight.values) final  CourseLineHeight lineHeight;
@override@JsonKey() final  double headerHeight;
@override@JsonKey() final  double periodColumnWidth;
@override@JsonKey() final  double courseBlockGap;
@override@JsonKey() final  double courseBlockRadius;
@override@JsonKey() final  double courseHorizontalPadding;
@override@JsonKey() final  double courseVerticalPadding;
@override@JsonKey()@_EnumFallback(CourseTextAlignment.values) final  CourseTextAlignment courseTextAlignment;
@override@JsonKey() final  bool showWeekend;
@override@JsonKey() final  bool showPeriodColumn;
@override@JsonKey() final  bool showWeekSelector;
@override@JsonKey() final  bool showGrid;
@override@JsonKey() final  bool showHeaderDate;
@override@JsonKey() final  bool showPeriodEndTime;
@override@JsonKey() final  bool highlightToday;
@override@JsonKey() final  bool showCurrentTime;
@override@JsonKey()@_EnumFallback(CourseColorMode.values) final  CourseColorMode colorMode;
@override@JsonKey()@_EnumFallback(CoursePaletteKind.values) final  CoursePaletteKind palette;
@override@JsonKey()@_EnumFallback(CourseTextColor.values) final  CourseTextColor textColor;
 final  Map<String, int> _courseColors;
@override@JsonKey() Map<String, int> get courseColors {
  if (_courseColors is EqualUnmodifiableMapView) return _courseColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_courseColors);
}

 final  Map<String, String> _courseAliases;
@override@JsonKey() Map<String, String> get courseAliases {
  if (_courseAliases is EqualUnmodifiableMapView) return _courseAliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_courseAliases);
}

@override@JsonKey() final  bool showLocation;
@override@JsonKey() final  bool showTeacher;
@override@JsonKey() final  bool stripTeacherTitle;
@override@JsonKey() final  bool splitLocation;
@override@JsonKey()@_EnumFallback(CourseNameStyle.values) final  CourseNameStyle nameStyle;
@override@JsonKey()@_EnumFallback(AppThemeMode.values) final  AppThemeMode themeMode;
@override@JsonKey() final  bool oledBlack;

/// Create a copy of TimetableStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimetableStyleCopyWith<_TimetableStyle> get copyWith => __$TimetableStyleCopyWithImpl<_TimetableStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimetableStyleToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'TimetableStyle'))
    ..add(DiagnosticsProperty('seedColorValue', seedColorValue))..add(DiagnosticsProperty('dayWidth', dayWidth))..add(DiagnosticsProperty('cellHeight', cellHeight))..add(DiagnosticsProperty('fontScale', fontScale))..add(DiagnosticsProperty('lineHeight', lineHeight))..add(DiagnosticsProperty('headerHeight', headerHeight))..add(DiagnosticsProperty('periodColumnWidth', periodColumnWidth))..add(DiagnosticsProperty('courseBlockGap', courseBlockGap))..add(DiagnosticsProperty('courseBlockRadius', courseBlockRadius))..add(DiagnosticsProperty('courseHorizontalPadding', courseHorizontalPadding))..add(DiagnosticsProperty('courseVerticalPadding', courseVerticalPadding))..add(DiagnosticsProperty('courseTextAlignment', courseTextAlignment))..add(DiagnosticsProperty('showWeekend', showWeekend))..add(DiagnosticsProperty('showPeriodColumn', showPeriodColumn))..add(DiagnosticsProperty('showWeekSelector', showWeekSelector))..add(DiagnosticsProperty('showGrid', showGrid))..add(DiagnosticsProperty('showHeaderDate', showHeaderDate))..add(DiagnosticsProperty('showPeriodEndTime', showPeriodEndTime))..add(DiagnosticsProperty('highlightToday', highlightToday))..add(DiagnosticsProperty('showCurrentTime', showCurrentTime))..add(DiagnosticsProperty('colorMode', colorMode))..add(DiagnosticsProperty('palette', palette))..add(DiagnosticsProperty('textColor', textColor))..add(DiagnosticsProperty('courseColors', courseColors))..add(DiagnosticsProperty('courseAliases', courseAliases))..add(DiagnosticsProperty('showLocation', showLocation))..add(DiagnosticsProperty('showTeacher', showTeacher))..add(DiagnosticsProperty('stripTeacherTitle', stripTeacherTitle))..add(DiagnosticsProperty('splitLocation', splitLocation))..add(DiagnosticsProperty('nameStyle', nameStyle))..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('oledBlack', oledBlack));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimetableStyle&&(identical(other.seedColorValue, seedColorValue) || other.seedColorValue == seedColorValue)&&(identical(other.dayWidth, dayWidth) || other.dayWidth == dayWidth)&&(identical(other.cellHeight, cellHeight) || other.cellHeight == cellHeight)&&(identical(other.fontScale, fontScale) || other.fontScale == fontScale)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.headerHeight, headerHeight) || other.headerHeight == headerHeight)&&(identical(other.periodColumnWidth, periodColumnWidth) || other.periodColumnWidth == periodColumnWidth)&&(identical(other.courseBlockGap, courseBlockGap) || other.courseBlockGap == courseBlockGap)&&(identical(other.courseBlockRadius, courseBlockRadius) || other.courseBlockRadius == courseBlockRadius)&&(identical(other.courseHorizontalPadding, courseHorizontalPadding) || other.courseHorizontalPadding == courseHorizontalPadding)&&(identical(other.courseVerticalPadding, courseVerticalPadding) || other.courseVerticalPadding == courseVerticalPadding)&&(identical(other.courseTextAlignment, courseTextAlignment) || other.courseTextAlignment == courseTextAlignment)&&(identical(other.showWeekend, showWeekend) || other.showWeekend == showWeekend)&&(identical(other.showPeriodColumn, showPeriodColumn) || other.showPeriodColumn == showPeriodColumn)&&(identical(other.showWeekSelector, showWeekSelector) || other.showWeekSelector == showWeekSelector)&&(identical(other.showGrid, showGrid) || other.showGrid == showGrid)&&(identical(other.showHeaderDate, showHeaderDate) || other.showHeaderDate == showHeaderDate)&&(identical(other.showPeriodEndTime, showPeriodEndTime) || other.showPeriodEndTime == showPeriodEndTime)&&(identical(other.highlightToday, highlightToday) || other.highlightToday == highlightToday)&&(identical(other.showCurrentTime, showCurrentTime) || other.showCurrentTime == showCurrentTime)&&(identical(other.colorMode, colorMode) || other.colorMode == colorMode)&&(identical(other.palette, palette) || other.palette == palette)&&(identical(other.textColor, textColor) || other.textColor == textColor)&&const DeepCollectionEquality().equals(other.courseColors, _courseColors)&&const DeepCollectionEquality().equals(other.courseAliases, _courseAliases)&&(identical(other.showLocation, showLocation) || other.showLocation == showLocation)&&(identical(other.showTeacher, showTeacher) || other.showTeacher == showTeacher)&&(identical(other.stripTeacherTitle, stripTeacherTitle) || other.stripTeacherTitle == stripTeacherTitle)&&(identical(other.splitLocation, splitLocation) || other.splitLocation == splitLocation)&&(identical(other.nameStyle, nameStyle) || other.nameStyle == nameStyle)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.oledBlack, oledBlack) || other.oledBlack == oledBlack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,seedColorValue,dayWidth,cellHeight,fontScale,lineHeight,headerHeight,periodColumnWidth,courseBlockGap,courseBlockRadius,courseHorizontalPadding,courseVerticalPadding,courseTextAlignment,showWeekend,showPeriodColumn,showWeekSelector,showGrid,showHeaderDate,showPeriodEndTime,highlightToday,showCurrentTime,colorMode,palette,textColor,const DeepCollectionEquality().hash(_courseColors),const DeepCollectionEquality().hash(_courseAliases),showLocation,showTeacher,stripTeacherTitle,splitLocation,nameStyle,themeMode,oledBlack]);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'TimetableStyle(seedColorValue: $seedColorValue, dayWidth: $dayWidth, cellHeight: $cellHeight, fontScale: $fontScale, lineHeight: $lineHeight, headerHeight: $headerHeight, periodColumnWidth: $periodColumnWidth, courseBlockGap: $courseBlockGap, courseBlockRadius: $courseBlockRadius, courseHorizontalPadding: $courseHorizontalPadding, courseVerticalPadding: $courseVerticalPadding, courseTextAlignment: $courseTextAlignment, showWeekend: $showWeekend, showPeriodColumn: $showPeriodColumn, showWeekSelector: $showWeekSelector, showGrid: $showGrid, showHeaderDate: $showHeaderDate, showPeriodEndTime: $showPeriodEndTime, highlightToday: $highlightToday, showCurrentTime: $showCurrentTime, colorMode: $colorMode, palette: $palette, textColor: $textColor, courseColors: $courseColors, courseAliases: $courseAliases, showLocation: $showLocation, showTeacher: $showTeacher, stripTeacherTitle: $stripTeacherTitle, splitLocation: $splitLocation, nameStyle: $nameStyle, themeMode: $themeMode, oledBlack: $oledBlack)';
}


}

/// @nodoc
abstract mixin class _$TimetableStyleCopyWith<$Res> implements $TimetableStyleCopyWith<$Res> {
  factory _$TimetableStyleCopyWith(_TimetableStyle value, $Res Function(_TimetableStyle) _then) = __$TimetableStyleCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'seedColor') int seedColorValue, double dayWidth, double cellHeight, double fontScale,@_EnumFallback(CourseLineHeight.values) CourseLineHeight lineHeight, double headerHeight, double periodColumnWidth, double courseBlockGap, double courseBlockRadius, double courseHorizontalPadding, double courseVerticalPadding,@_EnumFallback(CourseTextAlignment.values) CourseTextAlignment courseTextAlignment, bool showWeekend, bool showPeriodColumn, bool showWeekSelector, bool showGrid, bool showHeaderDate, bool showPeriodEndTime, bool highlightToday, bool showCurrentTime,@_EnumFallback(CourseColorMode.values) CourseColorMode colorMode,@_EnumFallback(CoursePaletteKind.values) CoursePaletteKind palette,@_EnumFallback(CourseTextColor.values) CourseTextColor textColor, Map<String, int> courseColors, Map<String, String> courseAliases, bool showLocation, bool showTeacher, bool stripTeacherTitle, bool splitLocation,@_EnumFallback(CourseNameStyle.values) CourseNameStyle nameStyle,@_EnumFallback(AppThemeMode.values) AppThemeMode themeMode, bool oledBlack
});




}
/// @nodoc
class __$TimetableStyleCopyWithImpl<$Res>
    implements _$TimetableStyleCopyWith<$Res> {
  __$TimetableStyleCopyWithImpl(this._self, this._then);

  final _TimetableStyle _self;
  final $Res Function(_TimetableStyle) _then;

/// Create a copy of TimetableStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seedColorValue = null,Object? dayWidth = null,Object? cellHeight = null,Object? fontScale = null,Object? lineHeight = null,Object? headerHeight = null,Object? periodColumnWidth = null,Object? courseBlockGap = null,Object? courseBlockRadius = null,Object? courseHorizontalPadding = null,Object? courseVerticalPadding = null,Object? courseTextAlignment = null,Object? showWeekend = null,Object? showPeriodColumn = null,Object? showWeekSelector = null,Object? showGrid = null,Object? showHeaderDate = null,Object? showPeriodEndTime = null,Object? highlightToday = null,Object? showCurrentTime = null,Object? colorMode = null,Object? palette = null,Object? textColor = null,Object? courseColors = null,Object? courseAliases = null,Object? showLocation = null,Object? showTeacher = null,Object? stripTeacherTitle = null,Object? splitLocation = null,Object? nameStyle = null,Object? themeMode = null,Object? oledBlack = null,}) {
  return _then(_TimetableStyle(
seedColorValue: null == seedColorValue ? _self.seedColorValue : seedColorValue // ignore: cast_nullable_to_non_nullable
as int,dayWidth: null == dayWidth ? _self.dayWidth : dayWidth // ignore: cast_nullable_to_non_nullable
as double,cellHeight: null == cellHeight ? _self.cellHeight : cellHeight // ignore: cast_nullable_to_non_nullable
as double,fontScale: null == fontScale ? _self.fontScale : fontScale // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as CourseLineHeight,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as double,periodColumnWidth: null == periodColumnWidth ? _self.periodColumnWidth : periodColumnWidth // ignore: cast_nullable_to_non_nullable
as double,courseBlockGap: null == courseBlockGap ? _self.courseBlockGap : courseBlockGap // ignore: cast_nullable_to_non_nullable
as double,courseBlockRadius: null == courseBlockRadius ? _self.courseBlockRadius : courseBlockRadius // ignore: cast_nullable_to_non_nullable
as double,courseHorizontalPadding: null == courseHorizontalPadding ? _self.courseHorizontalPadding : courseHorizontalPadding // ignore: cast_nullable_to_non_nullable
as double,courseVerticalPadding: null == courseVerticalPadding ? _self.courseVerticalPadding : courseVerticalPadding // ignore: cast_nullable_to_non_nullable
as double,courseTextAlignment: null == courseTextAlignment ? _self.courseTextAlignment : courseTextAlignment // ignore: cast_nullable_to_non_nullable
as CourseTextAlignment,showWeekend: null == showWeekend ? _self.showWeekend : showWeekend // ignore: cast_nullable_to_non_nullable
as bool,showPeriodColumn: null == showPeriodColumn ? _self.showPeriodColumn : showPeriodColumn // ignore: cast_nullable_to_non_nullable
as bool,showWeekSelector: null == showWeekSelector ? _self.showWeekSelector : showWeekSelector // ignore: cast_nullable_to_non_nullable
as bool,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,showHeaderDate: null == showHeaderDate ? _self.showHeaderDate : showHeaderDate // ignore: cast_nullable_to_non_nullable
as bool,showPeriodEndTime: null == showPeriodEndTime ? _self.showPeriodEndTime : showPeriodEndTime // ignore: cast_nullable_to_non_nullable
as bool,highlightToday: null == highlightToday ? _self.highlightToday : highlightToday // ignore: cast_nullable_to_non_nullable
as bool,showCurrentTime: null == showCurrentTime ? _self.showCurrentTime : showCurrentTime // ignore: cast_nullable_to_non_nullable
as bool,colorMode: null == colorMode ? _self.colorMode : colorMode // ignore: cast_nullable_to_non_nullable
as CourseColorMode,palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as CoursePaletteKind,textColor: null == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as CourseTextColor,courseColors: null == courseColors ? _self._courseColors : courseColors // ignore: cast_nullable_to_non_nullable
as Map<String, int>,courseAliases: null == courseAliases ? _self._courseAliases : courseAliases // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showLocation: null == showLocation ? _self.showLocation : showLocation // ignore: cast_nullable_to_non_nullable
as bool,showTeacher: null == showTeacher ? _self.showTeacher : showTeacher // ignore: cast_nullable_to_non_nullable
as bool,stripTeacherTitle: null == stripTeacherTitle ? _self.stripTeacherTitle : stripTeacherTitle // ignore: cast_nullable_to_non_nullable
as bool,splitLocation: null == splitLocation ? _self.splitLocation : splitLocation // ignore: cast_nullable_to_non_nullable
as bool,nameStyle: null == nameStyle ? _self.nameStyle : nameStyle // ignore: cast_nullable_to_non_nullable
as CourseNameStyle,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,oledBlack: null == oledBlack ? _self.oledBlack : oledBlack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
