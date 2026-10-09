// timetable_style.dart
// 课表样式配置
// by ashenmajo

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_style.freezed.dart';
part 'timetable_style.g.dart';

enum AppThemeMode { system, light, dark }

enum CourseLineHeight { compact, standard, relaxed }

enum CourseTextAlignment { left, center }

enum CourseColorMode { theme, custom, single }

enum CoursePaletteKind { material, macaron, morandi, contrast }

enum CourseTextColor { auto, dark, light }

enum CourseNameStyle { full, alias }

class _EnumFallback<T extends Enum> implements JsonConverter<T, String> {
  const _EnumFallback(this.values);
  final List<T> values;

  @override
  T fromJson(String json) =>
      values.firstWhere((v) => v.name == json, orElse: () => values.first);

  @override
  String toJson(T object) => object.name;
}

@freezed
abstract class TimetableStyle with _$TimetableStyle {
  const TimetableStyle._();

  const factory TimetableStyle({
    @JsonKey(name: 'seedColor')
    @Default(TimetableStyle.defaultSeedColor)
    int seedColorValue,
    @Default(TimetableStyle.defaultDayWidth) double dayWidth,
    @Default(0) double cellHeight,
    @Default(1) double fontScale,
    @_EnumFallback(CourseLineHeight.values)
    @Default(CourseLineHeight.standard)
    CourseLineHeight lineHeight,
    @Default(TimetableStyle.defaultHeaderHeight) double headerHeight,
    @Default(TimetableStyle.defaultPeriodColumnWidth) double periodColumnWidth,
    @Default(TimetableStyle.defaultCourseBlockGap) double courseBlockGap,
    @Default(TimetableStyle.defaultCourseBlockRadius) double courseBlockRadius,
    @Default(TimetableStyle.defaultCourseHorizontalPadding)
    double courseHorizontalPadding,
    @Default(TimetableStyle.defaultCourseVerticalPadding)
    double courseVerticalPadding,
    @_EnumFallback(CourseTextAlignment.values)
    @Default(CourseTextAlignment.left)
    CourseTextAlignment courseTextAlignment,
    @Default(true) bool showWeekend,
    @Default(true) bool showPeriodColumn,
    @Default(true) bool showWeekSelector,
    @Default(true) bool showGrid,
    @Default(true) bool showHeaderDate,
    @Default(true) bool showPeriodEndTime,
    @Default(true) bool highlightToday,
    @Default(true) bool showCurrentTime,
    @_EnumFallback(CourseColorMode.values)
    @Default(CourseColorMode.theme)
    CourseColorMode colorMode,
    @_EnumFallback(CoursePaletteKind.values)
    @Default(CoursePaletteKind.morandi)
    CoursePaletteKind palette,
    @_EnumFallback(CourseTextColor.values)
    @Default(CourseTextColor.auto)
    CourseTextColor textColor,
    @Default(<String, int>{}) Map<String, int> courseColors,
    @Default(<String, String>{}) Map<String, String> courseAliases,
    @Default(true) bool showLocation,
    @Default(false) bool showTeacher,
    @Default(true) bool stripTeacherTitle,
    @Default(true) bool splitLocation,
    @_EnumFallback(CourseNameStyle.values)
    @Default(CourseNameStyle.full)
    CourseNameStyle nameStyle,
    @_EnumFallback(AppThemeMode.values)
    @Default(AppThemeMode.system)
    AppThemeMode themeMode,
    @Default(false) bool oledBlack,
  }) = _TimetableStyle;

  factory TimetableStyle.fromJson(Map<String, dynamic> json) =>
      _$TimetableStyleFromJson(json);

  // ---- 常量 ----

  static const double baseFontSize = 12.5;
  static const int defaultSeedColor = 0xFF3F51B5;

  static const List<int> seedChoices = <int>[
    0xFF3F51B5, // 靛蓝
    0xFF1565C0, // 蓝
    0xFF00695C, // 青绿
    0xFF2E7D32, // 绿
    0xFF827717, // 橄榄
    0xFFEF6C00, // 橙
    0xFFC62828, // 红
    0xFFAD1457, // 玫红
    0xFF6A1B9A, // 紫
    0xFF4E342E, // 棕
    0xFF37474F, // 蓝灰
    0xFF424242, // 灰
  ];

  static const double defaultDayWidth = 46;
  static const double minDayWidth = 40;
  static const double maxDayWidth = 110;

