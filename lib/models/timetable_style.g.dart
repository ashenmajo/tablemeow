// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimetableStyle _$TimetableStyleFromJson(
  Map<String, dynamic> json,
) => _TimetableStyle(
  seedColorValue:
      (json['seedColor'] as num?)?.toInt() ?? TimetableStyle.defaultSeedColor,
  dayWidth:
      (json['dayWidth'] as num?)?.toDouble() ?? TimetableStyle.defaultDayWidth,
  cellHeight: (json['cellHeight'] as num?)?.toDouble() ?? 0,
  fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1,
  lineHeight:
      $enumDecodeNullable(_$CourseLineHeightEnumMap, json['lineHeight']) ??
      CourseLineHeight.standard,
  headerHeight:
      (json['headerHeight'] as num?)?.toDouble() ??
      TimetableStyle.defaultHeaderHeight,
  periodColumnWidth:
      (json['periodColumnWidth'] as num?)?.toDouble() ??
      TimetableStyle.defaultPeriodColumnWidth,
  courseBlockGap:
      (json['courseBlockGap'] as num?)?.toDouble() ??
      TimetableStyle.defaultCourseBlockGap,
  courseBlockRadius:
      (json['courseBlockRadius'] as num?)?.toDouble() ??
      TimetableStyle.defaultCourseBlockRadius,
  courseHorizontalPadding:
      (json['courseHorizontalPadding'] as num?)?.toDouble() ??
      TimetableStyle.defaultCourseHorizontalPadding,
  courseVerticalPadding:
      (json['courseVerticalPadding'] as num?)?.toDouble() ??
      TimetableStyle.defaultCourseVerticalPadding,
  courseTextAlignment:
      $enumDecodeNullable(
        _$CourseTextAlignmentEnumMap,
        json['courseTextAlignment'],
      ) ??
      CourseTextAlignment.left,
  showWeekend: json['showWeekend'] as bool? ?? true,
  showPeriodColumn: json['showPeriodColumn'] as bool? ?? true,
  showWeekSelector: json['showWeekSelector'] as bool? ?? true,
  showGrid: json['showGrid'] as bool? ?? true,
  showHeaderDate: json['showHeaderDate'] as bool? ?? true,
  showPeriodEndTime: json['showPeriodEndTime'] as bool? ?? true,
  highlightToday: json['highlightToday'] as bool? ?? true,
  showCurrentTime: json['showCurrentTime'] as bool? ?? true,
  colorMode:
      $enumDecodeNullable(_$CourseColorModeEnumMap, json['colorMode']) ??
      CourseColorMode.theme,
  palette:
      $enumDecodeNullable(_$CoursePaletteKindEnumMap, json['palette']) ??
      CoursePaletteKind.morandi,
  textColor:
      $enumDecodeNullable(_$CourseTextColorEnumMap, json['textColor']) ??
      CourseTextColor.auto,
  courseColors:
      (json['courseColors'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  courseAliases:
      (json['courseAliases'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  showLocation: json['showLocation'] as bool? ?? true,
  showTeacher: json['showTeacher'] as bool? ?? false,
  stripTeacherTitle: json['stripTeacherTitle'] as bool? ?? true,
  splitLocation: json['splitLocation'] as bool? ?? true,
  nameStyle:
      $enumDecodeNullable(_$CourseNameStyleEnumMap, json['nameStyle']) ??
      CourseNameStyle.full,
  themeMode:
      $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
      AppThemeMode.system,
  oledBlack: json['oledBlack'] as bool? ?? false,
);

Map<String, dynamic> _$TimetableStyleToJson(_TimetableStyle instance) =>
    <String, dynamic>{
      'seedColor': instance.seedColorValue,
      'dayWidth': instance.dayWidth,
      'cellHeight': instance.cellHeight,
      'fontScale': instance.fontScale,
      'lineHeight': _$CourseLineHeightEnumMap[instance.lineHeight]!,
      'headerHeight': instance.headerHeight,
      'periodColumnWidth': instance.periodColumnWidth,
      'courseBlockGap': instance.courseBlockGap,
      'courseBlockRadius': instance.courseBlockRadius,
      'courseHorizontalPadding': instance.courseHorizontalPadding,
      'courseVerticalPadding': instance.courseVerticalPadding,
      'courseTextAlignment':
          _$CourseTextAlignmentEnumMap[instance.courseTextAlignment]!,
      'showWeekend': instance.showWeekend,
      'showPeriodColumn': instance.showPeriodColumn,
      'showWeekSelector': instance.showWeekSelector,
      'showGrid': instance.showGrid,
      'showHeaderDate': instance.showHeaderDate,
      'showPeriodEndTime': instance.showPeriodEndTime,
      'highlightToday': instance.highlightToday,
      'showCurrentTime': instance.showCurrentTime,
      'colorMode': _$CourseColorModeEnumMap[instance.colorMode]!,
      'palette': _$CoursePaletteKindEnumMap[instance.palette]!,
      'textColor': _$CourseTextColorEnumMap[instance.textColor]!,
      'courseColors': instance.courseColors,
      'courseAliases': instance.courseAliases,
      'showLocation': instance.showLocation,
      'showTeacher': instance.showTeacher,
      'stripTeacherTitle': instance.stripTeacherTitle,
      'splitLocation': instance.splitLocation,
      'nameStyle': _$CourseNameStyleEnumMap[instance.nameStyle]!,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'oledBlack': instance.oledBlack,
    };

const _$CourseLineHeightEnumMap = {
  CourseLineHeight.compact: 'compact',
  CourseLineHeight.standard: 'standard',
  CourseLineHeight.relaxed: 'relaxed',
};

const _$CourseTextAlignmentEnumMap = {
  CourseTextAlignment.left: 'left',
  CourseTextAlignment.center: 'center',
};

const _$CourseColorModeEnumMap = {
  CourseColorMode.theme: 'theme',
  CourseColorMode.custom: 'custom',
  CourseColorMode.single: 'single',
};

const _$CoursePaletteKindEnumMap = {
  CoursePaletteKind.material: 'material',
  CoursePaletteKind.macaron: 'macaron',
  CoursePaletteKind.morandi: 'morandi',
  CoursePaletteKind.contrast: 'contrast',
};

const _$CourseTextColorEnumMap = {
  CourseTextColor.auto: 'auto',
  CourseTextColor.dark: 'dark',
  CourseTextColor.light: 'light',
};

const _$CourseNameStyleEnumMap = {
  CourseNameStyle.full: 'full',
  CourseNameStyle.alias: 'alias',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};
