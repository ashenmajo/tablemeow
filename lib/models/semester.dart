import 'package:flutter/foundation.dart';

import 'period_time.dart';

/// 学期设置：起始周、总周数、节次时间与显示偏好。
@immutable
class Semester {
  const Semester({
    required this.startDate,
    this.totalWeeks = 20,
    this.periods = defaultPeriods,
  });

  /// 第 1 周的周一，课表所有日期都由它推算。
  final DateTime startDate;

  final int totalWeeks;

  /// 每节课的时间安排，按节次升序。
  final List<PeriodTime> periods;

  /// 星期一至星期日的中文名，下标 0 对应周一。
  static const List<String> weekdayNames = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  /// 默认节次时间，可在设置页逐节调整。
  static const List<PeriodTime> defaultPeriods = <PeriodTime>[
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

  /// 自动重排节次时间：给出上午 / 下午 / 晚上的开始时间、每节时长与课间休息，
  /// 现有节次按当前开始时间分成三段（<12:00、12:00–18:00、≥18:00），
  /// 各段节数不变，只重算起止时间。
  static List<PeriodTime> autoPeriods(
    List<PeriodTime> periods, {
    required int morningStart,
    required int afternoonStart,
    required int eveningStart,
    required int lessonMinutes,
    required int breakMinutes,
  }) {
    final int lesson = lessonMinutes.clamp(10, 180);
    final int rest = breakMinutes.clamp(0, 60);
    final Map<PeriodSession, int> starts = <PeriodSession, int>{
      PeriodSession.morning: morningStart,
      PeriodSession.afternoon: afternoonStart,
      PeriodSession.evening: eveningStart,
    };

    final Map<PeriodSession, int> cursor = Map<PeriodSession, int>.of(starts);
    final List<PeriodTime> result = <PeriodTime>[];
    for (final PeriodTime period in periods) {
      final PeriodSession session = period.session;
      final int start = cursor[session] ?? starts[session]!;
      cursor[session] = start + lesson + rest;
      result.add(
        PeriodTime(
          index: period.index,
          start: PeriodTime.clockOf(start),
          end: PeriodTime.clockOf(start + lesson),
        ),
      );
    }
    return result;
  }

  /// 以 [today] 所在周的周一作为第 1 周，生成一份默认学期设置。
  factory Semester.defaults({DateTime? today}) {
    return Semester(startDate: mondayOf(today ?? DateTime.now()));
  }

  /// 取 [date] 所在周的周一（零点）。
  static DateTime mondayOf(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  /// 星期名称（1 表示周一）。
  String weekdayName(int weekday) => weekdayNames[(weekday - 1).clamp(0, 6)];

  DateTime weekStart(int week) => startDate.add(Duration(days: (week - 1) * 7));

  /// 第 [week] 周星期 [weekday] 对应的日期。
  DateTime dateOf(int week, int weekday) =>
      weekStart(week).add(Duration(days: weekday - 1));

  /// [date] 属于第几周，可能小于 1（学期开始前）或大于 [totalWeeks]。
  int weekOfDate(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    return day.difference(startDate).inDays ~/ 7 + 1;
  }

  bool containsDate(DateTime date) {
    final int week = weekOfDate(date);
    return week >= 1 && week <= totalWeeks;
  }

  /// 按节次序号取时间安排，序号不存在时返回 null。
  PeriodTime? periodAt(int index) {
    for (final PeriodTime period in periods) {
      if (period.index == index) {
        return period;
      }
    }
    return null;
  }

  Semester copyWith({
    DateTime? startDate,
    int? totalWeeks,
    List<PeriodTime>? periods,
  }) {
    return Semester(
      startDate: startDate ?? this.startDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      periods: periods ?? this.periods,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'startDate': startDate.toIso8601String(),
    'totalWeeks': totalWeeks,
    'periods': <Map<String, dynamic>>[
      for (final PeriodTime period in periods) period.toJson(),
    ],
  };

  factory Semester.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawPeriods =
        json['periods'] as List<Object?>? ?? const <Object?>[];
    final List<PeriodTime> periods = <PeriodTime>[
      for (final Object? item in rawPeriods)
        if (item is Map<String, dynamic>)
          PeriodTime.fromJson(item)
        else if (item is Map)
          PeriodTime.fromJson(item.cast<String, dynamic>()),
    ];
    return Semester(
      startDate: DateTime.parse(json['startDate'] as String),
      totalWeeks: (json['totalWeeks'] as num? ?? 20).toInt(),
      periods: periods.isEmpty ? defaultPeriods : periods,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Semester &&
        other.startDate == startDate &&
        other.totalWeeks == totalWeeks &&
        listEquals(other.periods, periods);
  }

  @override
  int get hashCode =>
      Object.hash(startDate, totalWeeks, Object.hashAll(periods));
}
