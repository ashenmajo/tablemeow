import 'package:flutter/foundation.dart';

import 'period_time.dart';

@immutable
class Semester {
  const Semester({
    required this.startDate,
    this.totalWeeks = 20,
    this.periods = defaultPeriods,
  });

  final DateTime startDate;
  final int totalWeeks;
  final List<PeriodTime> periods;

  static const weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static const defaultPeriods = [
    PeriodTime(index: 1, start: '08:00', end: '08:45'),
    PeriodTime(index: 2, start: '08:55', end: '09:40'),
    PeriodTime(index: 3, start: '10:00', end: '10:45'),
    PeriodTime(index: 4, start: '10:55', end: '11:40'),
    PeriodTime(index: 5, start: '14:00', end: '14:45'),
    PeriodTime(index: 6, start: '14:55', end: '15:40'),
    PeriodTime(index: 7, start: '16:00', end: '16:45'),
    PeriodTime(index: 8, start: '16:55', end: '17:40'),
    PeriodTime(index: 9, start: '19:00', end: '19:45'),
    PeriodTime(index: 10, start: '19:55', end: '20:40'),
    PeriodTime(index: 11, start: '20:50', end: '21:35'),
    PeriodTime(index: 12, start: '21:45', end: '22:30'),
  ];

  static List<PeriodTime> autoPeriods(
    List<PeriodTime> periods, {
    required int morningStart,
    required int afternoonStart,
    required int eveningStart,
    required int lessonMinutes,
    required int breakMinutes,
  }) {
    final lesson = lessonMinutes.clamp(10, 180);
    final rest = breakMinutes.clamp(0, 60);
    var cursor = {
      PeriodSession.morning: morningStart,
      PeriodSession.afternoon: afternoonStart,
      PeriodSession.evening: eveningStart,
    };

    var result = <PeriodTime>[];
    for (final p in periods) {
      final start = cursor[p.session]!;
      cursor[p.session] = start + lesson + rest;
      result.add(
        PeriodTime(
          index: p.index,
          start: PeriodTime.clockOf(start),
          end: PeriodTime.clockOf(start + lesson),
        ),
      );
    }
    return result;
  }

  factory Semester.defaults({DateTime? today}) =>
      Semester(startDate: mondayOf(today ?? DateTime.now()));

  static DateTime mondayOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  String weekdayName(int weekday) => weekdayNames[weekday - 1];

  DateTime weekStart(int week) => startDate.add(Duration(days: (week - 1) * 7));

  DateTime dateOf(int week, int weekday) =>
      weekStart(week).add(Duration(days: weekday - 1));

  int weekOfDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.difference(startDate).inDays ~/ 7 + 1;
  }

  bool containsDate(DateTime date) {
    final w = weekOfDate(date);
    return w >= 1 && w <= totalWeeks;
  }

  PeriodTime? periodAt(int index) {
    for (final p in periods) {
      if (p.index == index) return p;
    }
    return null;
  }

  Semester copyWith({
    DateTime? startDate,
    int? totalWeeks,
    List<PeriodTime>? periods,
  }) => Semester(
    startDate: startDate ?? this.startDate,
    totalWeeks: totalWeeks ?? this.totalWeeks,
    periods: periods ?? this.periods,
  );

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'totalWeeks': totalWeeks,
    'periods': periods.map((p) => p.toJson()).toList(),
  };

  factory Semester.fromJson(Map<String, dynamic> json) {
    final raw = (json['periods'] as List?) ?? [];
    final list = raw
        .whereType<Map>()
        .map((m) => PeriodTime.fromJson(m.cast<String, dynamic>()))
        .toList();
    return Semester(
      startDate: DateTime.parse(json['startDate'] as String),
      totalWeeks: (json['totalWeeks'] as num? ?? 20).toInt(),
      periods: list.isEmpty ? defaultPeriods : list,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Semester &&
      other.startDate == startDate &&
      other.totalWeeks == totalWeeks &&
      listEquals(other.periods, periods);

  @override
  int get hashCode =>
      Object.hash(startDate, totalWeeks, Object.hashAll(periods));
}
