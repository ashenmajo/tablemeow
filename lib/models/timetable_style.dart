import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

enum CourseLineHeight { compact, standard, relaxed }

enum CourseTextAlignment { left, center }

enum CourseColorMode { theme, custom, single }

enum CoursePaletteKind { material, macaron, morandi, contrast }

enum CourseTextColor { auto, dark, light }

enum CourseNameStyle { full, alias }

@immutable
class TimetableStyle {
  const TimetableStyle({
    this.seedColorValue = defaultSeedColor,
    this.dayWidth = defaultDayWidth,
    this.cellHeight = 0,
    this.fontScale = 1,
    this.lineHeight = CourseLineHeight.standard,
    this.headerHeight = defaultHeaderHeight,
    this.periodColumnWidth = defaultPeriodColumnWidth,
    this.courseBlockGap = defaultCourseBlockGap,
    this.courseBlockRadius = defaultCourseBlockRadius,
    this.courseHorizontalPadding = defaultCourseHorizontalPadding,
    this.courseVerticalPadding = defaultCourseVerticalPadding,
    this.courseTextAlignment = CourseTextAlignment.left,
    this.showWeekend = true,
    this.showPeriodColumn = true,
    this.showWeekSelector = true,
    this.showGrid = true,
    this.showHeaderDate = true,
    this.showPeriodEndTime = true,
    this.highlightToday = true,
    this.showCurrentTime = true,
    this.colorMode = CourseColorMode.theme,
    this.palette = CoursePaletteKind.morandi,
    this.textColor = CourseTextColor.auto,
    this.courseColors = const <String, int>{},
    this.courseAliases = const <String, String>{},
    this.showLocation = true,
    this.showTeacher = false,
    this.stripTeacherTitle = true,
    this.splitLocation = true,
    this.nameStyle = CourseNameStyle.full,
    this.themeMode = AppThemeMode.system,
    this.oledBlack = false,
  });

  final int seedColorValue;

  Color get seedColor => Color(seedColorValue);

  final double dayWidth;
  final double cellHeight;

  final double fontScale;

  final CourseLineHeight lineHeight;

  final double headerHeight;
  final double periodColumnWidth;
  final double courseBlockGap;
  final double courseBlockRadius;
  final double courseHorizontalPadding;
  final double courseVerticalPadding;
  final CourseTextAlignment courseTextAlignment;

  final bool showWeekend;

  final bool showPeriodColumn;

  final bool showWeekSelector;

  final bool showGrid;

  final bool showHeaderDate;
  final bool showPeriodEndTime;
  final bool highlightToday;
  final bool showCurrentTime;
  final CourseColorMode colorMode;
  final CoursePaletteKind palette;
  final CourseTextColor textColor;

  final Map<String, int> courseColors;

  final Map<String, String> courseAliases;

  final bool showLocation;
  final bool showTeacher;

  final bool stripTeacherTitle;

  final bool splitLocation;

  final CourseNameStyle nameStyle;

  final AppThemeMode themeMode;
  final bool oledBlack;

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

  /// 每节高度（自动模式除外）的范围。
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

  /// 自动行高时每个格子的最小高度。
  static const double minAutoCellHeight = 56;

  /// 课程名最多占几行（防止极端设置下无限占高）。
  static const int maxNameLines = 12;

  /// 地点最多两行；再加上教师最多一行。
  static const int maxLocationLines = 2;
  static const int maxTeacherLines = 1;

  static const TimetableStyle defaults = TimetableStyle();

  double get fontSize => baseFontSize * fontScale;

  double get detailFontSize => (fontSize * 0.8).clamp(8, 16);

  /// 行距倍数。
  double get lineHeightFactor => switch (lineHeight) {
    CourseLineHeight.compact => 1.1,
    CourseLineHeight.standard => 1.25,
    CourseLineHeight.relaxed => 1.45,
  };

  double get nameLineHeight => fontSize * lineHeightFactor;

  double get detailLineHeight => detailFontSize * lineHeightFactor;

  bool get autoCellHeight => cellHeight <= 0;

  int get weekdayCount => showWeekend ? 7 : 5;

  String nameFor(String courseName) {
    if (nameStyle != CourseNameStyle.alias) {
      return courseName;
    }
    final String? alias = courseAliases[courseName];
    return alias == null || alias.trim().isEmpty ? courseName : alias.trim();
  }

  String teacherFor(String teacher) =>
      stripTeacherTitle ? stripTeacherTitleOf(teacher) : teacher;

