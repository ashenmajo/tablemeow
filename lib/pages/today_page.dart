import 'package:flutter/material.dart';

import '../models/course_session.dart';
import '../models/semester.dart';
import '../models/timetable.dart';
import '../models/timetable_style.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../utils/date_format.dart';
import '../widgets/course_detail_sheet.dart';
import '../theme/course_palette.dart';
import '../widgets/empty_state.dart';

/// 今日页：当天课程时间轴与进行状态。
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final DateTime now = state.now;
    final Semester semester = state.semester;
    final List<CourseSession> sessions = state.timetable.sessionsOn(now);

    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _DayHeader(
            date: now,
            week: semester.weekOfDate(now),
            inSemester: semester.containsDate(now),
            courseCount: sessions.length,
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            const Card(
              child: EmptyState(
                icon: Icons.event_available_outlined,
                title: '今天没有课',
                message: '好好休息，或者去看看其他周的安排。',
              ),
            )
          else
            for (final CourseSession session in sessions) ...<Widget>[
              _TodayCourseCard(
                session: session,
                timetable: state.timetable,
                now: now,
                onTap: () => showCourseDetailSheet(
                  context,
                  session: session,
                  semester: semester,
                  week: semester.weekOfDate(now),
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

/// 顶部日期与周次信息。
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.week,
    required this.inSemester,
    required this.courseCount,
  });

  final DateTime date;
  final int week;
  final bool inSemester;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String weekdayName =
        Semester.weekdayNames[(date.weekday - 1).clamp(0, 6)];

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${formatMonthDay(date)} $weekdayName',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              inSemester
                  ? '第 $week 周 · 共 $courseCount 节课'
                  : '今天不在学期范围内 · 已按常规节次显示',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 今日的一节课。
class _TodayCourseCard extends StatelessWidget {
  const _TodayCourseCard({
    required this.session,
    required this.timetable,
    required this.now,
    required this.onTap,
  });

  final CourseSession session;
  final Timetable timetable;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PeriodTimeRange? range = timetable.rangeOf(session, now);
    final TimetableStyle style = AppScope.of(context).style;
    final Color accent = CoursePalette.onSurface(
      session.name,
      style,
      theme.colorScheme,
    );
    final _CourseStatus status = _statusOf(range, now);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      range == null
                          ? session.periodLabel
                          : formatClock(range.start),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (range != null)
                      Text(
                        formatClock(range.end),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      <String>[
                        if (session.location.isNotEmpty) session.location,
                        if (session.teacher.isNotEmpty) session.teacher,
                        session.periodLabel,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status, range: range, now: now),
            ],
          ),
        ),
      ),
    );
  }

  static _CourseStatus _statusOf(PeriodTimeRange? range, DateTime now) {
    if (range == null) {
      return _CourseStatus.unknown;
    }
    if (now.isBefore(range.start)) {
      return _CourseStatus.upcoming;
    }
    if (now.isAfter(range.end)) {
      return _CourseStatus.finished;
    }
    return _CourseStatus.ongoing;
  }
}

enum _CourseStatus { upcoming, ongoing, finished, unknown }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.range,
    required this.now,
  });

  final _CourseStatus status;
  final PeriodTimeRange? range;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = _label();
    final Color background = switch (status) {
      // 进行中的课程用主题主色，避免与课程自身配色混淆。
      _CourseStatus.ongoing => theme.colorScheme.primary,
      _CourseStatus.upcoming => theme.colorScheme.secondaryContainer,
      _CourseStatus.finished => theme.colorScheme.surfaceContainerHighest,
      _CourseStatus.unknown => theme.colorScheme.surfaceContainerHighest,
    };
    final Color foreground = status == _CourseStatus.ongoing
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }

  String _label() {
    switch (status) {
      case _CourseStatus.ongoing:
        final int minutes = range == null
            ? 0
            : range!.end.difference(now).inMinutes;
        return '进行中 · 还剩 ${minutes <= 0 ? 1 : minutes} 分钟';
      case _CourseStatus.upcoming:
        final int minutes = range == null
            ? 0
            : range!.start.difference(now).inMinutes;
        if (minutes < 60) {
          return '${minutes <= 0 ? 1 : minutes} 分钟后';
        }
        return '${(minutes / 60).floor()} 小时后';
      case _CourseStatus.finished:
        return '已结束';
      case _CourseStatus.unknown:
        return '待上课';
    }
  }
}
