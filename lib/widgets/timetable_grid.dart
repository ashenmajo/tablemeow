import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/course_session.dart';
import '../models/period_time.dart';
import '../models/semester.dart';
import '../models/timetable_style.dart';
import '../theme/course_palette.dart';
import '../utils/timeline.dart';

/// 周课表网格：左侧是节次与上课时间，右侧每天一列，课程按节次纵向排布。
///
/// 列宽、行高、字号、行距、配色与显示哪些信息都由 [TimetableStyle] 决定，
/// 具体设置在「设置 → 课表外观」里调整。
/// 列宽不足时会自动横向滚动，竖直方向随页面滚动。
class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    super.key,
    required this.semester,
    required this.week,
    required this.sessions,
    required this.periods,
    required this.now,
    required this.style,
    this.visibleDayCount,
    this.onSessionTap,
  });

  final Semester semester;

  final int week;

  final List<CourseSession> sessions;

  /// 实际渲染的节次（已按该周课程裁剪）。
  final List<PeriodTime> periods;

  /// 当前时间，用于高亮今天与绘制时间线。
  final DateTime now;

  final TimetableStyle style;

  /// 预览场景可只显示前几天，避免把完整周课表塞进小卡片。
  final int? visibleDayCount;

  final ValueChanged<CourseSession>? onSessionTap;

  /// 实际使用的行高：自动模式下把可视高度摊给本周的节次，
  /// 用户指定了行高就用它（放不下时竖直滚动）。
  static double rowHeightFor({
    required double availableHeight,
    required int periodCount,
    required TimetableStyle style,
  }) {
    final int count = math.max(periodCount, 1);
    if (!style.autoCellHeight) {
      return style.cellHeight;
    }
    final double gridHeight = availableHeight - style.headerHeight;
    if (!gridHeight.isFinite || gridHeight <= 0) {
      return TimetableStyle.minAutoCellHeight;
    }
    return math.max(gridHeight / count, TimetableStyle.minAutoCellHeight);
  }

  @override
  Widget build(BuildContext context) {
    final int dayCount = (visibleDayCount ?? style.weekdayCount).clamp(1, 7);
    final double periodWidth = style.showPeriodColumn
        ? style.periodColumnWidth
        : 0;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = math.max(
          constraints.maxWidth - periodWidth,
          0,
        );
        final double dayWidth = math.max(available / dayCount, style.dayWidth);
        final double totalWidth = periodWidth + dayWidth * dayCount;
        final double cellHeight = rowHeightFor(
          availableHeight: constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : periods.length * TimetableStyle.minAutoCellHeight,
          periodCount: periods.length,
          style: style,
        );
        final double gridHeight = periods.length * cellHeight;
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : gridHeight + style.headerHeight;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            height: height,
            child: Column(
              children: <Widget>[
                _buildHeader(context, dayWidth, dayCount, periodWidth),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: gridHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (style.showPeriodColumn)
                            _buildPeriodColumn(context, periods, cellHeight),
                          for (int weekday = 1; weekday <= dayCount; weekday++)
                            _buildDayColumn(
                              context,
                              weekday: weekday,
                              width: dayWidth,
                              periods: periods,
                              cellHeight: cellHeight,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double dayWidth,
    int dayCount,
    double periodWidth,
  ) {
    return SizedBox(
      height: style.headerHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: periodWidth),
          for (int weekday = 1; weekday <= dayCount; weekday++)
            SizedBox(width: dayWidth, child: _buildDayHeader(context, weekday)),
        ],
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context, int weekday) {
    final ThemeData theme = Theme.of(context);
    final DateTime date = semester.dateOf(week, weekday);
    final bool isCurrentDate = _isSameDay(date, now);
    final bool isToday = style.highlightToday && isCurrentDate;
    final Color labelColor = isToday
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isToday ? theme.colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 7 列时单列很窄，标题必须禁掉换行，否则表头会溢出。
            Text(
              semester.weekdayName(weekday),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
            ),
            if (style.showHeaderDate)
              Text(
                '${date.month}/${date.day}',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: labelColor,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodColumn(
    BuildContext context,
    List<PeriodTime> periods,
    double cellHeight,
  ) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? timeStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 9,
      height: 1.15,
      color: theme.colorScheme.onSurfaceVariant,
    );
    // 三行（节次 + 开始 + 结束）放得下才显示结束时间。
    final bool showEnd = style.showPeriodEndTime && cellHeight >= 52;

    return SizedBox(
      width: style.periodColumnWidth,
      child: Column(
        children: <Widget>[
          for (final PeriodTime period in periods)
            SizedBox(
              height: cellHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${period.index}',
                    maxLines: 1,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(period.start, maxLines: 1, style: timeStyle),
                  if (showEnd) Text(period.end, maxLines: 1, style: timeStyle),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context, {
    required int weekday,
    required double width,
    required List<PeriodTime> periods,
    required double cellHeight,
  }) {
    final ThemeData theme = Theme.of(context);
    final DateTime date = semester.dateOf(week, weekday);
    final bool isCurrentDate = _isSameDay(date, now);
    final bool isToday = style.highlightToday && isCurrentDate;
    final List<CourseSession> daySessions = sessions
        .where((CourseSession session) => session.weekday == weekday)
        .toList();
    final Color gridColor = theme.colorScheme.outlineVariant;
    final double? nowOffset = style.showCurrentTime && isCurrentDate
        ? Timeline.offsetOf(periods, now, cellHeight: cellHeight)
        : null;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.16)
            : null,
        border: style.showGrid
            ? Border(left: BorderSide(color: gridColor, width: 0.5))
            : null,
      ),
      child: Stack(
        children: <Widget>[
          if (style.showGrid)
            for (int index = 0; index < periods.length; index++)
              Positioned(
                left: 0,
                right: 0,
                top: index * cellHeight,
                height: cellHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: gridColor, width: 0.5),
                    ),
                  ),
                ),
              ),
          for (final CourseSession session in daySessions)
            Positioned(
              top:
                  (session.startPeriod - 1) * cellHeight + style.courseBlockGap,
              height:
                  session.periodCount * cellHeight - style.courseBlockGap * 2,
              left: style.courseBlockGap,
              right: style.courseBlockGap,
              child: _CourseBlock(
                session: session,
                style: style,
                onTap: onSessionTap,
              ),
            ),
          if (nowOffset != null)
            Positioned(
              top: nowOffset,
              left: 0,
              right: 0,
              child: _buildNowLine(theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _buildNowLine(Color color) {
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(child: Container(height: 1.5, color: color)),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 课表里的一节课：按设置显示课程名、地点与教师。
class _CourseBlock extends StatelessWidget {
  const _CourseBlock({required this.session, required this.style, this.onTap});

  final CourseSession session;
  final TimetableStyle style;
  final ValueChanged<CourseSession>? onTap;

  /// 楼名（中文）与房间号（数字 / 字母）。
  static final RegExp _buildingAndRoom = RegExp(
    r'^([^\x00-\x7F]+)\s*([\x00-\x7F].*)$',
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    // 颜色按真实课程名取，显示名可以是别名。
    final Color background = CoursePalette.surface(session.name, style, scheme);
    final Color foreground = CoursePalette.onSurface(
      session.name,
      style,
      scheme,
    );
    final String title = style.nameFor(session.name);
    final bool wantLocation = style.showLocation && session.location.isNotEmpty;
    final bool wantTeacher = style.showTeacher && session.teacher.isNotEmpty;
    final List<String> parts = _locationParts(session.location);

    // 用 strut 把行高钉死，不锁死会撑破格子出现overflow黄条
    final StrutStyle nameStrut = StrutStyle(
      fontSize: style.fontSize,
      height: style.lineHeightFactor,
      forceStrutHeight: true,
    );
    final StrutStyle detailStrut = StrutStyle(
      fontSize: style.detailFontSize,
      height: style.lineHeightFactor,
      forceStrutHeight: true,
    );
    final TextStyle? nameStyle = theme.textTheme.labelMedium?.copyWith(
      color: foreground,
      fontWeight: FontWeight.w600,
      fontSize: style.fontSize,
      height: style.lineHeightFactor,
    );
    final TextStyle? detailStyle = theme.textTheme.labelSmall?.copyWith(
      color: foreground.withValues(alpha: 0.85),
      fontSize: style.detailFontSize,
      height: style.lineHeightFactor,
    );

    final bool centered =
        style.courseTextAlignment == CourseTextAlignment.center;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(style.courseBlockRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(session),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: style.courseHorizontalPadding,
            vertical: style.courseVerticalPadding,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final ({int nameLines, int detailLines}) budget = style
                  .lineBudget(
                    constraints.maxHeight + style.courseVerticalPadding * 2,
                    detailWidgets:
                        (wantLocation ? 1 : 0) + (wantTeacher ? 1 : 0),
                  );
              final int locationLines = wantLocation
                  ? math.min(
                      budget.detailLines,
                      TimetableStyle.maxLocationLines,
                    )
                  : 0;
              final int teacherLines = wantTeacher
                  ? math.min(
                      budget.detailLines - locationLines,
                      TimetableStyle.maxTeacherLines,
                    )
                  : 0;
              final bool splitLocation =
                  style.splitLocation &&
                  parts.length > 1 &&
                  locationLines >= parts.length;

              return Column(
                crossAxisAlignment: centered
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: budget.nameLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: centered ? TextAlign.center : TextAlign.start,
                    strutStyle: nameStrut,
                    style: nameStyle,
                  ),
                  if (locationLines > 0 && splitLocation)
                    Wrap(
                      alignment: centered
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      children: <Widget>[
                        for (final String part in parts)
                          Text(
                            part,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            textAlign: centered
                                ? TextAlign.center
                                : TextAlign.start,
                            strutStyle: detailStrut,
                            style: detailStyle,
                          ),
                      ],
                    )
                  else if (locationLines > 0)
                    Text(
                      session.location,
                      maxLines: locationLines,
                      overflow: TextOverflow.ellipsis,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      strutStyle: detailStrut,
                      style: detailStyle,
                    ),
                  if (teacherLines > 0)
                    Text(
                      style.teacherFor(session.teacher),
                      maxLines: teacherLines,
                      overflow: TextOverflow.ellipsis,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      strutStyle: detailStrut,
                      style: detailStyle,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  static List<String> _locationParts(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return const <String>[];
    }
    final RegExpMatch? match = _buildingAndRoom.firstMatch(text);
    if (match == null) {
      return <String>[text];
    }
    final String building = match.group(1)!.trim();
    final String room = match.group(2)!.trim();
    if (building.isEmpty || room.isEmpty) {
      return <String>[text];
    }
    return <String>[building, room];
  }
}