  static const double minCellHeight = 56;
  static const double maxCellHeight = 140;

  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.5;

  static const double defaultHeaderHeight = 54;
  static const double minHeaderHeight = 42;
  static const double maxHeaderHeight = 76;

  static const double defaultPeriodColumnWidth = 44;
  static const double minPeriodColumnWidth = 34;
  static const double maxPeriodColumnWidth = 68;

  static const double defaultCourseBlockGap = 2;
  static const double minCourseBlockGap = 0;
  static const double maxCourseBlockGap = 8;

  static const double defaultCourseBlockRadius = 12;
  static const double minCourseBlockRadius = 0;
  static const double maxCourseBlockRadius = 24;

  static const double defaultCourseHorizontalPadding = 4;
  static const double minCourseHorizontalPadding = 2;
  static const double maxCourseHorizontalPadding = 10;

  static const double defaultCourseVerticalPadding = 3;
  static const double minCourseVerticalPadding = 1;
  static const double maxCourseVerticalPadding = 8;

  static const double minAutoCellHeight = 56;
  static const int maxNameLines = 12;
  static const int maxLocationLines = 2;
  static const int maxTeacherLines = 1;

  static const TimetableStyle defaults = TimetableStyle();

  // ---- getter ----

  Color get seedColor => Color(seedColorValue);

  double get fontSize => baseFontSize * fontScale;

  double get detailFontSize => (fontSize * 0.8).clamp(8, 16);

  double get lineHeightFactor => switch (lineHeight) {
    CourseLineHeight.compact => 1.1,
    CourseLineHeight.standard => 1.25,
    CourseLineHeight.relaxed => 1.45,
  };

  double get nameLineHeight => fontSize * lineHeightFactor;

  double get detailLineHeight => detailFontSize * lineHeightFactor;

  bool get autoCellHeight => cellHeight <= 0;

  int get weekdayCount => showWeekend ? 7 : 5;

  // ---- 方法 ----

  String nameFor(String courseName) {
    if (nameStyle != CourseNameStyle.alias) {
      return courseName;
    }
    final alias = courseAliases[courseName];
    return alias == null || alias.trim().isEmpty ? courseName : alias.trim();
  }

  String teacherFor(String teacher) =>
      stripTeacherTitle ? stripTeacherTitleOf(teacher) : teacher;

  ({int nameLines, int detailLines}) lineBudget(
    double blockHeight, {
    required int detailWidgets,
  }) {
    final available = blockHeight - courseVerticalPadding * 2;
    final wanted = switch (detailWidgets) {
      <= 0 => 0,
      1 => maxLocationLines,
      _ => maxLocationLines + maxTeacherLines,
    };
    var detailLines = 0;
    for (var lines = wanted; lines >= 1; lines--) {
      if (available >= nameLineHeight + detailLineHeight * lines) {
        detailLines = lines;
        break;
      }
    }
    final nameLines =
        ((available - detailLines * detailLineHeight) / nameLineHeight)
            .floor()
            .clamp(1, maxNameLines);
    return (nameLines: nameLines, detailLines: detailLines);
  }

  TimetableStyle withCourseColor(String courseName, int? argb) {
    final next = Map<String, int>.of(courseColors);
    if (argb == null) {
      next.remove(courseName);
    } else {
      next[courseName] = argb;
    }
    return copyWith(courseColors: next);
  }

  TimetableStyle withCourseAlias(String courseName, String? alias) {
    final next = Map<String, String>.of(courseAliases);
    final trimmed = alias?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == courseName) {
      next.remove(courseName);
    } else {
      next[courseName] = trimmed;
    }
    return copyWith(courseAliases: next);
  }
}

String stripTeacherTitleOf(String value) {
  var text = value.trim();
  if (text.isEmpty) {
    return value;
  }
  text = text.replaceAll(RegExp(r'[（(]\s*(高校|企业|外聘|兼职|专职|返聘)\s*[）)]\s*$'), '');
  final match = RegExp(
    r'^(.*?)\s*(?:高等学校|高等|高级|副|助理|外聘|兼职|专职)?'
    r'(?:教授|讲师|助教|教师|工程师|实验师|研究员|教员)$',
  ).firstMatch(text);
  if (match == null) {
    return text.isEmpty ? value : text;
  }
  final name = match.group(1)!.trim();
  return name.isEmpty ? value : name;
}
