//timetable.dart
//定义课表的数据结构，以及一节课的时间范围
import 'package:flutter/foundation.dart';
import 'course_session.dart';
import 'semester.dart';
import 'timetable_style.dart';

@immutable
class Timetable {
  const Timetable({
    required this.semester,
    this.sessions = const [],
    this.style = TimetableStyle.defaults,
  });

  factory Timetable.empty({DateTime? today}) =>
      Timetable(semester: Semester.defaults(today: today));

  final Semester semester;
  final List<CourseSession> sessions;
  final TimetableStyle style;

  bool get isEmpty => sessions.isEmpty;
  bool get isNotEmpty => sessions.isNotEmpty;

  // 取该周最后一节的结束节次，用 minPeriods 兜底，避免课表被压缩
  int visiblePeriodCount(int week, {int minPeriods = 8}) {
    final list = sessionsOfWeek(week);
    if (list.isEmpty) {
      return minPeriods;
    }
    final maxEnd = list.map((s) => s.endPeriod).reduce((a, b) => a > b ? a : b);
    return maxEnd > minPeriods ? maxEnd : minPeriods;
  }

  List<String> get courseNames =>
      sessions.map((s) => s.name).toSet().toList()..sort();

  int get courseCount => courseNames.length;

  List<CourseSession> sessionsAt({required int week, required int weekday}) {
    return sessions
        .where((s) => s.weekday == weekday && s.occursInWeek(week))
        .toList()
      ..sort(_byPeriod);
  }

  List<CourseSession> sessionsOn(DateTime date) =>
      sessionsAt(week: semester.weekOfDate(date), weekday: date.weekday);

  List<CourseSession> sessionsOfWeek(int week) {
    return sessions.where((s) => s.occursInWeek(week)).toList()
      ..sort(_byPeriod);
  }

  PeriodTimeRange? rangeOf(CourseSession session, DateTime day) {
    final start = semester.periodAt(session.startPeriod);
    final end = semester.periodAt(session.endPeriod);
    if (start == null || end == null) {
      return null;
    }
    return PeriodTimeRange(start: start.startAt(day), end: end.endAt(day));
  }

  Timetable copyWith({
    Semester? semester,
    List<CourseSession>? sessions,
    TimetableStyle? style,
  }) => Timetable(
    semester: semester ?? this.semester,
    sessions: sessions ?? this.sessions,
    style: style ?? this.style,
  );

  Map<String, dynamic> toJson() => {
    'semester': semester.toJson(),
    'style': style.toJson(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory Timetable.fromJson(Map<String, dynamic> json) {
    final rawStyle = json['style'];
    return Timetable(
      semester: Semester.fromJson(
        (json['semester'] as Map).cast<String, dynamic>(),
      ),
      style: rawStyle is Map
          ? TimetableStyle.fromJson(rawStyle.cast<String, dynamic>())
          : TimetableStyle.defaults,
      sessions: ((json['sessions'] as List?) ?? [])
          .whereType<Map>()
          .map((m) => CourseSession.fromJson(m.cast<String, dynamic>()))
          .toList(),
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
