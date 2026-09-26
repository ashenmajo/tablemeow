import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 主题模式：亮色 / 暗色 / 跟随系统。
enum AppThemeMode { system, light, dark }

/// 行高（行距）档位。
enum CourseLineHeight { compact, standard, relaxed }

/// 课程块中文字的横向对齐方式。
enum CourseTextAlignment { left, center }

/// 课程块配色的分配方式。
enum CourseColorMode {
  /// 跟随主题色：用主题配色里的容器色，天然与主色协调（默认）。
  theme,

  /// 自定义色板：在下面选的色板里按课程名取色。
  custom,

  /// 全部课程用同一个颜色。
  single,
}

/// 内置色板（自定义配色方案时使用）。
enum CoursePaletteKind { material, macaron, morandi, contrast }

/// 课程块上的文字颜色。
enum CourseTextColor { auto, dark, light }

/// 课程名显示方式。
enum CourseNameStyle { full, alias }

/// 课表外观设置：格子布局、配色、信息显示与主题。
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

  /// 主题主色（种子色）。整套 Material 3 配色由它推导，
  /// 课表里「跟随主题色」的课程块也用它。
  final int seedColorValue;

  Color get seedColor => Color(seedColorValue);

  // ---- 格子与布局 ----

  /// 每天一列的最小宽度；放不下时课表横向滚动。
  final double dayWidth;

  /// 每节课的行高；`0` 表示自动撑满可视区域。
  final double cellHeight;

  /// 字号缩放倍数（0.8–1.5）。
  final double fontScale;

  /// 行距档位。
  final CourseLineHeight lineHeight;

  /// 星期表头、节次列和课程块的细节尺寸。
  final double headerHeight;
  final double periodColumnWidth;
  final double courseBlockGap;
  final double courseBlockRadius;
  final double courseHorizontalPadding;
  final double courseVerticalPadding;
  final CourseTextAlignment courseTextAlignment;

  /// 是否显示周六周日。
  final bool showWeekend;

  /// 是否显示左侧节次（时间）列。
  final bool showPeriodColumn;

  /// 是否显示顶部周次条。
  final bool showWeekSelector;

  /// 是否显示网格线。
  final bool showGrid;

  final bool showHeaderDate;
  final bool showPeriodEndTime;
  final bool highlightToday;
  final bool showCurrentTime;

  // ---- 颜色 ----

  final CourseColorMode colorMode;
  final CoursePaletteKind palette;
  final CourseTextColor textColor;

  /// 单课自定义颜色：课程名 → ARGB。
  final Map<String, int> courseColors;

  /// 课程别名：原名 → 想显示的名字。
  final Map<String, String> courseAliases;

  // ---- 信息显示 ----

  final bool showLocation;
  final bool showTeacher;

  /// 是否去掉教师名后面的职称（`刘湛讲师（高校）` → `刘湛`）。
  final bool stripTeacherTitle;

  /// 是否把地点拆成「楼名 + 房间号」两行，避免房间号被拆开。
  final bool splitLocation;

  final CourseNameStyle nameStyle;

  // ---- 主题 ----

  final AppThemeMode themeMode;
  final bool oledBlack;

  // ---- 常量与派生值 ----

  /// 字号基准值，实际字号 = 基准 × [fontScale]。
  static const double baseFontSize = 12.5;

  /// 默认主色：靛蓝。
  static const int defaultSeedColor = 0xFF3F51B5;

  /// 可选主色（Material 调色板的常见色相），用户选一个，整套配色从它推导。
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

  /// 课程块上显示的名字（配了别名且选了别名模式时用别名）。
  String nameFor(String courseName) {
    if (nameStyle != CourseNameStyle.alias) {
      return courseName;
    }
    final String? alias = courseAliases[courseName];
    return alias == null || alias.trim().isEmpty ? courseName : alias.trim();
  }

  /// 教师显示文本：按设置决定要不要去掉职称后缀。
  String teacherFor(String teacher) =>
      stripTeacherTitle ? stripTeacherTitleOf(teacher) : teacher;

  /// 给定课程块高度与副信息行数，算出课程名与副信息各能放几行。
  ///
  /// 两者加起来不会超过块高，所以不会溢出。
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

  /// 给某门课指定（或清除）颜色与别名。
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

/// 教师名后面的职称与括注（`刘湛讲师（高校）` → `刘湛`）。
///
/// 放在这里是为了让「是否去掉职称」这个开关在渲染时才生效，
/// 导入时保留原始文本。
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