  ({int nameLines, int detailLines}) lineBudget(
    double blockHeight, {
    required int detailWidgets,
  }) {
    final double available = blockHeight - courseVerticalPadding * 2;
    final int wanted = switch (detailWidgets) {
      <= 0 => 0,
      1 => maxLocationLines,
      _ => maxLocationLines + maxTeacherLines,
    };
    int detailLines = 0;
    for (int lines = wanted; lines >= 1; lines--) {
      if (available >= nameLineHeight + detailLineHeight * lines) {
        detailLines = lines;
        break;
      }
    }
    final int nameLines =
        ((available - detailLines * detailLineHeight) / nameLineHeight)
            .floor()
            .clamp(1, maxNameLines);
    return (nameLines: nameLines, detailLines: detailLines);
  }

  TimetableStyle copyWith({
    int? seedColorValue,
    double? dayWidth,
    double? cellHeight,
    double? fontScale,
    CourseLineHeight? lineHeight,
    double? headerHeight,
    double? periodColumnWidth,
    double? courseBlockGap,
    double? courseBlockRadius,
    double? courseHorizontalPadding,
    double? courseVerticalPadding,
    CourseTextAlignment? courseTextAlignment,
    bool? showWeekend,
    bool? showPeriodColumn,
    bool? showWeekSelector,
    bool? showGrid,
    bool? showHeaderDate,
    bool? showPeriodEndTime,
    bool? highlightToday,
    bool? showCurrentTime,
    CourseColorMode? colorMode,
    CoursePaletteKind? palette,
    CourseTextColor? textColor,
    Map<String, int>? courseColors,
    Map<String, String>? courseAliases,
    bool? showLocation,
    bool? showTeacher,
    bool? stripTeacherTitle,
    bool? splitLocation,
    CourseNameStyle? nameStyle,
    AppThemeMode? themeMode,
    bool? oledBlack,
  }) {
    return TimetableStyle(
      seedColorValue: seedColorValue ?? this.seedColorValue,
      dayWidth: dayWidth ?? this.dayWidth,
      cellHeight: cellHeight ?? this.cellHeight,
      fontScale: fontScale ?? this.fontScale,
      lineHeight: lineHeight ?? this.lineHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      periodColumnWidth: periodColumnWidth ?? this.periodColumnWidth,
      courseBlockGap: courseBlockGap ?? this.courseBlockGap,
      courseBlockRadius: courseBlockRadius ?? this.courseBlockRadius,
      courseHorizontalPadding:
          courseHorizontalPadding ?? this.courseHorizontalPadding,
      courseVerticalPadding:
          courseVerticalPadding ?? this.courseVerticalPadding,
      courseTextAlignment: courseTextAlignment ?? this.courseTextAlignment,
      showWeekend: showWeekend ?? this.showWeekend,
      showPeriodColumn: showPeriodColumn ?? this.showPeriodColumn,
      showWeekSelector: showWeekSelector ?? this.showWeekSelector,
      showGrid: showGrid ?? this.showGrid,
      showHeaderDate: showHeaderDate ?? this.showHeaderDate,
      showPeriodEndTime: showPeriodEndTime ?? this.showPeriodEndTime,
      highlightToday: highlightToday ?? this.highlightToday,
      showCurrentTime: showCurrentTime ?? this.showCurrentTime,
      colorMode: colorMode ?? this.colorMode,
      palette: palette ?? this.palette,
      textColor: textColor ?? this.textColor,
      courseColors: courseColors ?? this.courseColors,
      courseAliases: courseAliases ?? this.courseAliases,
      showLocation: showLocation ?? this.showLocation,
      showTeacher: showTeacher ?? this.showTeacher,
      stripTeacherTitle: stripTeacherTitle ?? this.stripTeacherTitle,
      splitLocation: splitLocation ?? this.splitLocation,
      nameStyle: nameStyle ?? this.nameStyle,
      themeMode: themeMode ?? this.themeMode,
      oledBlack: oledBlack ?? this.oledBlack,
    );
  }

  TimetableStyle withCourseColor(String courseName, int? argb) {
    final Map<String, int> next = Map<String, int>.of(courseColors);
    if (argb == null) {
      next.remove(courseName);
    } else {
      next[courseName] = argb;
    }
    return copyWith(courseColors: next);
  }

