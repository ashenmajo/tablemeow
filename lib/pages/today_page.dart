//today_page.dart
//该文件是今日页

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
    final String weekdayName = Semester.weekdayNames[(date.weekday - 1)];

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
    final CourseStatus status = courseStatusOf(range, now);

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
}

enum CourseStatus { upcoming, ongoing, finished, unknown }

CourseStatus courseStatusOf(PeriodTimeRange? range, DateTime now) {
  if (range == null) {
    return CourseStatus.unknown;
  }
  if (now.isBefore(range.start)) {
    return CourseStatus.upcoming;
  }
  if (now.isAfter(range.end)) {
    return CourseStatus.finished;
  }
  return CourseStatus.ongoing;
}

int _ceiledMinutes(Duration remaining) {
  const int microsPerMinute = Duration.microsecondsPerMinute;
  final int micros = remaining.inMicroseconds;
  if (micros <= 0) {
    return 0;
  }
  return (micros + microsPerMinute - 1) ~/ microsPerMinute;
}

String _durationText(int minutes) {
  final int hours = minutes ~/ 60;
  if (hours == 0) {
    return '$minutes 分钟';
  }
  final int rest = minutes % 60;
  if (rest == 0) {
    return '$hours 小时';
  }
  return '$hours 小时 $rest 分钟';
}

String courseStatusLabel({
  required CourseStatus status,
  PeriodTimeRange? range,
  required DateTime now,
}) {
  switch (status) {
    case CourseStatus.ongoing:
      final int minutes = range == null
          ? 0
          : _ceiledMinutes(range.end.difference(now));
      return '进行中 · 还剩 ${_durationText(minutes)}';
    case CourseStatus.upcoming:
      final int minutes = range == null
          ? 0
          : _ceiledMinutes(range.start.difference(now));
      return '${_durationText(minutes)}后';
    case CourseStatus.finished:
      return '已结束';
    case CourseStatus.unknown:
      return '待上课';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.range,
    required this.now,
  });

  final CourseStatus status;
  final PeriodTimeRange? range;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = courseStatusLabel(
      status: status,
      range: range,
      now: now,
    );
    final Color background = switch (status) {
      CourseStatus.ongoing => theme.colorScheme.primary,
      CourseStatus.upcoming => theme.colorScheme.secondaryContainer,
      CourseStatus.finished => theme.colorScheme.surfaceContainerHighest,
      CourseStatus.unknown => theme.colorScheme.surfaceContainerHighest,
    };
    final Color foreground = status == CourseStatus.ongoing
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
}
