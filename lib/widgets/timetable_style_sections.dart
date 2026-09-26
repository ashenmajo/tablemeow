import 'package:flutter/material.dart';

import '../models/timetable_style.dart';
import '../theme/course_palette.dart';

/// 课表外观的四组设置，分别对应设置里的四个入口。
///
/// 每组只管自己的字段，改完立刻回调 [onChanged]。

// ---------------------------------------------------------------------------
// 布局与尺寸
// ---------------------------------------------------------------------------

/// 判断字号放不放得下时用的通用长课程名（不展示给用户）。
const String _worstCaseName = '课程名称较长时的示例文本内容';

enum _LayoutPreset { compact, balanced, spacious }

class TimetableLayoutSection extends StatefulWidget {
  const TimetableLayoutSection({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final TimetableStyle style;
  final ValueChanged<TimetableStyle> onChanged;

  @override
  State<TimetableLayoutSection> createState() => _TimetableLayoutSectionState();
}

class _TimetableLayoutSectionState extends State<TimetableLayoutSection> {
  late TimetableStyle _style = widget.style;

  @override
  void didUpdateWidget(TimetableLayoutSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style && widget.style != _style) {
      _style = widget.style;
    }
  }

  void _apply(TimetableStyle style) {
    setState(() => _style = style);
    widget.onChanged(style);
  }

  @override
  Widget build(BuildContext context) {
    final double maxScale = _maxFontScale(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StyleChoiceRow<_LayoutPreset>(
          label: '密度预设',
          values: _LayoutPreset.values,
          selected: _matchingPreset(),
          labelOf: (_LayoutPreset value) => switch (value) {
            _LayoutPreset.compact => '紧凑',
            _LayoutPreset.balanced => '均衡',
            _LayoutPreset.spacious => '舒展',
          },
          onChanged: _applyPreset,
        ),
        const Divider(height: 32),
        Text('基础尺寸', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('每节高度自动'),
          value: _style.autoCellHeight,
          onChanged: (bool value) =>
              _apply(_style.copyWith(cellHeight: value ? 0 : 72)),
        ),
        StyleSlider(
          label: '每节高度',
          value: _style.autoCellHeight
              ? '自动'
              : '${_style.cellHeight.round()} dp',
          slider: Slider(
            value: _style.autoCellHeight
                ? TimetableStyle.minCellHeight
                : _style.cellHeight.clamp(
                    TimetableStyle.minCellHeight,
                    TimetableStyle.maxCellHeight,
                  ),
            min: TimetableStyle.minCellHeight,
            max: TimetableStyle.maxCellHeight,
            divisions:
                ((TimetableStyle.maxCellHeight - TimetableStyle.minCellHeight) /
                        4)
                    .round(),
            label: '${_style.cellHeight.round()} dp',
            onChanged: _style.autoCellHeight
                ? null
                : (double value) => _apply(_style.copyWith(cellHeight: value)),
          ),
        ),
        StyleSlider(
          label: '字号缩放',
          value: '${_style.fontScale.toStringAsFixed(2)}×',
          slider: Slider(
            value: _style.fontScale.clamp(
              TimetableStyle.minFontScale,
              maxScale,
            ),
            min: TimetableStyle.minFontScale,
            max: maxScale,
            divisions: ((maxScale - TimetableStyle.minFontScale) * 20).round(),
            label: '${_style.fontScale.toStringAsFixed(2)}×',
            onChanged: (double value) =>
                _apply(_style.copyWith(fontScale: value)),
          ),
        ),
        StyleChoiceRow<CourseLineHeight>(
          label: '行高',
          values: CourseLineHeight.values,
          selected: _style.lineHeight,
          labelOf: (CourseLineHeight value) => switch (value) {
            CourseLineHeight.compact => '紧凑',
            CourseLineHeight.standard => '标准',
            CourseLineHeight.relaxed => '宽松',
          },
          onChanged: (CourseLineHeight value) =>
              _apply(_style.copyWith(lineHeight: value)),
        ),
        StyleSlider(
          label: '列宽',
          value: '${_style.dayWidth.round()} dp',
          slider: Slider(
            value: _style.dayWidth,
            min: TimetableStyle.minDayWidth,
            max: TimetableStyle.maxDayWidth,
            divisions: (TimetableStyle.maxDayWidth - TimetableStyle.minDayWidth)
                .round(),
            label: '${_style.dayWidth.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(dayWidth: value)),
          ),
        ),
        const Divider(height: 32),
        Text('课程块', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        StyleSlider(
          label: '块间距',
          value: '${_style.courseBlockGap.round()} dp',
          slider: Slider(
            value: _style.courseBlockGap,
            min: TimetableStyle.minCourseBlockGap,
            max: TimetableStyle.maxCourseBlockGap,
            divisions: 8,
            label: '${_style.courseBlockGap.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(courseBlockGap: value)),
          ),
        ),
        StyleSlider(
          label: '水平内边距',
          value: '${_style.courseHorizontalPadding.round()} dp',
          slider: Slider(
            value: _style.courseHorizontalPadding,
            min: TimetableStyle.minCourseHorizontalPadding,
            max: TimetableStyle.maxCourseHorizontalPadding,
            divisions: 8,
            label: '${_style.courseHorizontalPadding.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(courseHorizontalPadding: value)),
          ),
        ),
        StyleSlider(
          label: '垂直内边距',
          value: '${_style.courseVerticalPadding.round()} dp',
          slider: Slider(
            value: _style.courseVerticalPadding,
            min: TimetableStyle.minCourseVerticalPadding,
            max: TimetableStyle.maxCourseVerticalPadding,
            divisions: 7,
            label: '${_style.courseVerticalPadding.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(courseVerticalPadding: value)),
          ),
        ),
        StyleSlider(
          label: '圆角',
          value: '${_style.courseBlockRadius.round()} dp',
          slider: Slider(
            value: _style.courseBlockRadius,
            min: TimetableStyle.minCourseBlockRadius,
            max: TimetableStyle.maxCourseBlockRadius,
            divisions: 12,
            label: '${_style.courseBlockRadius.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(courseBlockRadius: value)),
          ),
        ),
        StyleChoiceRow<CourseTextAlignment>(
          label: '文字对齐',
          values: CourseTextAlignment.values,
          selected: _style.courseTextAlignment,
          labelOf: (CourseTextAlignment value) => switch (value) {
            CourseTextAlignment.left => '左对齐',
            CourseTextAlignment.center => '居中',
          },
          onChanged: (CourseTextAlignment value) =>
              _apply(_style.copyWith(courseTextAlignment: value)),
        ),
        const Divider(height: 32),
        Text('表头与节次', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        StyleSlider(
          label: '表头高度',
          value: '${_style.headerHeight.round()} dp',
          slider: Slider(
            value: _style.headerHeight,
            min: TimetableStyle.minHeaderHeight,
            max: TimetableStyle.maxHeaderHeight,
            divisions: 17,
            label: '${_style.headerHeight.round()} dp',
            onChanged: (double value) =>
                _apply(_style.copyWith(headerHeight: value)),
          ),
        ),
        StyleSlider(
          label: '节次列宽',
          value: '${_style.periodColumnWidth.round()} dp',
          slider: Slider(
            value: _style.periodColumnWidth,
            min: TimetableStyle.minPeriodColumnWidth,
            max: TimetableStyle.maxPeriodColumnWidth,
            divisions: 17,
            label: '${_style.periodColumnWidth.round()} dp',
            onChanged: _style.showPeriodColumn
                ? (double value) =>
                      _apply(_style.copyWith(periodColumnWidth: value))
                : null,
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('表头显示日期'),
          value: _style.showHeaderDate,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showHeaderDate: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示每节结束时间'),
          value: _style.showPeriodEndTime,
          onChanged: _style.showPeriodColumn
              ? (bool value) =>
                    _apply(_style.copyWith(showPeriodEndTime: value))
              : null,
        ),
        const Divider(height: 32),
        Text('可见结构', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示周末'),
          value: _style.showWeekend,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showWeekend: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示节次列'),
          value: _style.showPeriodColumn,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showPeriodColumn: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示周次条'),
          value: _style.showWeekSelector,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showWeekSelector: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示网格线'),
          value: _style.showGrid,
          onChanged: (bool value) => _apply(_style.copyWith(showGrid: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('高亮今天'),
          value: _style.highlightToday,
          onChanged: (bool value) =>
              _apply(_style.copyWith(highlightToday: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示当前时间线'),
          value: _style.showCurrentTime,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showCurrentTime: value)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _restoreDefaults,
            icon: const Icon(Icons.restart_alt),
            label: const Text('恢复默认布局'),
          ),
        ),
      ],
    );
  }

  _LayoutPreset? _matchingPreset() {
    for (final _LayoutPreset preset in _LayoutPreset.values) {
      final TimetableStyle candidate = _styleForPreset(preset);
      if (_sameLayout(_style, candidate)) {
        return preset;
      }
    }
    return null;
  }

  void _applyPreset(_LayoutPreset preset) => _apply(_styleForPreset(preset));

  void _restoreDefaults() {
    const TimetableStyle defaults = TimetableStyle.defaults;
    _apply(
      _style.copyWith(
        dayWidth: defaults.dayWidth,
        cellHeight: defaults.cellHeight,
        fontScale: defaults.fontScale,
        lineHeight: defaults.lineHeight,
        headerHeight: defaults.headerHeight,
        periodColumnWidth: defaults.periodColumnWidth,
        courseBlockGap: defaults.courseBlockGap,
        courseBlockRadius: defaults.courseBlockRadius,
        courseHorizontalPadding: defaults.courseHorizontalPadding,
        courseVerticalPadding: defaults.courseVerticalPadding,
        courseTextAlignment: defaults.courseTextAlignment,
        showWeekend: defaults.showWeekend,
        showPeriodColumn: defaults.showPeriodColumn,
        showWeekSelector: defaults.showWeekSelector,
        showGrid: defaults.showGrid,
        showHeaderDate: defaults.showHeaderDate,
        showPeriodEndTime: defaults.showPeriodEndTime,
        highlightToday: defaults.highlightToday,
        showCurrentTime: defaults.showCurrentTime,
      ),
    );
  }

  TimetableStyle _styleForPreset(_LayoutPreset preset) => switch (preset) {
    _LayoutPreset.compact => _style.copyWith(
      cellHeight: 56,
      dayWidth: 40,
      fontScale: 0.85,
      lineHeight: CourseLineHeight.compact,
      headerHeight: 44,
      periodColumnWidth: 38,
      courseBlockGap: 1,
      courseBlockRadius: 6,
      courseHorizontalPadding: 2,
      courseVerticalPadding: 1,
    ),
    _LayoutPreset.balanced => _style.copyWith(
      cellHeight: 0,
      dayWidth: TimetableStyle.defaultDayWidth,
      fontScale: 1,
      lineHeight: CourseLineHeight.standard,
      headerHeight: TimetableStyle.defaultHeaderHeight,
      periodColumnWidth: TimetableStyle.defaultPeriodColumnWidth,
      courseBlockGap: TimetableStyle.defaultCourseBlockGap,
      courseBlockRadius: TimetableStyle.defaultCourseBlockRadius,
      courseHorizontalPadding: TimetableStyle.defaultCourseHorizontalPadding,
      courseVerticalPadding: TimetableStyle.defaultCourseVerticalPadding,
    ),
    _LayoutPreset.spacious => _style.copyWith(
      cellHeight: 88,
      dayWidth: 64,
      fontScale: 1.1,
      lineHeight: CourseLineHeight.relaxed,
      headerHeight: 64,
      periodColumnWidth: 52,
      courseBlockGap: 4,
      courseBlockRadius: 16,
      courseHorizontalPadding: 6,
      courseVerticalPadding: 5,
    ),
  };

  bool _sameLayout(TimetableStyle a, TimetableStyle b) =>
      a.cellHeight == b.cellHeight &&
      a.dayWidth == b.dayWidth &&
      a.fontScale == b.fontScale &&
      a.lineHeight == b.lineHeight &&
      a.headerHeight == b.headerHeight &&
      a.periodColumnWidth == b.periodColumnWidth &&
      a.courseBlockGap == b.courseBlockGap &&
      a.courseBlockRadius == b.courseBlockRadius &&
      a.courseHorizontalPadding == b.courseHorizontalPadding &&
      a.courseVerticalPadding == b.courseVerticalPadding;

  /// 当前行高下，字号缩放最大能到多少（再大课程名就会被截断）。
  double _maxFontScale(BuildContext context) {
    final double blockHeight = _blockHeight(context);
    final int detailWidgets =
        (_style.showLocation ? 1 : 0) + (_style.showTeacher ? 1 : 0);
    double best = TimetableStyle.minFontScale;
    for (
      double scale = TimetableStyle.minFontScale;
      scale <= TimetableStyle.maxFontScale;
      scale += 0.05
    ) {
      final TimetableStyle candidate = _style.copyWith(fontScale: scale);
      final int room = candidate
          .lineBudget(blockHeight, detailWidgets: detailWidgets)
          .nameLines;
      if (room < 1 || _measureLines(context, candidate.fontSize) > room) {
        break;
      }
      best = scale;
    }
    return best.clamp(TimetableStyle.minFontScale, TimetableStyle.maxFontScale);
  }

  /// 按两节课的格子估算：自动行高时扣掉标题栏、周次条与导航栏。
  double _blockHeight(BuildContext context) {
    final double cellHeight = _style.autoCellHeight
        ? MediaQuery.sizeOf(context).height - 220
        : _style.cellHeight;
    return (cellHeight * 2 - 4).clamp(40, 600);
  }

  int _measureLines(BuildContext context, double fontSize) {
    final TextPainter painter =
        TextPainter(
          text: TextSpan(
            text: _worstCaseName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: _style.lineHeightFactor,
            ),
          ),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(
          maxWidth: (_style.dayWidth - _style.courseHorizontalPadding * 2)
              .clamp(10, 400),
        );
    final int lines = painter.computeLineMetrics().length;
    painter.dispose();
    return lines < 1 ? 1 : lines;
  }
}

// ---------------------------------------------------------------------------
// 配色
// ---------------------------------------------------------------------------

class TimetableColorSection extends StatefulWidget {
  const TimetableColorSection({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final TimetableStyle style;
  final ValueChanged<TimetableStyle> onChanged;

  @override
  State<TimetableColorSection> createState() => _TimetableColorSectionState();
}

class _TimetableColorSectionState extends State<TimetableColorSection> {
  late TimetableStyle _style = widget.style;

  void _apply(TimetableStyle style) {
    setState(() => _style = style);
    widget.onChanged(style);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StyleChoiceRow<CourseColorMode>(
          label: '配色方案',
          values: CourseColorMode.values,
          selected: _style.colorMode,
          labelOf: (CourseColorMode value) => switch (value) {
            CourseColorMode.theme => '跟随主题色',
            CourseColorMode.custom => '自定义色板',
            CourseColorMode.single => '单色',
          },
          onChanged: (CourseColorMode value) =>
              _apply(_style.copyWith(colorMode: value)),
        ),
        if (_style.colorMode == CourseColorMode.custom) ...<Widget>[
          const SizedBox(height: 8),
          Text('色板', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final CoursePaletteKind kind in CoursePaletteKind.values)
                _PaletteChip(
                  kind: kind,
                  selected: _style.palette == kind,
                  onTap: () => _apply(_style.copyWith(palette: kind)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        StyleChoiceRow<CourseTextColor>(
          label: '文字颜色',
          values: CourseTextColor.values,
          selected: _style.textColor,
          labelOf: (CourseTextColor value) => switch (value) {
            CourseTextColor.auto => '自动对比',
            CourseTextColor.dark => '深色',
            CourseTextColor.light => '浅色',
          },
          onChanged: (CourseTextColor value) =>
              _apply(_style.copyWith(textColor: value)),
        ),
        const SizedBox(height: 12),
        Text(
          '主色在「主题」里选；单门课的颜色在课程详情里设置。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 色板选择：用四个色块预览。
class _PaletteChip extends StatelessWidget {
  const _PaletteChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final CoursePaletteKind kind;
  final bool selected;
  final VoidCallback onTap;

  static const Map<CoursePaletteKind, String> _names =
      <CoursePaletteKind, String>{
        CoursePaletteKind.material: 'Material',
        CoursePaletteKind.macaron: '马卡龙',
        CoursePaletteKind.morandi: '莫兰迪',
        CoursePaletteKind.contrast: '高对比',
      };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Color> colors = CoursePalette.palettes[kind]!;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final Color color in colors.take(4))
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_names[kind]!, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 显示内容
// ---------------------------------------------------------------------------

class TimetableDisplaySection extends StatefulWidget {
  const TimetableDisplaySection({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final TimetableStyle style;
  final ValueChanged<TimetableStyle> onChanged;

  @override
  State<TimetableDisplaySection> createState() =>
      _TimetableDisplaySectionState();
}

class _TimetableDisplaySectionState extends State<TimetableDisplaySection> {
  late TimetableStyle _style = widget.style;

  void _apply(TimetableStyle style) {
    setState(() => _style = style);
    widget.onChanged(style);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示地点'),
          value: _style.showLocation,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showLocation: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('显示教师'),
          value: _style.showTeacher,
          onChanged: (bool value) =>
              _apply(_style.copyWith(showTeacher: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('去掉教师职称'),
          subtitle: const Text('如「讲师（高校）」'),
          value: _style.stripTeacherTitle,
          onChanged: (bool value) =>
              _apply(_style.copyWith(stripTeacherTitle: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('地点拆成两行'),
          subtitle: const Text('楼名与房间号分行'),
          value: _style.splitLocation,
          onChanged: (bool value) =>
              _apply(_style.copyWith(splitLocation: value)),
        ),
        StyleChoiceRow<CourseNameStyle>(
          label: '课程名',
          values: CourseNameStyle.values,
          selected: _style.nameStyle,
          labelOf: (CourseNameStyle value) => switch (value) {
            CourseNameStyle.full => '全名',
            CourseNameStyle.alias => '别名',
          },
          onChanged: (CourseNameStyle value) =>
              _apply(_style.copyWith(nameStyle: value)),
        ),
        const SizedBox(height: 8),
        Text(
          '别名在课程详情里设置。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 主题
// ---------------------------------------------------------------------------

class TimetableThemeSection extends StatefulWidget {
  const TimetableThemeSection({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final TimetableStyle style;
  final ValueChanged<TimetableStyle> onChanged;

  @override
  State<TimetableThemeSection> createState() => _TimetableThemeSectionState();
}

class _TimetableThemeSectionState extends State<TimetableThemeSection> {
  late TimetableStyle _style = widget.style;

  void _apply(TimetableStyle style) {
    setState(() => _style = style);
    widget.onChanged(style);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('主色', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          '整应用的配色与课表颜色都由它推导。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final int value in TimetableStyle.seedChoices)
              _SeedDot(
                color: Color(value),
                selected: _style.seedColorValue == value,
                onTap: () => _apply(_style.copyWith(seedColorValue: value)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        StyleChoiceRow<AppThemeMode>(
          label: '明暗',
          values: AppThemeMode.values,
          selected: _style.themeMode,
          labelOf: (AppThemeMode value) => switch (value) {
            AppThemeMode.system => '跟随系统',
            AppThemeMode.light => '亮色',
            AppThemeMode.dark => '暗色',
          },
          onChanged: (AppThemeMode value) =>
              _apply(_style.copyWith(themeMode: value)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('纯黑模式'),
          subtitle: const Text('暗色下背景用纯黑'),
          value: _style.oledBlack,
          onChanged: _style.themeMode == AppThemeMode.light
              ? null
              : (bool value) => _apply(_style.copyWith(oledBlack: value)),
        ),
      ],
    );
  }
}

/// 主色圆点。
class _SeedDot extends StatelessWidget {
  const _SeedDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 通用控件
// ---------------------------------------------------------------------------

/// 一行「标题 + 当前值 + 滑块」。
class StyleSlider extends StatelessWidget {
  const StyleSlider({
    super.key,
    required this.label,
    required this.value,
    required this.slider,
  });

  final String label;
  final String value;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context)
              .copyWith(allowedInteraction: SliderInteraction.slideThumb),
          child: slider,
        ),
      ],
    );
  }
}

/// 一行「标题 + 若干可选项」。
class StyleChoiceRow<T> extends StatelessWidget {
  const StyleChoiceRow({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final T value in values)
                ChoiceChip(
                  label: Text(labelOf(value)),
                  selected: value == selected,
                  onSelected: (bool _) => onChanged(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