  TimetableStyle withCourseAlias(String courseName, String? alias) {
    final Map<String, String> next = Map<String, String>.of(courseAliases);
    final String trimmed = alias?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == courseName) {
      next.remove(courseName);
    } else {
      next[courseName] = trimmed;
    }
    return copyWith(courseAliases: next);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'seedColor': seedColorValue,
    'dayWidth': dayWidth,
    'cellHeight': cellHeight,
    'fontScale': fontScale,
    'lineHeight': lineHeight.name,
    'headerHeight': headerHeight,
    'periodColumnWidth': periodColumnWidth,
    'courseBlockGap': courseBlockGap,
    'courseBlockRadius': courseBlockRadius,
    'courseHorizontalPadding': courseHorizontalPadding,
    'courseVerticalPadding': courseVerticalPadding,
    'courseTextAlignment': courseTextAlignment.name,
    'showWeekend': showWeekend,
    'showPeriodColumn': showPeriodColumn,
    'showWeekSelector': showWeekSelector,
    'showGrid': showGrid,
    'showHeaderDate': showHeaderDate,
    'showPeriodEndTime': showPeriodEndTime,
    'highlightToday': highlightToday,
    'showCurrentTime': showCurrentTime,
    'colorMode': colorMode.name,
    'palette': palette.name,
    'textColor': textColor.name,
    'courseColors': courseColors,
    'courseAliases': courseAliases,
    'showLocation': showLocation,
    'showTeacher': showTeacher,
    'stripTeacherTitle': stripTeacherTitle,
    'splitLocation': splitLocation,
    'nameStyle': nameStyle.name,
    'themeMode': themeMode.name,
    'oledBlack': oledBlack,
  };

  factory TimetableStyle.fromJson(Map<String, dynamic> json) {
    double fontScale = (json['fontScale'] as num? ?? 1).toDouble();
    final Object? legacyFontSize = json['fontSize'];
    if (json['fontScale'] == null && legacyFontSize is num) {
      fontScale = legacyFontSize.toDouble() / baseFontSize;
    }
    return TimetableStyle(
      seedColorValue: (json['seedColor'] as num? ?? defaultSeedColor).toInt(),
      dayWidth: (json['dayWidth'] as num? ?? defaultDayWidth).toDouble().clamp(
        minDayWidth,
        maxDayWidth,
      ),
      cellHeight: (json['cellHeight'] as num? ?? 0).toDouble().clamp(
        0,
        maxCellHeight,
      ),
      fontScale: fontScale.clamp(minFontScale, maxFontScale),
      lineHeight: _byName(CourseLineHeight.values, json['lineHeight']),
      headerHeight: (json['headerHeight'] as num? ?? defaultHeaderHeight)
          .toDouble()
          .clamp(minHeaderHeight, maxHeaderHeight),
      periodColumnWidth:
          (json['periodColumnWidth'] as num? ?? defaultPeriodColumnWidth)
              .toDouble()
              .clamp(minPeriodColumnWidth, maxPeriodColumnWidth),
      courseBlockGap: (json['courseBlockGap'] as num? ?? defaultCourseBlockGap)
          .toDouble()
          .clamp(minCourseBlockGap, maxCourseBlockGap),
      courseBlockRadius:
          (json['courseBlockRadius'] as num? ?? defaultCourseBlockRadius)
              .toDouble()
              .clamp(minCourseBlockRadius, maxCourseBlockRadius),
      courseHorizontalPadding:
          (json['courseHorizontalPadding'] as num? ??
                  defaultCourseHorizontalPadding)
              .toDouble()
              .clamp(minCourseHorizontalPadding, maxCourseHorizontalPadding),
      courseVerticalPadding:
          (json['courseVerticalPadding'] as num? ??
                  defaultCourseVerticalPadding)
              .toDouble()
              .clamp(minCourseVerticalPadding, maxCourseVerticalPadding),
      courseTextAlignment: _byName(
        CourseTextAlignment.values,
        json['courseTextAlignment'],
      ),
      showWeekend: json['showWeekend'] as bool? ?? true,
      showPeriodColumn: json['showPeriodColumn'] as bool? ?? true,
      showWeekSelector: json['showWeekSelector'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      showHeaderDate: json['showHeaderDate'] as bool? ?? true,
      showPeriodEndTime: json['showPeriodEndTime'] as bool? ?? true,
      highlightToday: json['highlightToday'] as bool? ?? true,
      showCurrentTime: json['showCurrentTime'] as bool? ?? true,
      colorMode: _byName(CourseColorMode.values, json['colorMode']),
      palette: _byName(CoursePaletteKind.values, json['palette']),
      textColor: _byName(CourseTextColor.values, json['textColor']),
      courseColors: _intMap(json['courseColors']),
      courseAliases: _stringMap(json['courseAliases']),
      showLocation: json['showLocation'] as bool? ?? true,
      showTeacher: json['showTeacher'] as bool? ?? false,
      stripTeacherTitle: json['stripTeacherTitle'] as bool? ?? true,
      splitLocation: json['splitLocation'] as bool? ?? true,
      nameStyle: _byName(CourseNameStyle.values, json['nameStyle']),
      themeMode: _byName(AppThemeMode.values, json['themeMode']),
      oledBlack: json['oledBlack'] as bool? ?? false,
    );
  }

  static T _byName<T extends Enum>(List<T> values, Object? raw) {
    if (raw is String) {
      for (final T value in values) {
        if (value.name == raw) {
          return value;
        }
      }
    }
    return values.first;
  }

  static Map<String, int> _intMap(Object? raw) {
    if (raw is! Map) {
      return const <String, int>{};
    }
    return <String, int>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        if (entry.value is num)
          entry.key.toString(): (entry.value! as num).toInt(),
    };
  }

  static Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) {
      return const <String, String>{};
    }
    return <String, String>{
      for (final MapEntry<Object?, Object?> entry in raw.entries)
        if (entry.value != null && entry.value.toString().trim().isNotEmpty)
          entry.key.toString(): entry.value.toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is TimetableStyle &&
      other.seedColorValue == seedColorValue &&
      other.dayWidth == dayWidth &&
      other.cellHeight == cellHeight &&
      other.fontScale == fontScale &&
      other.lineHeight == lineHeight &&
      other.headerHeight == headerHeight &&
      other.periodColumnWidth == periodColumnWidth &&
      other.courseBlockGap == courseBlockGap &&
      other.courseBlockRadius == courseBlockRadius &&
      other.courseHorizontalPadding == courseHorizontalPadding &&
      other.courseVerticalPadding == courseVerticalPadding &&
      other.courseTextAlignment == courseTextAlignment &&
      other.showWeekend == showWeekend &&
      other.showPeriodColumn == showPeriodColumn &&
      other.showWeekSelector == showWeekSelector &&
      other.showGrid == showGrid &&
      other.showHeaderDate == showHeaderDate &&
      other.showPeriodEndTime == showPeriodEndTime &&
      other.highlightToday == highlightToday &&
      other.showCurrentTime == showCurrentTime &&
      other.colorMode == colorMode &&
      other.palette == palette &&
      other.textColor == textColor &&
      mapEquals(other.courseColors, courseColors) &&
      mapEquals(other.courseAliases, courseAliases) &&
      other.showLocation == showLocation &&
      other.showTeacher == showTeacher &&
      other.stripTeacherTitle == stripTeacherTitle &&
      other.splitLocation == splitLocation &&
      other.nameStyle == nameStyle &&
      other.themeMode == themeMode &&
      other.oledBlack == oledBlack;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    seedColorValue,
    dayWidth,
    cellHeight,
    fontScale,
    lineHeight,
    headerHeight,
    periodColumnWidth,
    courseBlockGap,
    courseBlockRadius,
    courseHorizontalPadding,
    courseVerticalPadding,
    courseTextAlignment,
    showWeekend,
    showPeriodColumn,
    showWeekSelector,
    showGrid,
    showHeaderDate,
    showPeriodEndTime,
    highlightToday,
    showCurrentTime,
    colorMode,
    palette,
    textColor,
    Object.hashAllUnordered(courseColors.entries.map((e) => e.key)),
    Object.hashAllUnordered(courseAliases.entries.map((e) => e.key)),
    showLocation,
    showTeacher,
    stripTeacherTitle,
    splitLocation,
    nameStyle,
    themeMode,
    oledBlack,
  ]);
}

String stripTeacherTitleOf(String value) {
  String text = value.trim();
  if (text.isEmpty) {
    return value;
  }
  text = text.replaceAll(RegExp(r'[（(]\s*(高校|企业|外聘|兼职|专职|返聘)\s*[）)]\s*$'), '');
  final RegExpMatch? match = RegExp(
    r'^(.*?)\s*(?:高等学校|高等|高级|副|助理|外聘|兼职|专职)?'
    r'(?:教授|讲师|助教|教师|工程师|实验师|研究员|教员)$',
  ).firstMatch(text);
  if (match == null) {
    return text.isEmpty ? value : text;
  }
  final String name = match.group(1)!.trim();
  return name.isEmpty ? value : name;
}
