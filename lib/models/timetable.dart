import 'package:flutter/foundation.dart';

import 'course_session.dart';
import 'period_time.dart';
import 'semester.dart';
import 'timetable_style.dart';

@immutable
class Timetable {
  const Timetable({
    required this.semester,
    this.sessions = const <CourseSession>[],
    this.style = TimetableStyle.defaults,
  });

  factory Timetable.empty({DateTime? today}) =>
      Timetable(semester: Semester.defaults(today: today));

  final Semester semester;
  final List<CourseSession> sessions;

  final TimetableStyle style;

  bool get isEmpty => sessions.isEmpty;

  bool get isNotEmpty => sessions.isNotEmpty;

  /*
  第week周课表需要显示到第几节。
  取该周最后一节课的结束节次，并用minPeriods兜底，
  避免只上两节课时课表被压得过短。
*/
  int visiblePeriodCount(int week, {int minPeriods = 8}) {
    int last = 0;
    for (final CourseSession session in sessionsOfWeek(week)) {
      if (session.endPeriod > last) {
        last = session.endPeriod;
      }
    }
    final int target = last > minPeriods ? last : minPeriods;
    return target.clamp(1, semester.periods.length);
  }

  /// 全部课程名（去重、按名称排序
  List<String> get courseNames =>
      sessions.map((CourseSession session) => session.name).toSet().toList()
        ..sort();


  int get courseCount => courseNames.length;

  List<CourseSession> sessionsAt({required int week, required int weekday}) {
    return sessions
        .where(
          (CourseSession session) =>
              session.weekday == weekday && session.occursInWeek(week),
        )
        .toList()
      ..sort(_byPeriod);
  }

  List<CourseSession> sessionsOn(DateTime date) =>
      sessionsAt(week: semester.weekOfDate(date), weekday: date.weekday);

  List<CourseSession> sessionsOfWeek(int week) {
    return sessions
        .where((CourseSession session) => session.occursInWeek(week))
        .toList()
      ..sort(_byPeriod);
  }

  PeriodTimeRange? rangeOf(CourseSession session, DateTime day) =>
      _rangeOf(session, day);

  PeriodTimeRange? _rangeOf(CourseSession session, DateTime day) {
    final PeriodTime? startPeriod = semester.periodAt(session.startPeriod);
    final PeriodTime? endPeriod = semester.periodAt(session.endPeriod);
    if (startPeriod == null || endPeriod == null) {
      return null;
    }
    return PeriodTimeRange(
      start: startPeriod.startAt(day),
      end: endPeriod.endAt(day),
    );
  }

  Timetable copyWith({
    Semester? semester,
    List<CourseSession>? sessions,
    TimetableStyle? style,
  }) {
    return Timetable(
      semester: semester ?? this.semester,
      sessions: sessions ?? this.sessions,
      style: style ?? this.style,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'semester': semester.toJson(),
    'style': style.toJson(),
    'sessions': <Map<String, dynamic>>[
      for (final CourseSession session in sessions) session.toJson(),
    ],
  };

  factory Timetable.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawSessions =
        json['sessions'] as List<Object?>? ?? const <Object?>[];
    final Object? rawStyle = json['style'];
    return Timetable(
      semester: Semester.fromJson(
        (json['semester'] as Map).cast<String, dynamic>(),
      ),
      style: rawStyle is Map
          ? TimetableStyle.fromJson(rawStyle.cast<String, dynamic>())
          : TimetableStyle.defaults,
      sessions: <CourseSession>[
        for (final Object? item in rawSessions)
          if (item is Map<String, dynamic>)
            CourseSession.fromJson(item)
          else if (item is Map)
            CourseSession.fromJson(item.cast<String, dynamic>()),
      ],
    );
  }

  static int _byPeriod(CourseSession a, CourseSession b) {
    if (a.startPeriod != b.startPeriod) {
      return a.startPeriod.compareTo(b.startPeriod);
    }
    return a.name.compareTo(b.name);
  }
}

@immutable
class PeriodTimeRange {
  const PeriodTimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
