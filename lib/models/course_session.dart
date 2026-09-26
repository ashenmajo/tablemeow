import 'package:flutter/foundation.dart';

/// 一次上课安排：某门课在「星期几的第几节到第几节、哪些周」上课。
///
/// 课表数据以 [CourseSession] 列表的形式保存，同一门课一周上多次时
/// 会有多条记录。
@immutable
class CourseSession {
  const CourseSession({
    required this.name,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
    required this.weeks,
    this.teacher = '',
    this.location = '',
  });

  /// 课程名称。
  final String name;

  /// 星期几：1 表示周一，7 表示周日。
  final int weekday;

  /// 起始节次，从 1 开始。
  final int startPeriod;

  /// 结束节次，等于 [startPeriod] 时表示单节连堂。
  final int endPeriod;

  /// 上课周次，例如 `[1, 2, 3, ...]` 或 `[1, 3, 5]`。
  final List<int> weeks;

  /// 任课教师，可能为空。
  final String teacher;

  /// 上课地点，可能为空。
  final String location;

  int get periodCount => endPeriod - startPeriod + 1;

  bool occursInWeek(int week) => weeks.contains(week);

  String get periodLabel =>
      startPeriod == endPeriod ? '$startPeriod 节' : '$startPeriod-$endPeriod 节';

  /// 周次的可读文本，例如 `1-16周`、`1-16周(单)`、`1,3,5-9周`。
  String get weeksLabel => formatWeeks(weeks);

  CourseSession copyWith({
    String? name,
    int? weekday,
    int? startPeriod,
    int? endPeriod,
    List<int>? weeks,
    String? teacher,
    String? location,
  }) {
    return CourseSession(
      name: name ?? this.name,
      weekday: weekday ?? this.weekday,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weeks: weeks ?? this.weeks,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'weekday': weekday,
    'startPeriod': startPeriod,
    'endPeriod': endPeriod,
    'weeks': weeks,
    'teacher': teacher,
    'location': location,
  };

  factory CourseSession.fromJson(Map<String, dynamic> json) {
    return CourseSession(
      name: (json['name'] as String? ?? '').trim(),
      weekday: (json['weekday'] as num? ?? 1).toInt(),
      startPeriod: (json['startPeriod'] as num? ?? 1).toInt(),
      endPeriod: (json['endPeriod'] as num? ?? 1).toInt(),
      weeks: <int>[
        for (final Object? week
            in (json['weeks'] as List<Object?>? ?? const <Object?>[]))
          if (week is num) week.toInt(),
      ],
      teacher: json['teacher'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }

  /// 把一组周次压缩成便于阅读的文本。
  static String formatWeeks(List<int> weeks) {
    final List<int> sorted = weeks.toSet().toList()..sort();
    if (sorted.isEmpty) {
      return '未指定';
    }
    final List<String> segments = <String>[];
    int start = sorted.first;
    int previous = sorted.first;
    for (final int week in sorted.skip(1)) {
      if (week == previous + 1) {
        previous = week;
        continue;
      }
      segments.add(start == previous ? '$start' : '$start-$previous');
      start = week;
      previous = week;
    }
    segments.add(start == previous ? '$start' : '$start-$previous');

    final bool allOdd = sorted.every((int week) => week.isOdd);
    final bool allEven = sorted.every((int week) => week.isEven);
    final String suffix = allOdd ? '(单)' : (allEven ? '(双)' : '');
    return "${segments.join(",")}周$suffix";
  }

  @override
  bool operator ==(Object other) {
    return other is CourseSession &&
        other.name == name &&
        other.weekday == weekday &&
        other.startPeriod == startPeriod &&
        other.endPeriod == endPeriod &&
        other.teacher == teacher &&
        other.location == location &&
        listEquals(other.weeks, weeks);
  }

  @override
  int get hashCode => Object.hash(
    name,
    weekday,
    startPeriod,
    endPeriod,
    teacher,
    location,
    Object.hashAll(weeks),
  );

  @override
  String toString() =>
      'CourseSession($name, 周$weekday $periodLabel, $weeksLabel)';
}
