import 'package:flutter/foundation.dart';

/// 一天的三个时段：上午 / 下午 / 晚上。
enum PeriodSession { morning, afternoon, evening }

/// 一节课（小节）的时间安排。
@immutable
class PeriodTime {
  const PeriodTime({
    required this.index,
    required this.start,
    required this.end,
  });

  /// 节次序号，从 1 开始。
  final int index;

  /// 开始时间，形如 `08:00`。
  final String start;

  /// 结束时间，形如 `08:45`。
  final String end;

  String get label => '第 $index 节';

  /// `08:20` → 500（从零点开始的分钟数）。
  static int minuteOf(String hhmm) {
    final List<String> parts = hhmm.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }

  /// 500 → `08:20`（超过一天按取模算）。
  static String clockOf(int minute) {
    final int wrapped = minute % (24 * 60);
    final int hour = wrapped ~/ 60;
    final int rest = wrapped % 60;
    return '${_twoDigits(hour)}:${_twoDigits(rest)}';
  }

  /// 这节课属于上午 / 下午 / 晚上（按开始时间划分）。
  PeriodSession get session {
    final int minute = minuteOf(start);
    if (minute < 12 * 60) {
      return PeriodSession.morning;
    }
    if (minute < 18 * 60) {
      return PeriodSession.afternoon;
    }
    return PeriodSession.evening;
  }

  static String _twoDigits(int value) =>
      value < 10 ? '0$value' : '$value';

  /// 当天该节次的开始时刻，用于时间线、倒计时等比较。
  DateTime startAt(DateTime day) => _at(day, start);

  /// 当天该节次的结束时刻。
  DateTime endAt(DateTime day) => _at(day, end);

  PeriodTime copyWith({int? index, String? start, String? end}) {
    return PeriodTime(
      index: index ?? this.index,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'index': index,
    'start': start,
    'end': end,
  };

  factory PeriodTime.fromJson(Map<String, dynamic> json) {
    return PeriodTime(
      index: (json['index'] as num).toInt(),
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  static DateTime _at(DateTime day, String hhmm) {
    final List<String> parts = hhmm.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodTime &&
        other.index == index &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(index, start, end);

  @override
  String toString() => 'PeriodTime($index, $start-$end)';
}
